FROM debian:stable-slim as fetcher
COPY build/fetch_binaries.sh /tmp/fetch_binaries.sh

RUN apt-get update && apt-get install -y \
  curl \
  wget

RUN bash /tmp/fetch_binaries.sh

### 自定义二进制
###
COPY ./scripts/shelldoor /usr/local/bin/shelldoor
COPY ./scripts/maxopenfiles /usr/local/bin/maxopenfiles
RUN chmod +x /usr/local/bin/shelldoor && \ 
 chmod +x /usr/local/bin/maxopenfiles

###
FROM golang as xping 
COPY ./scripts/build_ping.sh /tmp/build_ping.sh 
RUN go version && \
  chmod +x /tmp/build_ping.sh && \
  /tmp/build_ping.sh

### github prebuild binarys not include aarch64, so we build it ourself
# golang:1.17.10 已经不适用
# ethr 项目并没有把所有需要的依赖都在 go.mod 声明，所以需要 go mod tidy
FROM golang as ethr 
RUN go version && \
  cd /tmp && \
  git clone https://github.com/Microsoft/ethr.git && \
  cd ethr && \
  go mod tidy && \
  go build -v -tags netgo -o /usr/local/bin/ethr .

### 
FROM golang as topic 
COPY ./scripts/build_topic.sh /tmp/build_topic.sh 
RUN go version && \
  chmod +x /tmp/build_topic.sh && \
  /tmp/build_topic.sh

### 
FROM golang as httpstat 
RUN go version && \
  cd /tmp && \
  git clone https://github.com/davecheney/httpstat.git && \
  cd httpstat && \
  go build -v -tags netgo -o /usr/local/bin/httpstat .

### 
FROM golang as rinetd
COPY ./scripts/build_rinetd.sh /tmp/build_rinetd.sh 
RUN go version && \
  chmod +x /tmp/build_rinetd.sh && \
  /tmp/build_rinetd.sh

### 
FROM alpine:3.18.3

RUN set -ex \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk add --no-cache \
    apache2-utils \
    bash \
    bind-tools \
    bird \
    bridge-utils \
    busybox-extras \
    conntrack-tools \
    curl \
    dhcping \
    drill \
    ethtool \
    file \
    fping \
    iftop \
    iperf \
    iperf3 \
    iproute2 \
    ipset \
    iptables \
    iptraf-ng \
    iputils \
    ipvsadm \
    httpie \
    jq \
    libc6-compat \
    liboping \
    ltrace \
    mtr \
    net-snmp-tools \
    netcat-openbsd \
    nftables \
    ngrep \
    nmap \
    nmap-nping \
    nmap-scripts \
    openssl \
    py3-pip \
    py3-setuptools \
    scapy \
    socat \
    speedtest-cli \
    openssh \
    oh-my-zsh \
    strace \
    tcpdump \
    tcptraceroute \
    tshark \
    util-linux \
    vim \
    git \
    zsh \
    websocat \
    swaks \
    perl-crypt-ssleay \
    perl-net-ssleay \
    aria2 \
    tree \
    pstree \
    htop \
    coreutils \
    python3 \
    nmap-ncat \
    nmap-scripts \
    axel \
    openssh \
    openssh-sftp-server \
    tzdata \
    dropbear

# Installing ctop - top-like container monitor
COPY --from=fetcher /tmp/ctop /usr/local/bin/ctop

# Installing calicoctl
COPY --from=fetcher /tmp/calicoctl /usr/local/bin/calicoctl

# Installing termshark
COPY --from=fetcher /tmp/termshark /usr/local/bin/termshark

COPY --from=xping /usr/local/bin/httping /usr/local/bin/httping
COPY --from=xping /usr/local/bin/tcping /usr/local/bin/tcping
COPY --from=fetcher /usr/local/bin/shelldoor /usr/local/bin/shelldoor
COPY --from=fetcher /usr/local/bin/maxopenfiles /usr/local/bin/maxopenfiles
COPY --from=fetcher /tmp/miniserve /usr/local/bin/miniserve
COPY --from=fetcher /tmp/micro /usr/local/bin/micro
COPY --from=fetcher /tmp/dust /usr/local/bin/dust
COPY --from=fetcher /tmp/etcdctl /usr/local/bin/etcdctl
COPY --from=fetcher /tmp/helm /usr/local/bin/helm
COPY --from=fetcher /tmp/kubectl /usr/local/bin/kubectl
COPY --from=fetcher /tmp/nerdctl /usr/local/bin/nerdctl
COPY --from=fetcher /tmp/fd /usr/local/bin/fd
COPY --from=fetcher /tmp/gost /usr/local/bin/gost
COPY --from=fetcher /tmp/duf /usr/local/bin/duf
COPY --from=fetcher /tmp/file-server-dufs/dufs /usr/local/bin/dufs
COPY --from=fetcher /tmp/upt /usr/local/bin/upt
COPY --from=fetcher /tmp/curl-xh /usr/local/bin/curl-xh
COPY --from=fetcher /tmp/step /usr/local/bin/step
COPY --from=fetcher /tmp/sx /usr/local/bin/sx
COPY --from=ethr /usr/local/bin/ethr /usr/local/bin/ethr
COPY --from=topic /usr/local/bin/topic /usr/local/bin/topic
COPY --from=httpstat /usr/local/bin/httpstat /usr/local/bin/httpstat
COPY --from=rinetd /usr/local/bin/rinetd /usr/local/bin/rinetd

# copy rustscan from another image
COPY --from=rustscan/rustscan:latest /usr/local/bin/rustscan /usr/local/bin/rustscan

# Setting User and Home
USER root
WORKDIR /root
ENV HOSTNAME netshoot

# Fix permissions for OpenShift and tshark
RUN chmod -R g=u /root
RUN chown root:root /usr/bin/dumpcap

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    sed -i "s/#PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config && \
    ssh-keygen -t dsa -P "" -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -t rsa -P "" -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -t ecdsa -P "" -f /etc/ssh/ssh_host_ecdsa_key && \
    ssh-keygen -t ed25519 -P "" -f /etc/ssh/ssh_host_ed25519_key && \
    mkdir /etc/dropbear && \ 
    echo "dropbear -RFEm -p 22" > /usr/local/bin/run_dropbear && chmod +x /usr/local/bin/run_dropbear

# Running ZSH
CMD ["zsh"]
