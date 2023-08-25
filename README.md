# docker-WARProxy

[wgcf](https://github.com/ViRb3/wgcf) + [wireproxy](https://github.com/octeep/wireproxy) + [python-proxy](https://github.com/qwj/python-proxy) and some useful scripts

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

If you have an existing Warp+ license key, edit `/config/wgcf-account.toml` and,  delete two files :  
`/config/wgcf-profile.conf` and `/config/wireproxy.conf`  
When you restart container, it will update your account info and re-generate conf files automatically.

## Direct connection to wireproxy

As wireproxy is binding to ```0.0.0.0:8080```, you can directly access it independently to the proxy running at front by publishing your container port ```8080```. It is highly recommended exposing the port for internal use only.

## Environment variables

| ENV  | Description  | Default  |
|---|---|---|
| ```PUID``` / ```PGID```  | uid and gid for running an app  | ```911``` / ```911```  |
| ```TZ```  | timezone  | ```Asia/Seoul```  |
| ```PROXY_ENABLED```  | set ```false``` to disable proxy | ```true``` |
| ```PROXY_USER``` / ```PROXY_PASS```  | required both to activate proxy authentication   |  |
| ```PROXY_PORT```  | to run proxy in a different port  | ```8008``` |
| ```PROXY_VERBOSE```  | simple access logging  |  |
| ```PROXY_AUTHTIME```  | re-auth time interval for same ip (second in string format)  | ```0``` |
| ```WARP_ENABLED```  | set ```false``` to disable cloudflare WARP  | ```true``` |
| ```WARP_PLUS```  | set ```true``` to enable auto WARP+ quota script  | ```false``` |
| ```WARP_PLUS_VERBOSE```  | set ```true``` to run auto WARP+ quota script in verbose mode   | ```false```  |

## Thanks

* [by275 (docker-dpitunnel)](https://github.com/by275/docker-dpitunnel)
