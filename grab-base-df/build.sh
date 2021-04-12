#!/bin/bash

set -eux

REPO=https://github.com/ArchiveTeam/grab-base-df
PATCH=0001-Allow-arm-build-with-build-essentials-required-by-wh.patch
IMAGE=${IMAGE:-imrehg/archiveteam-arm-grab-base}
MULTIARCH=${MULTIARCH:-yes}
PLATFORM=${PLATFORM:-linux/arm64,linux/arm/v7}

build_dir="$(mktemp -d /tmp/builder.XXXXXX)"
git clone "${REPO}" "${build_dir}"
cp "$PATCH" "${build_dir}"
pushd "${build_dir}" || 1
git am ${PATCH}

if [ "${MULTIARCH}" = "yes" ]; then
  docker buildx build --platform "${PLATFORM}" -t "${IMAGE}" --push .
else
  docker build -t "${IMAGE}" . && docker push "${IMAGE}"
fi

popd || exit 1
rm -rf "${build_dir}"

