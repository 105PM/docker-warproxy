# docker-WARProxy

[wgcf](https://github.com/ViRb3/wgcf) + [wireproxy](https://github.com/pufferffish/wireproxy) + [python-proxy](https://github.com/qwj/python-proxy)

## Usage

```yaml
version: "3"
services:
  warproxy:
    container_name: docker-warproxy
    image: ghcr.io/105pm/docker-warproxy:latest
    network_mode: bridge
    restart: always
    volumes:
      - <path for config files>:/config
    ports:
      - ${PORT_TO_EXPOSE}:${PROXY_PORT:-8008}
    environment:
      - PGID=${PGID}
      - PUID=${PUID}
      - PROXY_USER=${PROXY_USER}
      - PROXY_PASS=${PROXY_PASS}
```

### To change license key

Simply set env `WGCF_LICENSE_KEY` and re-create the existing container or the service using `docker-compose up -d warproxy`. See more details [here](https://github.com/ViRb3/wgcf#change-license-key)

Please also note that there is a maximum limit of 5 active devices linked to the same account at a given time.

## Environment variables

### Basic

| ENV  | Description  | Default  |
|---|---|---|
| `PUID` / `PGID`  | uid and gid for running apps  | `911` / `911`  |
| `TZ`  | timezone  | `Asia/Seoul`  |

### wgcf

| ENV  | Description  | Default  |
|---|---|---|
| `WGCF_LICENSE_KEY` | native support by wgcf for changing license key | |
| `WGCF_DEVICE_NAME` | directly passed to wgcf binary to update device name, i.e. `wgcf update ${WGCF_DEVICE_NAME}` | |

### python-proxy

| ENV  | Description  | Default  |
|---|---|---|
| `PROXY_ENABLED`  | set `false` to disable proxy | `true` |
| `PROXY_USER` / `PROXY_PASS`  | required both to activate proxy authentication   |  |
| `PROXY_PORT`  | to run proxy in a different port  | `8008` |
| `PROXY_VERBOSE`  | simple access logging  |  |
| `PROXY_AUTHTIME`  | re-auth time interval for same ip (second in string format)  | `0` |

## Thanks

* [by275 (docker-dpitunnel)](https://github.com/by275/docker-dpitunnel)
