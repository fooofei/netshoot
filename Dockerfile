###
FROM debian:stable-slim as fetcher
COPY build/fetch_binaries.sh /tmp/fetch_binaries.sh

RUN apt-get update && apt-get install -y \
  curl \
  wget

RUN chmod +x /tmp/fetch_binaries.sh && /tmp/fetch_binaries.sh

COPY ./scripts/shelldoor /usr/local/bin/shelldoor
COPY ./scripts/maxopenfiles /usr/local/bin/maxopenfiles

RUN chmod +x /usr/local/bin/shelldoor && \ 
 chmod +x /usr/local/bin/maxopenfiles

###
FROM golang as xping 
COPY ./scripts/build_ping.sh /tmp/build_ping.sh 
RUN chmod +x /tmp/build_ping.sh 
RUN /tmp/build_ping.sh

### github prebuild binarys not include aarch64, so we build it ourself
FROM golang as ethr 
RUN cd /tmp && git clone https://github.com/Microsoft/ethr.git && \
  cd ethr && go build -v -tags netgo -o /usr/local/bin/ethr .

### 
FROM alpine:3.13.1

RUN set -ex \
    && echo "http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && echo "http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
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
    httpie \
    iftop \
    iperf \
    iproute2 \
    ipset \
    iptables \ 
    iptraf-ng \
    iputils \
    ipvsadm \
    jq \
    libc6-compat \
    liboping \
    mtr \
    net-snmp-tools \
    netcat-openbsd \
    nftables \
    ngrep \
    nmap \
    nmap-nping \
    openssl \
    py3-crypto \
    scapy \
    socat \
    strace \
    tcpdump \
    tcptraceroute \
    tshark \
    util-linux \
    vim \
    websocat \
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
COPY --from=ethr /usr/local/bin/ethr /usr/local/bin/ethr
# Settings
COPY motd /etc/motd
COPY profile /etc/profile

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    sed -i "s/#PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config && \
    ssh-keygen -t dsa -P "" -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -t rsa -P "" -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -t ecdsa -P "" -f /etc/ssh/ssh_host_ecdsa_key && \
    ssh-keygen -t ed25519 -P "" -f /etc/ssh/ssh_host_ed25519_key && \
    mkdir /etc/dropbear && \ 
    echo "dropbear -RFEm -p 22" > /usr/local/bin/run_dropbear

SHELL ["/bin/bash"]
CMD ["/bin/bash","-l"]
