#!/usr/bin/env bash

# START: configure me
COREDNS_VERSION=${COREDNS_VERSION-v1.6.6}
ADS_VERSION=${ADS_VERSION-v0.2.0}
BUILD_TARGETS=( 'linux:amd64' 'linux:arm64' 'linux:arm:7' )
COMPRESS=${COMPRESS-false} # Might not work for arm7 
EXTRACT_BINARY=${EXTRACT_BINARY-true}
# END: configure me

set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BUILD_DIR="${DIR}/build"

if [ "${EXTRACT_BINARY}" = true ]; then
  [ -d "${BUILD_DIR}" ] || mkdir "${BUILD_DIR}"
fi

for target in "${BUILD_TARGETS[@]}"; do
  targetOs=$(printf '%s' "${target}" | cut -f1 -d':')
  targetArch=$(printf '%s' "${target}" | cut -f2 -d':')
  targetArmVersion=$(printf '%s' "${target}" | cut -f3 -d':')

  imageName="coredns-ads:${COREDNS_VERSION}-${targetArch}"
  echo "Building Image: ${imageName}"
  docker build \
    -t "${imageName}" \
    --build-arg "COREDNS_VERSION=${COREDNS_VERSION}" \
    --build-arg "ADS_VERSION=${ADS_VERSION}" \
    --build-arg "GOOS=${targetOs}" \
    --build-arg "GOARCH=${targetArch}" \
    --build-arg "GOARM=${targetArmVersion}" \
    --build-arg "COMPRESS=${COMPRESS}" \
    "$DIR"

  if [ "${EXTRACT_BINARY}" = true ]; then
    binaryName="coredns-${COREDNS_VERSION}-${targetArch}"
    containerId=$(docker create "${imageName}")
    docker cp "${containerId}:/coredns" "${DIR}/build/${binaryName}"
    docker rm -v "${containerId}"
  fi
done

docker rmi "$(docker images -q -f 'dangling=true' -f 'label=autodelete=true')"

# TODO add manifests for pushing
#docker manifest create coredns-ads:$COREDNS_VERSION \
#  coredns-ads:$COREDNS_VERSION-amd64 \
#  coredns-ads:$COREDNS_VERSION-arm64 \
#  coredns-ads:$COREDNS_VERSION-arm
#
#docker manifest inspect coredns-ads:$COREDNS_VERSION
