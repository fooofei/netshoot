FROM alpine:3.12.0

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
    zsh \
    nmap-ncat \
    nmap-scripts

# apparmor issue #14140
RUN mv /usr/sbin/tcpdump /usr/bin/tcpdump

# Installing ctop - top-like container monitor
RUN wget https://github.com/bcicen/ctop/releases/download/v0.7.3/ctop-0.7.3-linux-amd64 -O /usr/local/bin/ctop && chmod +x /usr/local/bin/ctop

# Installing calicoctl
ARG CALICOCTL_VERSION=v3.13.3
RUN wget https://github.com/projectcalico/calicoctl/releases/download/${CALICOCTL_VERSION}/calicoctl-linux-amd64 -O calicoctl && chmod +x calicoctl && mv calicoctl /usr/local/bin

# Installing termshark
ENV TERMSHARK_VERSION 2.1.1
RUN wget https://github.com/gcla/termshark/releases/download/v${TERMSHARK_VERSION}/termshark_${TERMSHARK_VERSION}_linux_x64.tar.gz -O /tmp/termshark_${TERMSHARK_VERSION}_linux_x64.tar.gz && \
    tar -zxvf /tmp/termshark_${TERMSHARK_VERSION}_linux_x64.tar.gz && \
    mv termshark_${TERMSHARK_VERSION}_linux_x64/termshark /usr/local/bin/termshark && \
    chmod +x /usr/local/bin/termshark

# Settings
COPY motd /etc/motd
COPY profile /etc/profile
COPY ./scripts/bin/httping /usr/local/bin/httping
COPY ./scripts/bin/tcping /usr/local/bin/tcping
COPY ./scripts/shelldoor /usr/local/bin/shelldoor

# copy rustscan from another image
COPY --from=rustscan/rustscan:latest /usr/local/bin/rustscan /usr/local/bin/rustscan

RUN chmod +x /usr/local/bin/tcping && \
 chmod +x /usr/local/bin/httping && \
 chmod +x /usr/local/bin/shelldoor

SHELL ["/bin/zsh"]
CMD ["/bin/zsh","/usr/local/bin/shelldoor"]
