#!/bin/bash

set -eux

REPO=https://github.com/ArchiveTeam/yahooanswers-grab
PATCH=0001-switch-base-image-to-arm-version.patch
IMAGE=${IMAGE:-imrehg/archiveteam-arm-yahooanswers-grab}
TAG=${TAG:-latest}
MULTIARCH=${MULTIARCH:-yes}
PLATFORM=${PLATFORM:-linux/arm64,linux/arm/v7,linux/arm/v6}

build_dir="./build"
git clone "${REPO}" "${build_dir}"
cp "${PATCH}" "${build_dir}"
pushd "${build_dir}" || exit 1
patch -p1 < "${PATCH}"

COMMIT_ID=$(git rev-parse HEAD)

IMAGE_TAGGED="${IMAGE}:${TAG}"
IMAGE_SHA="${IMAGE}:${COMMIT_ID}"

if [ "${MULTIARCH}" = "yes" ]; then
  docker buildx build \
    --platform "${PLATFORM}" \
    --tag "${IMAGE_TAGGED}" \
    --tag "${IMAGE_SHA}" \
    --push .
else
  docker build \
    --tag "${IMAGE_TAGGED}" \
    --tag "${IMAGE_SHA}" \
    . \
  && docker push "${IMAGE_TAGGED}" \
  && docker push "${IMAGE_SHA}"
fi

popd || exit 1
rm -rf "${build_dir}"
