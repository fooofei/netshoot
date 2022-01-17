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

get_dust() {
    # e.g. "tag_name": "v0.7.5",
    VERSION=$(get_latest_release bootandy/dust)
    if [ "$ARCH" == "amd64" ]; then
      FILE_NAME="dust-${VERSION}-x86_64-unknown-linux-musl"
    else
      FILE_NAME="dust-${VERSION}-arm-unknown-linux-gnueabihf"
    fi
    # https://github.com/bootandy/dust/releases/download/v0.7.5/dust-v0.7.5-x86_64-unknown-linux-musl.tar.gz
    # https://github.com/bootandy/dust/releases/download/v0.7.5/dust-v0.7.5-arm-unknown-linux-gnueabihf.tar.gz
    LINK="https://github.com/bootandy/dust/releases/download/${VERSION}/${FILE_NAME}.tar.gz"
    get_file "${LINK}" /tmp/dust.tar.gz && \
    tar -zxvf /tmp/dust.tar.gz && \
    mv "${FILE_NAME}/dust" /tmp/dust && \
    chmod +x /tmp/dust
}

get_etcdctl() {
    # e.g. https://api.github.com/repos/etcd-io/etcd/releases/latest "tag_name": "v3.5.1",
    VERSION=$(get_latest_release etcd-io/etcd)
    # https://github.com/etcd-io/etcd/releases/download/v3.5.1/etcd-v3.5.1-linux-amd64.tar.gz
    FILE_NAME="etcd-${VERSION}-linux-${ARCH}"
    LINK="https://github.com/etcd-io/etcd/releases/download/${VERSION}/${FILE_NAME}.tar.gz"
    get_file "${LINK}" /tmp/etcdctl.tar.gz && \
    tar -zxvf /tmp/etcdctl.tar.gz && \
    mv "${FILE_NAME}/etcdctl" /tmp/etcdctl && \
    chmod +x /tmp/etcdctl
}

get_helm() {
    # e.g. https://api.github.com/repos/helm/helm/releases/latest "tag_name": "v3.7.2",
    VERSION=$(get_latest_release helm/helm)
    # https://get.helm.sh/helm-v3.7.2-linux-amd64.tar.gz
    FILE_NAME="helm-${VERSION}-linux-${ARCH}"
    UNZIP_FILE_NAME="linux-${ARCH}"
    LINK="https://get.helm.sh/${FILE_NAME}.tar.gz"
    get_file "${LINK}" /tmp/helm.tar.gz && \
    tar -zxvf /tmp/helm.tar.gz && \
    mv "${UNZIP_FILE_NAME}/helm" /tmp/helm && \
    chmod +x /tmp/helm
}

get_kubectl() {
    # https://storage.googleapis.com/kubernetes-release/release/stable.txt
    VERSION=$(curl --silent https://storage.googleapis.com/kubernetes-release/release/stable.txt)
    # https://dl.k8s.io/release/v1.22.3/bin/linux/amd64/kubectl
    LINK="https://dl.k8s.io/release/${VERSION}/bin/linux/${ARCH}/kubectl"
    get_file "${LINK}" /tmp/kubectl && \
    chmod +x /tmp/kubectl
}

get_ctop
get_calicoctl
get_termshark
get_miniserve
get_micro
get_dust
get_etcdctl
get_helm
get_kubectl
