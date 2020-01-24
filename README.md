# CoreDNS with c-mueller/ads Plugin

This project builds the `ads` plugin into CoreDNS
using the specified versions within `build.sh`.

It creates OCI images for multiple platforms using stable and pinned
source versions.

The entire build process happens within the `Dockerfile`
(docker build runtime), and cross-platform compilation is natively
supported in golang, which means this project can be built on just about
any platform and target any other platform.

The resulting images are distroless (`FROM scratch`), so they're quite
small (30-40MB range).

## Building
Simply run `./build.sh`.
Tags are automatic.
Does not push.
Only a single CoreDNS and ads version can be built at once;

The versions of CoreDNS and c-mueller/ads can be changed by updating
`COREDNS_VERSION` and `ADS_VERSION` variables within `build.sh`.
Additionally, the platform targets can be changed by updating
`BUILD_TARGETS` using the format `os:arch[:arm-version]` which maps to
`GOOS:GOARCH:GOARM` respectively, e.g. `linux:arm:7` or `linux:amd64`.
Supporting platform version combinations are documented at golang's
[GoArm](https://github.com/golang/go/wiki/GoArm) wiki page, and
asukakenji's
[GOOS and GOARCH](https://gist.github.com/asukakenji/f15ba7e588ac42795f421b48b8aede63)
gist markdown.


### Parameters
* If `EXTRACT_BINARY` is set to `true` the binaries will be extracted from the docker images saved in a new subdirectory called `build`.

* If `COMPRESS` is set to `true` then the `coredns` binary will be attempted to be compressed with `upx`.
    > NOTE: This has *not* been tested with ARM based binaries, and thus has been disabled by default.


## See Also
 - https://github.com/c-mueller/ads
 - https://github.com/coredns/coredns

## TODO
 - V2 repository API manifest
 - Multi-version/multi-platform matrix builds