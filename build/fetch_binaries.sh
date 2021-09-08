#!/usr/bin/env bash
set -euox pipefail

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}


ARCH=$(uname -m)
case $ARCH in
    x86_64)
        ARCH=amd64
        ;;
    aarch64)
        ARCH=arm64
        ;;
esac

get_file() {
  echo "get file \"$2\" from $1"
  curl "$1" -L -o "$2"
  echo "md5sum $(md5sum $2)"
  echo "sha256sum $(sha256sum $2)"
}

get_ctop() {
  VERSION=$(get_latest_release bcicen/ctop | sed -e 's/^v//')
  LINK="https://github.com/bcicen/ctop/releases/download/${VERSION}/ctop-${VERSION}-linux-${ARCH}"
  # we cannot download with wget, we will receive http status 302
  # we need redirect to second url to download file
  get_file "$LINK" /tmp/ctop && chmod +x /tmp/ctop
}

get_calicoctl() {
  VERSION=$(get_latest_release projectcalico/calicoctl)
  LINK="https://github.com/projectcalico/calicoctl/releases/download/${VERSION}/calicoctl-linux-${ARCH}"
  get_file "$LINK"  /tmp/calicoctl && chmod +x /tmp/calicoctl
}

get_termshark() {
  case "$ARCH" in
    "arm"*)
      echo "echo termshark does not yet support arm" > /tmp/termshark && chmod +x /tmp/termshark
      ;;
    *)
      VERSION=$(get_latest_release gcla/termshark | sed -e 's/^v//')
      if [ "$ARCH" == "amd64" ]; then
        TERM_ARCH=x64
      else
        TERM_ARCH="$ARCH"
      fi
      LINK="https://github.com/gcla/termshark/releases/download/v${VERSION}/termshark_${VERSION}_linux_${TERM_ARCH}.tar.gz"
      get_file "$LINK" /tmp/termshark.tar.gz && \
      tar -zxvf /tmp/termshark.tar.gz && \
      mv "termshark_${VERSION}_linux_${TERM_ARCH}/termshark" /tmp/termshark && \
      chmod +x /tmp/termshark
      ;;
  esac
}

get_miniserve() {
    VERSION=$(get_latest_release svenstaro/miniserve)
    if [ "$ARCH" == "amd64" ]; then
      MINISERVE_ARCH="x86_64-unknown-linux-musl"
    else
      MINISERVE_ARCH="aarch64-unknown-linux-musl"
    fi
    LINK="https://github.com/svenstaro/miniserve/releases/download/${VERSION}/miniserve-${VERSION}-${MINISERVE_ARCH}"
    get_file "${LINK}" /tmp/miniserve && chmod +x /tmp/miniserve
}

get_micro() {
    VERSION=$(get_latest_release zyedidia/micro | sed -e 's/^v//')
    if [ "$ARCH" == "amd64" ]; then
      MICRO_ARCH="linux64-static"
    else
      MICRO_ARCH="linux-$ARCH"
    fi
    LINK="https://github.com/zyedidia/micro/releases/download/v${VERSION}/micro-${VERSION}-${MICRO_ARCH}.tar.gz"
    get_file "${LINK}" /tmp/micro.tar.gz && \
    tar -zxvf /tmp/micro.tar.gz && \
    mv "micro-${VERSION}/micro" /tmp/micro && \
    chmod +x /tmp/miniserve
}

get_ctop
get_calicoctl
get_termshark
get_miniserve
get_micro
