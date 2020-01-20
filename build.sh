#!/usr/bin/env bash

# START: configure me
COREDNS_VERSION=v1.6.6
ADS_VERSION=v0.2.0
BUILD_TARGETS=( 'linux:amd64' 'linux:arm64' 'linux:arm:7' )
# END: configure me

set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

for target in "${BUILD_TARGETS[@]}"; do
  targetOs=$(printf '%s' "$target" | cut -f1 -d':')
  targetArch=$(printf '%s' "$target" | cut -f2 -d':')
  targetArmVersion=$(printf '%s' "$target" | cut -f3 -d':')

  docker build \
    -t "coredns-ads:$COREDNS_VERSION-$targetArch" \
    --build-arg "COREDNS_VERSION=$COREDNS_VERSION" \
    --build-arg "ADS_VERSION=$ADS_VERSION" \
    --build-arg "GOOS=$targetOs" \
    --build-arg "GOARCH=$targetArch" \
    --build-arg "GOARM=$targetArmVersion" \
    "$DIR"
done

docker rmi $(docker images -q -f 'dangling=true' -f 'label=autodelete=true')

# TODO add manifests for pushing
#docker manifest create coredns-ads:$COREDNS_VERSION \
#  coredns-ads:$COREDNS_VERSION-amd64 \
#  coredns-ads:$COREDNS_VERSION-arm64 \
#  coredns-ads:$COREDNS_VERSION-arm
#
#docker manifest inspect coredns-ads:$COREDNS_VERSION
