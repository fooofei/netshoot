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
    nmap-scripts \
    axel

# apparmor issue #14140
RUN mv /usr/sbin/tcpdump /usr/bin/tcpdump

# Installing ctop - top-like container monitor
RUN curl -k -L https://github.com/bcicen/ctop/releases/download/v0.7.3/ctop-0.7.3-linux-arm64 -o /usr/local/bin/ctop && chmod +x /usr/local/bin/ctop

# Installing calicoctl
ARG CALICOCTL_VERSION=v3.13.3
RUN curl -k -L https://github.com/projectcalico/calicoctl/releases/download/${CALICOCTL_VERSION}/calicoctl-linux-arm64 -o calicoctl && chmod +x calicoctl && mv calicoctl /usr/local/bin

# Installing termshark
ENV TERMSHARK_VERSION 2.1.1
RUN curl -k -L https://github.com/gcla/termshark/releases/download/v${TERMSHARK_VERSION}/termshark_${TERMSHARK_VERSION}_linux_armv6.tar.gz -o /tmp/termshark_${TERMSHARK_VERSION}_linux_armv6.tar.gz && \
    tar -zxvf /tmp/termshark_${TERMSHARK_VERSION}_linux_armv6.tar.gz && \
    mv termshark_${TERMSHARK_VERSION}_linux_armv6/termshark /usr/local/bin/termshark && \
    chmod +x /usr/local/bin/termshark && rm -rf /tmp/* &&  rm -rf termshark_${TERMSHARK_VERSION}_linux_armv6/

# Settings
COPY motd /etc/motd
COPY profile /etc/profile
COPY ./scripts/bin/httping /usr/local/bin/httping
COPY ./scripts/bin/tcping /usr/local/bin/tcping
COPY ./scripts/shelldoor /usr/local/bin/shelldoor
COPY ./scripts/maxopenfiles /usr/local/bin/maxopenfiles

# copy rustscan from another image
# COPY --from=rustscan/rustscan:latest /usr/local/bin/rustscan /usr/local/bin/rustscan

RUN chmod +x /usr/local/bin/tcping && \
 chmod +x /usr/local/bin/httping && \
 chmod +x /usr/local/bin/shelldoor && \ 
 chmod +x /usr/local/bin/maxopenfiles

SHELL ["/bin/zsh"]
CMD ["/bin/zsh","-l"]
