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

# Top-like interface for container metrics
get_ctop() {
  VERSION=$(get_latest_release bcicen/ctop | sed -e 's/^v//')
  LINK="https://github.com/bcicen/ctop/releases/download/v${VERSION}/ctop-${VERSION}-linux-${ARCH}"
  # we cannot download with wget, we will receive http status 302
  # we need redirect to second url to download file
  get_file "$LINK" /tmp/ctop && chmod +x /tmp/ctop
}

# Cloud native networking and network security
get_calicoctl() {
  VERSION=$(get_latest_release projectcalico/calico)
  LINK="https://github.com/projectcalico/calico/releases/download/${VERSION}/calicoctl-linux-${ARCH}"
  get_file "$LINK"  /tmp/calicoctl && chmod +x /tmp/calicoctl
}

# A terminal UI for tshark, inspired by Wireshark
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

get_nerdctl() {
    # e.g. https://api.github.com/repos/containerd/nerdctl/releases/latest "tag_name": "v0.16.0",
    VERSION=$(get_latest_release containerd/nerdctl | sed -e 's/^v//')
    # https://github.com/containerd/nerdctl/releases/download/v0.16.0/nerdctl-0.16.0-linux-arm64.tar.gz
    FILE_NAME="nerdctl-${VERSION}-linux-${ARCH}"
    UNZIP_FILE_NAME="linux-${ARCH}"
    LINK="https://github.com/containerd/nerdctl/releases/download/v${VERSION}/${FILE_NAME}.tar.gz"
    get_file "${LINK}" /tmp/nerdctl.tar.gz && \
    tar -zxvf /tmp/nerdctl.tar.gz && \
    mv nerdctl /tmp/nerdctl && \
    chmod +x /tmp/nerdctl
}

get_fd_files() {
    # e.g. https://api.github.com/repos/sharkdp/fd/releases/latest "tag_name": "v8.3.1",
    VERSION=$(get_latest_release sharkdp/fd)
    # https://github.com/sharkdp/fd/releases/download/v8.3.1/fd-v8.3.1-x86_64-unknown-linux-musl.tar.gz
    # https://github.com/sharkdp/fd/releases/download/v8.3.1/fd-v8.3.1-arm-unknown-linux-musleabihf.tar.gz
    case "${ARCH}" in
      arm64)
        FILE_NAME="fd-${VERSION}-arm-unknown-linux-musleabihf"
        ;;
      amd64)
        FILE_NAME="fd-${VERSION}-x86_64-unknown-linux-musl"
        ;;
    esac
    LINK="https://github.com/sharkdp/fd/releases/download/${VERSION}/${FILE_NAME}.tar.gz"
    get_file "${LINK}" /tmp/fdfiles.tar.gz && \
    tar -zxvf /tmp/fdfiles.tar.gz && \
    mv ${FILE_NAME}/fd /tmp/fd && \
    chmod +x /tmp/fd
}

get_gost() {
  # e.g. https://api.github.com/repos/ginuerzh/gost/releases/latest "tag_name":  "v2.11.1",
  VERSION=$(get_latest_release ginuerzh/gost | sed -e 's/^v//')
  # https://github.com/ginuerzh/gost/releases/download/v2.11.1/gost-linux-amd64-2.11.1.gz
  # https://github.com/ginuerzh/gost/releases/download/v2.11.1/gost-linux-armv8-2.11.1.gz
  case "${ARCH}" in
    arm64)
      FILE_NAME="gost-linux-armv8-${VERSION}"
      ;;
    amd64)
      FILE_NAME="gost-linux-amd64-${VERSION}"
      ;;
  esac
  LINK="https://github.com/ginuerzh/gost/releases/download/v${VERSION}/${FILE_NAME}.gz"
  get_file "${LINK}" /tmp/gostfiles.tar.gz && \
  gunzip -c /tmp/gostfiles.tar.gz > /tmp/gost && \
  chmod +x /tmp/gost
}

