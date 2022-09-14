# docker-warp

This requires a Wireguard kernel module.

## Usage
```yaml
version: "3"
services:
  warp:
    container_name: docker-warp
    image: docker-warp:testing
    network_mode: bridge
    restart: always
    volumes:
      - <path for wgcf config files>:/wgcf
      - /lib/modules:/lib/modules
    privileged: true
    sysctls:
      net.ipv6.conf.all.disable_ipv6: 0
    cap_add:
      - NET_ADMIN
    ports:
      - ${PORT_TO_EXPOSE}:${PROXY_PORT:-8008}
    environment:
      - PGID=${PGID}
      - PUID=${PUID}
      - PROXY_USER=${PROXY_USER}
      - PROXY_PASS=${PROXY_PASS}
```

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
| ```WARP_PLUS```  | set ```true``` to enable WARP+ quota script  | ```false``` |
| ```WARP_PLUS_VERBOSE```  | set ```true``` to run WARP+ quota script in verbose mode   | ```8080```  |