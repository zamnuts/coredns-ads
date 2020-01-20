FROM golang:1.13 AS build

LABEL autodelete=true

ARG COREDNS_VERSION=v1.6.6
ARG ADS_VERSION=v0.2.0

ENV \
  COREDNS_INSTALL_PATH=$GOPATH/src/github.com/coredns/coredns \
  ADS_INSTALL_PATH=$GOPATH/src/github.com/c-mueller/ads \
  GO111MODULE=on

# split into 2 RUNs for cross-platform compilation layer reuse
RUN \
  apt-get update &&  \
  apt-get -y install ca-certificates && \
  update-ca-certificates && \
  \
  git clone https://github.com/coredns/coredns $COREDNS_INSTALL_PATH && \
  git -C $COREDNS_INSTALL_PATH checkout tags/$COREDNS_VERSION && \
  \
  git clone https://github.com/c-mueller/ads $ADS_INSTALL_PATH && \
  git -C $ADS_INSTALL_PATH checkout tags/$ADS_VERSION && \
  \
  sed -i 's|hosts:hosts|ads:github.com/c-mueller/ads\nhosts:hosts|g' $COREDNS_INSTALL_PATH/plugin.cfg && \
  printf '\nreplace github.com/c-mueller/ads => %s\n' "$ADS_INSTALL_PATH" >> $COREDNS_INSTALL_PATH/go.mod && \
  ( \
    cd $COREDNS_INSTALL_PATH && \
    go generate && \
    go get -v -d ./... \
  )

ARG GOOS
ARG GOARCH
ARG GOARM

RUN \
  cd $COREDNS_INSTALL_PATH && \
  make BINARY="/coredns" SYSTEM="GOOS=$GOOS GOARCH=$GOARCH GOARM=$GOARM" CHECKS="" BUILDOPTS=""

###

FROM scratch AS distroless

COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /coredns /coredns

EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]
