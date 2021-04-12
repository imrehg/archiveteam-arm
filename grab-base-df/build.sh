#!/bin/bash

set -eux

REPO=https://github.com/ArchiveTeam/grab-base-df
PATCH=0001-Allow-arm-build-with-build-essentials-required-by-wh.patch
IMAGE=${IMAGE:-imrehg/archiveteam-arm-grab-base}
MULTIARCH=${MULTIARCH:-yes}
PLATFORM=${PLATFORM:-linux/arm64,linux/arm/v7,linux/arm/v6}

build_dir="./build"
git clone "${REPO}" "${build_dir}"
cp "$PATCH" "${build_dir}"
pushd "${build_dir}" || 1
patch -p1 < ${PATCH}

if [ "${MULTIARCH}" = "yes" ]; then
  docker buildx build --platform "${PLATFORM}" -t "${IMAGE}" --push .
else
  docker build -t "${IMAGE}" . && docker push "${IMAGE}"
fi

popd || exit 1
rm -rf "${build_dir}"

