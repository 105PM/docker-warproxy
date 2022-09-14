FROM ghcr.io/linuxserver/baseimage-ubuntu:focal AS base

COPY root/ /
ADD https://git.io/wgcf.sh /tmp

RUN \
    apt-get update && apt-get install -y \
    curl ca-certificates \
    iproute2 net-tools iptables \
    wireguard-tools openresolv  kmod \
    moreutils \
    python3 python3-pip --no-install-recommends && \
    bash /tmp/wgcf.sh && \
    pip3 install --no-warn-script-location pproxy[accelerated] toml && \
    echo "**** permissions ****" && \
    chmod a+x \
        /usr/local/bin/* \
        /etc/s6-overlay/scripts/* && \
    echo "**** cleanup ****" && \
    rm -rf \
      /var/lib/apt/lists/* \
      /tmp/* \
      /root/.cache

ENV \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    PYTHONUNBUFFERED=1 \
    TZ=Asia/Seoul \
    WARP_ENABLED=true \
    PROXY_ENABLED=true \
    PROXY_PORT=8008

EXPOSE ${PROXY_PORT}
VOLUME /wgcf
WORKDIR /wgcf

HEALTHCHECK --interval=30s --timeout=30s --start-period=1m \
    CMD /usr/local/bin/healthcheck || kill 1

ENTRYPOINT ["/init"]
