
REPO=https://github.com/ArchiveTeam/yahooanswers-grab
PATCH=0001-switch-base-image-to-arm-version.patch
IMAGE=${IMAGE:-imrehg/archiveteam-arm-yahooanswers-grab}

build_dir="$(mktemp -d /tmp/yahooanswers-grab.XXXXXX)"
git clone "${REPO}" "${build_dir}"
cp "${PATCH}" "${build_dir}"
pushd "${build_dir}"
git am "${PATCH}"

docker build -t ${IMAGE} .

popd
rm -rf "${build_dir}"
