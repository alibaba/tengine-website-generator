# ngx_http_upstream_keepalive_module

长连接超时设置

增加nginx后端长连接的超时支持:

```
upstream backend {
    server 127.0.0.1:8080;
    keepalive 32;
    keepalive_timeout 30s; # 设置后端连接的最大idle时间为30s
}
```

## 指令

> Syntax: **keepalive_timeout** time
> Default: -
> Context: upstream

该指令设置后端长连接的最大空闲超时时间，参数的时间单位可以是s（秒），ms（毫秒），m（分钟）。默认时间单位是秒。
