ARG ALPINE_VER=3.20

## ALPINE BASE WITH PYTHON3
FROM ghcr.io/linuxserver/baseimage-alpine:${ALPINE_VER} AS base
RUN \
    echo "**** install frolvlad/alpine-python3 ****" && \
    apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm /usr/lib/python*/EXTERNALLY-MANAGED && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip; fi && \
    echo "**** install runtime packages ****" && \
    apk add --no-cache \
        grep \
        py3-pycryptodome \
        py3-requests \
        py3-toml \
        py3-uvloop \
        sed \
        && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/* \
        /root/.cache

## INSTALL wgcf
FROM base AS wgcf
RUN \
    echo "**** install wgcf ****" && \
    curl -fsSL https://git.io/wgcf.sh | bash

## INSTALL wireproxy
FROM golang:1.23-alpine${ALPINE_VER} AS wproxy
RUN \
    echo "**** build wireproxy ****" && \
    go install github.com/pufferffish/wireproxy/cmd/wireproxy@latest

## INSTALL python-proxy
FROM base AS pproxy
RUN \
    apk add --no-cache git && \
    pip install --root /bar \
        "pproxy[accelerated] @ git+https://github.com/by275/python-proxy"


FROM base AS collector

COPY --from=wgcf /usr/local/bin/wgcf /bar/usr/local/bin/wgcf
COPY --from=wproxy /go/bin/wireproxy /bar/usr/local/bin/wireproxy
COPY --from=pproxy /bar/ /bar/
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
LABEL org.opencontainers.image.source=https://github.com/105PM/docker-warproxy

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
