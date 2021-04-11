
REPO=https://github.com/ArchiveTeam/grab-base-df
PATCH=0001-Allow-arm-build-with-build-essentials-required-by-wh.patch
IMAGE=${IMAGE:-imrehg/archiveteam-arm-grab-base}

build_dir="$(mktemp -d /tmp/builder.XXXXXX)"
git clone "${REPO}" "${build_dir}"
cp "$PATCH" "${build_dir}"
pushd "${build_dir}"
git am ${PATCH}

docker build -t ${IMAGE} .

