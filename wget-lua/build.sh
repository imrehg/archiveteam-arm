#!/bin/bash

set -eux

REPO=https://github.com/ArchiveTeam/wget-lua
IMAGE=${IMAGE:-imrehg/archiveteam-arm-wget-lua:v1.20.3-at-openssl}
MULTIARCH=${MULTIARCH:-yes}
PLATFORM=${PLATFORM:-linux/arm64,linux/arm/v7}

build_dir="$(mktemp -d /tmp/wget-lua.XXXXXX)"
git clone "${REPO}" "${build_dir}"
pushd "${build_dir}" || exit 1

if [ "${MULTIARCH}" = "yes" ]; then
  docker buildx build --platform "${PLATFORM}" -t "${IMAGE}" --push .
else
  docker build -t "${IMAGE}" . && docker push "${IMAGE}"
fi

popd || exit 1
rm -rf "${build_dir}"
