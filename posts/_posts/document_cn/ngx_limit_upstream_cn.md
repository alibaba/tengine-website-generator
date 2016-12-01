# limit upstream retries

限制每个请求对后端服务器访问的最大尝试次数，支持proxy、memcached、fastcgi、scgi和uwsgi模块。
可以使用下面的指令开启访问次数进行限制。

## Example

```
http {
upstream test {
server 127.0.0.1:8081;
server 127.0.0.2:8081;
server 127.0.0.3:8081;
server 127.0.0.4:8081;
}

server {
proxy_upstream_tries 2;
proxy_set_header Host $host;

location / {
proxy_pass test;
}
}
}
```

## 指令



Syntax: **fastcgi_upstream_tries** num

Default: -

Context: http, server, locatioon



限制fastcgi代理的后端尝试次数。


Syntax: **proxy_upstream_tries** num

Default: -

Context: http, server, locatioon



限制proxy代理的后端尝试次数。


Syntax: **memcached_upstream_tries** num

Default: -

Context: http, server, locatioon



限制memcached代理的后端尝试次数。


Syntax: **scgi_upstream_tries** num

Default: -

Context: http, server, locatioon



限制scgi代理的后端尝试次数。


Syntax: **uwsgi_upstream_tries** num

Default: -

Context: http, server, locatioon



限制uwsgi代理的后端尝试次数。

  