# Disk Usage/Free Utility - a better 'df' alternative
get_df_duf() {
  # e.g. https://api.github.com/repos/muesli/duf/releases/latest "tag_name": "v0.8.1"
  VERSION=$(get_latest_release muesli/duf | sed -e 's/^v//')
  # https://github.com/muesli/duf/releases/download/v0.8.1/duf_0.8.1_linux_x86_64.tar.gz
  case "${ARCH}" in
    arm64)
      FILE_NAME="duf_${VERSION}_linux_arm64"
      ;;
    amd64)
      FILE_NAME="duf_${VERSION}_linux_x86_64"
      ;;
  esac
  LINK="https://github.com/muesli/duf/releases/download/v${VERSION}/${FILE_NAME}.tar.gz"
  get_file "${LINK}" /tmp/dfduf.tar.gz && \
  mkdir -p /tmp/dfduf && \
  tar -xf /tmp/dfduf.tar.gz -C /tmp/dfduf && \
  chmod +x /tmp/dfduf/duf && \
  mv /tmp/dfduf/duf /tmp/duf
}

# Duf is a simple file server. Support static serve, search, upload, delete...
get_file_server_duf() {
  # e.g. https://api.github.com/repos/sigoden/duf/releases/latest   "name": "v0.7.0"
  VERSION=$(get_latest_release sigoden/duf)
  # https://github.com/sigoden/duf/releases/download/v0.7.0/duf-v0.7.0-x86_64-unknown-linux-musl.tar.gz
  # https://github.com/sigoden/duf/releases/download/v0.7.0/duf-v0.7.0-aarch64-unknown-linux-musl.tar.gz
  case "${ARCH}" in
    arm64)
      FILE_NAME="duf-${VERSION}-aarch64"
      ;;
    amd64)
      FILE_NAME="duf-${VERSION}-x86_64"
      ;;
  esac
  LINK="https://github.com/sigoden/duf/releases/download/${VERSION}/${FILE_NAME}-unknown-linux-musl.tar.gz"
  get_file "${LINK}" /tmp/file-server-duf.tar.gz && \
  mkdir -p /tmp/file-server-duf && \
  tar -xf /tmp/file-server-duf.tar.gz -C /tmp/file-server-duf && \
  chmod +x /tmp/file-server-duf/duf
}

# Universal Package-management Tool for Windows, macOS and Linux.
get_pmt_upt() {
  # e.g. https://api.github.com/repos/sigoden/upt/releases/latest   "tag_name": "v0.7.0",
  VERSION=$(get_latest_release sigoden/upt)
  # https://github.com/sigoden/upt/releases/download/v0.3.0/upt-x86_64-unknown-linux-musl
  LINK="https://github.com/sigoden/upt/releases/download/${VERSION}/upt-x86_64-unknown-linux-musl"
  get_file "${LINK}" /tmp/upt && \
  chmod +x /tmp/upt
}

# Friendly and fast tool for sending HTTP requests
get_curl_xh() {
  # e.g. https://api.github.com/repos/ducaale/xh/releases/latest     "tag_name": "v0.16.1"
  VERSION=$(get_latest_release ducaale/xh)
  # https://github.com/ducaale/xh/releases/download/v0.16.1/xh-v0.16.1-x86_64-unknown-linux-musl.tar.gz
  LINK="https://github.com/ducaale/xh/releases/download/${VERSION}/xh-${VERSION}-x86_64-unknown-linux-musl.tar.gz"
  get_file "${LINK}" /tmp/curl-xh.tar.gz && \
  tar -xf /tmp/curl-xh.tar.gz -C /tmp/curl-xh-dir && \
  mv /tmp/curl-xh-dir/xh-${VERSION}-x86_64-unknown-linux-musl/xh /tmp/curl-xh && \
  chmod +x /tmp/curl-xh
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
get_nerdctl
get_fd_files
get_gost
get_df_duf
get_file_server_duf
get_pmt_upt
get_curl_xh
