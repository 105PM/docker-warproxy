FROM golang:1.18 as build
RUN \
    echo "**** build wireproxy ****" && \
    git clone https://github.com/octeep/wireproxy /tmp/wireproxy && \
    cd /tmp/wireproxy && \
    CGO_ENABLED=0 go build ./cmd/wireproxy

FROM ghcr.io/linuxserver/baseimage-alpine:3.16 AS base

COPY --from=build /tmp/wireproxy/wireproxy /usr/bin/wireproxy
COPY root/ /

RUN \
    echo "**** install frolvlad/alpine-python3 ****" && \
    apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip; fi && \
    echo "**** install wgcf ****" && \
    curl -fsSL git.io/wgcf.sh | bash && mkdir -p /wgcf && \
    echo "**** install python-proxy ****" && \
    apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
        py3-pycryptodome \
        py3-uvloop \
        && \
    pip3 install pproxy[accelerated] \
                toml && \
    echo "**** install others ****" && \
    apk add --no-cache \
        wireguard-tools \
        grep \
        moreutils \
        sed \
        && \
    echo "**** permissions ****" && \
    chmod a+x \
        /usr/local/bin/* \
        /etc/s6-overlay/scripts/* && \
    echo "**** cleanup ****" && \
    rm -rf \
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
VOLUME /config
WORKDIR /config

HEALTHCHECK --interval=10m --timeout=30s --start-period=10s --retries=3 \
    CMD /usr/local/bin/healthcheck

ENTRYPOINT ["/init"]
