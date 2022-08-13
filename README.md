# ARM versions of Archive Team Docker images

[Archive Team](https://wiki.archiveteam.org/) is saving our digital heritage.
They have stand-alone VirtualBox-packaged versions of their archivers, and
also have instructions to [run Archive Team projects with Docker](https://wiki.archiveteam.org/index.php/Running_Archive_Team_Projects_with_Docker).
The official images are however only available for x86_64 (amd64). The
projects themselves run a mixture of Lua/Python, and should just work
on ARM processors, widening the list of available hardware that can be used
to archive (e.g. [RaspberryPi](https://www.raspberrypi.org/), or other
common ARM64/ARMv7/ARMv6 boards).

This repo aims to provide information and patched build scripts to
either build the relevant images for these architectures, or to run
the actual Archive Team projects with the nre base images.

**Note:** this repo is a work-in-progress, so not everything might work.

## Projects

The following lists of projects are supported so far and have images:

| Project | Official Image | ARM Image (this repo) |
| ------- | -------------- | --------------------- |
| [Reddit](https://wiki.archiveteam.org/index.php/Reddit) | `atdr.meo.ws/archiveteam/reddit-grab` | [`imrehg/archiveteam-arm-reddit-grab`](https://hub.docker.com/repository/docker/imrehg/archiveteam-arm-reddit-grab) |

In addition to the project images, the following base images are provided:

| Official Image | ARM Image (this repo) |
| -------------- | --------------------- |
| `atdr.meo.ws/archiveteam/wget-lua` | [`imrehg/archiveteam-arm-wget-lua`](https://hub.docker.com/repository/docker/imrehg/archiveteam-arm-wget-lua) (gnutls version only) |
| `atdr.meo.ws/archiveteam/grab-base` | [`imrehg/archiveteam-arm-grab-base`](https://hub.docker.com/repository/docker/imrehg/archiveteam-arm-grab-base) (gnutls version only) |

## Multiarch builds

Set things up as they are described in this [Building Multi-Arch Images ...](https://www.docker.com/blog/multi-arch-images/)
blogpost, basically:

```shell
docker buildx create --name mybuilder
docker buildx use mybuilder
docker buildx inspect --bootstrap
```
