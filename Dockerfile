FROM alpine:3.11.3

RUN set -ex \
    && echo "http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
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
    iproute2 \
    ipset \
    iptables \
    iptraf-ng \
    iputils \
    ipvsadm \
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
    py-crypto \
    python2 \
    python3 \
    scapy \
    socat \
    strace \
    tcpdump \
    tcptraceroute \
    util-linux \
    vim \
    tree \
    pstree \
    htop \
    coreutils

# apparmor issue #14140
RUN mv /usr/sbin/tcpdump /usr/bin/tcpdump

# Installing ctop - top-like container monitor
RUN wget https://github.com/bcicen/ctop/releases/download/v0.7.3/ctop-0.7.3-linux-amd64 -O /usr/local/bin/ctop && chmod +x /usr/local/bin/ctop

# Installing calicoctl
ARG CALICOCTL_VERSION=v3.8.6
RUN wget https://github.com/projectcalico/calicoctl/releases/download/${CALICOCTL_VERSION}/calicoctl-linux-amd64 -O calicoctl && chmod +x calicoctl && mv calicoctl /usr/local/bin

# Settings
COPY motd /etc/motd
COPY profile /etc/profile
COPY ./bin/httping.linux.x86_64 /usr/bin/httping
COPY ./bin/tcping.linux.x86_64 /usr/bin/tcping
RUN chmod +x /usr/bin/tcping && chmod +x /usr/bin/httping

CMD ["/bin/bash","-l"]
