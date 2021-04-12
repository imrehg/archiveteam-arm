#!/bin/bash

set -eux

REPO=https://github.com/ArchiveTeam/yahooanswers-grab
PATCH=0001-switch-base-image-to-arm-version.patch
IMAGE=${IMAGE:-imrehg/archiveteam-arm-yahooanswers-grab}
MULTIARCH=${MULTIARCH:-yes}
PLATFORM=${PLATFORM:-linux/arm64,linux/arm/v7,linux/arm/v6}

build_dir="./build"
git clone "${REPO}" "${build_dir}"
cp "${PATCH}" "${build_dir}"
pushd "${build_dir}" || exit 1
patch -p1 < "${PATCH}"

if [ "${MULTIARCH}" = "yes" ]; then
  docker buildx build --platform "${PLATFORM}" -t "${IMAGE}" --cache-from "${IMAGE}" --push .
else
  docker build -t "${IMAGE}" . && docker push "${IMAGE}"
fi

popd || exit 1
rm -rf "${build_dir}"
