ARG ALPINE_VER=3.18

## BUILD WIREPROXY
FROM golang:1.20-alpine${ALPINE_VER} AS builder
RUN \
    echo "**** build wireproxy ****" && \
    go install github.com/octeep/wireproxy/cmd/wireproxy@latest

## ALPINE BASE WITH PYTHON3

FROM ghcr.io/linuxserver/baseimage-alpine:${ALPINE_VER} AS base

RUN \
    echo "**** install frolvlad/alpine-python3 ****" && \
    apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip; fi && \
    echo "**** install wgcf ****" && \
    curl -fsSL https://git.io/wgcf.sh | bash && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/* \
        /root/.cache


FROM base AS collector

COPY --from=builder /go/bin/wireproxy /bar/usr/local/bin/wireproxy
COPY root/ /bar/

RUN echo "**** permissions ****" && \
    chmod a+x \
        /bar/usr/local/bin/* \
        /bar/etc/s6-overlay/s6-rc.d/*/run \
        /bar/etc/s6-overlay/s6-rc.d/*/finish \
        /bar/etc/s6-overlay/s6-rc.d/*/data/*

## RELEASE

FROM base
LABEL maintainer="105PM"
LABEL org.opencontainers.image.source https://github.com/105PM/docker-warproxy


RUN \
    echo "**** install python-proxy ****" && \
    apk add --no-cache \
        py3-pycryptodome \
        py3-requests \
        py3-toml \
        py3-uvloop \
        && \
    pip3 install pproxy[accelerated] && \
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
    PROXY_ENABLED=true \
    PROXY_PORT=8008

EXPOSE ${PROXY_PORT}
VOLUME /config
WORKDIR /config

HEALTHCHECK --interval=5m --timeout=30s --start-period=2m --retries=3 \
    CMD /usr/local/bin/healthcheck

ENTRYPOINT ["/init"]
