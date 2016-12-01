---
title: "ngx_http_upstream_keepalive_module keepalive timeout"
date: "2016-12-02 03:37:32"
---


Enhance the ngx_http_upstream_keepalive_module to support setting keepalive timeout:

```
upstream backend {
server 127.0.0.1:8080;
keepalive 32;
keepalive_timeout 30s; # set keepalive_timeout to 30s
}
```

## Directives

Syntax: **keepalive_timeout** time

Default: -

Context: upstream

Controls the max idle time used in backend keepalive connections. The 'time' argument can be an integer, with an optional time unit, like s (second), ms (millisecond), m (minute). The default time unit is s (second).
