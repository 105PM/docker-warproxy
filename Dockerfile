FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy AS base

COPY root/ /

RUN \
    apt-get update && apt-get install -y \
    curl ca-certificates \
    iproute2 net-tools iptables \
    wireguard-tools openresolv  kmod \
    moreutils \
    python3 python3-pip --no-install-recommends && \
    curl -fsSL git.io/wgcf.sh | bash && mkdir -p /wgcf && \
    pip3 install --no-warn-script-location pproxy[accelerated] && \
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

HEALTHCHECK --interval=10m --timeout=30s --start-period=10s --retries=3 \
    CMD /usr/local/bin/healthcheck

ENTRYPOINT ["/init"]
