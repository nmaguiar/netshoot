FROM openaf/oaf:nightly as main

USER root
WORKDIR /root
COPY fetch_binaries.sh /tmp/fetch_binaries.sh

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
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
    wget \
    dhcping \
    drill \
    ethtool \
    file \
    fping \
    gzip \
    gcc \
    libc-dev\
    linux-headers\
    iftop \
    iotop \
    iperf \
    iperf3 \
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
    netcat-openbsd \
    net-snmp-tools \
    netcat-openbsd \
    nftables \
    ngrep \
    nmap \
    nmap-nping \
    nmap-scripts \
    nss_wrapper \
    openssl \
    py3-pip \
    py3-setuptools \
    scapy \
    socat \
    speedtest-cli \
    openssh \
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
    perl-net-ssleay\
    httpie

RUN /bin/sh /tmp/fetch_binaries.sh
RUN rm /tmp/fetch_binaries.sh

RUN mv /tmp/ctop /usr/local/bin/ctop
RUN mv /tmp/calicoctl /usr/local/bin/calicoctl
RUN mv /tmp/termshark /usr/local/bin/termshark

# OpenAF packages
RUN /openaf/opack install oJob-common\
  && /openaf/opack install S3\
  && /openaf/opack install Kube\
  && /openaf/opack install ElasticSearch\
  && /openaf/opack install AWS\
  && /openaf/ojob ojob.io/s3/getMC path=/usr/bin

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
COPY zshrc .zshrc
COPY motd motd

# Fix permissions for OpenShift and tshark
RUN chmod -R g=u /root
RUN chown root:root /usr/bin/dumpcap

# -------------------
FROM scratch as final

COPY --from=main / /
USER root
WORKDIR /root
ENV HOSTNAME netshoot

# Running ZSH
#CMD ["zsh"]
ENTRYPOINT ["/bin/zsh"]
