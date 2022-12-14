ARG ALPINE_VER=3.16

## BUILD WIREPROXY
FROM golang:1.18 as builder
RUN \
    echo "**** build wireproxy ****" && \
    git clone https://github.com/octeep/wireproxy /tmp/wireproxy && \
    cd /tmp/wireproxy && \
    CGO_ENABLED=0 go build ./cmd/wireproxy

## ALPINE BASE WITH PYTHON3

FROM ghcr.io/linuxserver/baseimage-alpine:${ALPINE_VER} AS base

ADD https://git.io/wgcf.sh /tmp/wgcf.sh

RUN \
    echo "**** install frolvlad/alpine-python3 ****" && \
    apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip; fi && \
    echo "**** install wgcf ****" && \
    bash /tmp/wgcf.sh && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/* \
        /root/.cache


FROM base AS collector

COPY --from=builder /tmp/wireproxy/wireproxy /bar/usr/bin/wireproxy
COPY root/ /bar

RUN echo "**** permissions ****" && \
    chmod a+x \
        /usr/local/bin/* \
        /bar/etc/s6-overlay/scripts/*

## RELEASE

FROM base
LABEL maintainer="105PM"
LABEL org.opencontainers.image.source https://github.com/105PM/docker-warproxy


RUN \
    echo "**** install python-proxy ****" && \
    apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
        py3-pycryptodome \
        py3-uvloop \
        && \
    pip3 install pproxy[accelerated] \
                toml && \
    echo "**** install others ****" && \
    apk add --no-cache \
        grep \
        moreutils \
        sed \
        && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/* \
        /root/.cache

COPY --from=collector /bar/ /

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
