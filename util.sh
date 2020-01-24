#!/usr/bin/env bash

#
# core-ads Bash Script utity file
#



#######################################
# Get latest release version string of GitHub repository
# Globals:
#   None
# Arguments:
#   The quoted and slash sepparated tuple of <GitHub User> and <repository>
#   Example: "coredns/coredns"
# Returns:
#   The version string
#######################################
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

#######################################
# Returns "true" if build uses the latest coredns and ads code
# Globals:
#   LATEST_COREDNS_VERSION
#   LATEST_ADS_VERSION
#   COREDNS_VERSION
#   ADS_VERSION
# Arguments:
#   None
# Returns:
#   "true" if build uses the latest coredns and ads code, else "false"
#######################################
is_latest() {
  if [ "${LATEST_COREDNS_VERSION}" = "${COREDNS_VERSION}" ] && \
     [ "${LATEST_ADS_VERSION}" = "${ADS_VERSION}" ]; then
    echo "true"
  else
    echo "false"
  fi
}

#######################################
# Print greeting and config
# Globals:
#   LATEST_COREDNS_VERSION
#   LATEST_ADS_VERSION
#   COREDNS_VERSION
#   ADS_VERSION
#   COMPRESS
#   EXTRACT_BINARY
#   BUILD_DIR
# Arguments:
#   None
# Returns:
#   None
#######################################
info() {
cat << EOF
build.sh $0 -- coredns with ad-blocking builder script

Configuration environment variables set:
  COREDNS_VERSION="${COREDNS_VERSION}"
  ADS_VERSION="${ADS_VERSION}"
  BUILD_TARGETS="${BUILD_TARGETS}"
  COMPRESS="${COMPRESS}"
  EXTRACT_BINARY="${EXTRACT_BINARY}"
  BUILD_DIR="${BUILD_DIR}"

More information about the available configuration can be found here:
  https://github.com/zamnuts/coredns-ads
EOF
}

#
# Global Internal Variables Setup
#
readonly LATEST_COREDNS_VERSION=$( get_latest_release "coredns/coredns" )
readonly LATEST_ADS_VERSION=$( get_latest_release "c-mueller/ads" )
readonly DEFAULT_BUILD_TARGETS=( 'linux:amd64' 'linux:arm64' 'linux:arm:7' )
