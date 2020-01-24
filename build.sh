#!/usr/bin/env bash
#
# Build coredns docker images, and optionally extract built binaries
#

# Initial Setup
readonly DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. "${DIR}/util.sh" --source-only

# START: configure me
readonly COREDNS_VERSION=${COREDNS_VERSION-${LATEST_COREDNS_VERSION}}
readonly ADS_VERSION=${ADS_VERSION-${LATEST_ADS_VERSION}}
# BUILD_TARGETS=${BUILD_TARGETS-${DEFAULT_BUILD_TARGETS[*]}}
BUILD_TARGETS=( 'linux:amd64' 'linux:arm64' 'linux:arm:7' )

readonly COMPRESS=${COMPRESS-false} # Might not work for ARM7 
readonly EXTRACT_BINARY=${EXTRACT_BINARY-true}
readonly BUILD_DIR=${BUILD_DIR-"${DIR}/build"}

# TODO(platten): add latest tag functionality after manifests are built
# readonly ADD_LATEST_TAG=${ADD_LATEST_TAG-$( is_latest )}

# END: configure me
set -e

# Print info
info

# Create build sub-directory if EXTRACT_BINARY is true and does not exist
if [ "${EXTRACT_BINARY}" = true ]; then
  [ -d "${BUILD_DIR}" ] || mkdir "${BUILD_DIR}"
fi

for target in "${BUILD_TARGETS[@]}"; do
  target_os=$(printf '%s' "${target}" | cut -f1 -d':')
  target_arch=$(printf '%s' "${target}" | cut -f2 -d':')
  target_arm_version=$(printf '%s' "${target}" | cut -f3 -d':')
  image_name="coredns-ads:${COREDNS_VERSION}-${target_arch}"

  echo "Building Image: ${image_name}"
  docker build \
    -t "${image_name}" \
    --build-arg "COREDNS_VERSION=${COREDNS_VERSION}" \
    --build-arg "ADS_VERSION=${ADS_VERSION}" \
    --build-arg "GOOS=${target_os}" \
    --build-arg "GOARCH=${target_arch}" \
    --build-arg "GOARM=${target_arm_version}" \
    --build-arg "COMPRESS=${COMPRESS}" \
    "${DIR}"

  if [ "${EXTRACT_BINARY}" = "true" ]; then
    binary_name="coredns-${COREDNS_VERSION}-${target_arch}"
    target_path="${DIR}/build/${binary_name}"

    echo "Extracting coredns binary for ${target_arch} to ${target_path}"
    container_id=$(docker create "${image_name}")
    docker cp "${container_id}:/coredns" "${target_path}"
    docker rm -v "${container_id}"
  fi
done

echo "Cleaning up dangling and intermediate build containers"
docker rmi $(docker images -q -f 'dangling=true' -f 'label=autodelete=true')

# TODO(zamnuts): Add manifests for pushing
#docker manifest create coredns-ads:$COREDNS_VERSION \
#  coredns-ads:$COREDNS_VERSION-amd64 \
#  coredns-ads:$COREDNS_VERSION-arm64 \
#  coredns-ads:$COREDNS_VERSION-arm
#
#docker manifest inspect coredns-ads:$COREDNS_VERSION
