#!/bin/bash

set -eux


while getopts r:i:t:p:a: option; do
  case "${option}" in
    r) REPO=${OPTARG};;
    i) IMAGE=${OPTARG};;
    t) TAG=${OPTARG};;
    p) PLATFORM=${OPTARG};;
    a) PATCH=${OPTARG};;
  esac
done

# PLATFORM=${PLATFORM:-linux/arm64,linux/arm/v7,linux/arm/v6}
PLATFORM=${PLATFORM:-linux/arm64}
PATCH=${PATCH:-}

build_dir="./build"
if [ -d "${build_dir}" ]; then
  echo "Cleaning up left-over build directoru: ${build_dir}"
  rm -rf "${build_dir}"
fi
git clone "${REPO}" "${build_dir}"

pushd "${build_dir}" || exit 1

if [ "${PATCH}" != "" ]; then
  echo "Applying patch..."
  patch -p1 < $(dirname $0)/${PATCH}
fi

COMMIT_ID=$(git rev-parse HEAD)

IMAGE_TAGGED="${IMAGE}:${TAG}"
IMAGE_SHA="${IMAGE}:${COMMIT_ID}"

docker buildx build --platform "${PLATFORM}" -t "${IMAGE}"  --push .

if [ "${PLATFORM}" != "" ]; then
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
