from collections import namedtuple

from invoke import task
from invoke.exceptions import UnexpectedExit

Project = namedtuple(
    "Project", ("git_repo", "docker_repo", "tag", "patch", "depends_on", "build_args")
)

project_list = {
    "wget-gnutls": Project(
        git_repo="https://github.com/ArchiveTeam/wget-lua",
        docker_repo="imrehg/archiveteam-arm-wget-lua",
        tag="v1.21.3-at-gnutls",
        patch=None,
        depends_on=None,
        build_args=["TLSTYPE=gnutls"],
    ),
    "grab-base-gnutls": Project(
        git_repo="https://github.com/ArchiveTeam/grab-base-df",
        docker_repo="imrehg/archiveteam-arm-grab-base",
        tag="gnutls",
        patch="grab-base.patch",
        depends_on="wget-gnutls",
        build_args=["TLSTYPE=gnutls"],
    ),
    "reddit": Project(
        git_repo="https://github.com/ArchiveTeam/reddit-grab",
        docker_repo="imrehg/archiveteam-arm-reddit-grab",
        tag="latest",
        patch=None,
        depends_on="grab-base-gnutls",
        build_args=[],
    ),
}

BuildResult = namedtuple("BuildResult", ("rebuilt"))


def get_remote_revision(c, repo):
    cmd = "git ls-remote {repo} HEAD".format(repo=repo)
    res = c.run(cmd, hide="both")
    hash = res.stdout.strip().split()[0]
    return hash


def image_exists(c, image):
    try:
        c.run(f"docker manifest inspect {image}", hide="both")
        exists = True
    except UnexpectedExit:
        exists = False
    return exists


@task
def build(c, project_name, force=False):
    """Build shit."""
    if project_name not in project_list:
        print(
            f"Cannot find {project_name} among supported projects: {', '.join(list(project_list.keys()))}"
        )
        return
    print(f"Building: {project_name}, force: {force}")

    project = project_list[project_name]
    if not force:
        print("Checking if image alread exists...")
        hash = get_remote_revision(c, project.git_repo)
        print(f"remote rev: {hash}")
        exists = image_exists(c, f"{project.docker_repo}:{hash}")
        print(f"Image exsits: {exists}")

    to_build = force or not exists
    print(f"To build: {to_build}")

    if to_build:
        cmd = f"./build.sh -r {project.git_repo} -i {project.docker_repo} -t {project.tag}"
        if project.patch is not None:
            cmd += f" -a {project.patch}"
        for build_arg in project.build_args:
            cmd += f" -b {build_arg}"
        c.run(cmd)

    return BuildResult(rebuilt=to_build)


@task
def buildall(c, force=False):
    dependencies = [None]
    rebuild = False
    while True:
        to_do_list = []
        for project in project_list:
            if project_list[project].depends_on in dependencies:
                to_do_list += [project]

        for project in to_do_list:
            result = build(c, project, force or rebuild)
            rebuild = rebuild or result.rebuilt

        dependencies = to_do_list
        if len(dependencies) == 0:
            break
