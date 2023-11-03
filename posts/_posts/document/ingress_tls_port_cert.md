# TLS端口映射默认证书

`Tengine-Ingress`支持证书端口映射，通过不同的TLS端口与根域名的映射关系，动态匹配对应证书。

Configmap配置**custom-port-domain**
> Syntax: **custom-port-domain** `443: aaa.com, 2443: bbb.com, 3443: ccc.com`;
> Default: ``

设置证书端口映射表，通过不同的TLS端口与根域名的映射关系，动态匹配对应证书。
当客户端TLS建链Client Hello请求不携带SNI，Tengine-Ingress通过端口匹配对应的证书用于TLS握手。


## 示例 
```yaml
custom-port-domain: '443: a.com, 4431: b.com, 4432: c.com'
```

* 通过在Configmap中增加配置custom-port-domain，`Tengine-Ingress`基于template配置模板，动态生成下述tengine配置文件：
```
        ## start server _
        server {
                server_name _ ;

                listen 80 default_server reuseport backlog=65535 ;
                listen [::]:80 default_server reuseport backlog=65535 ;
                listen 443 default_server reuseport backlog=65535 ssl http2 https_allow_http ;
                listen [::]:443 default_server reuseport backlog=65535 ssl http2 https_allow_http ;

                listen 4431 default_server reuseport backlog=65535 ssl http2 https_allow_http ;
                listen [::]:4432 default_server reuseport backlog=65535 ssl http2 https_allow_http ;
                listen 4432 default_server reuseport backlog=65535 ssl http2 https_allow_http ;
                listen [::]:4438 default_server reuseport backlog=65535 ssl http2 https_allow_http ;

                ... ...
        }
```

###
* `证书1`: 加签域名包含根域名a.com
```
CN: [
a.com
*.a1.a.com
*.a2.a.com
*.a3.a.com
*.a4.a.com
*.a5.a.com
*.a6.a.com ]
```
* 在客户端向`Tengine-Ingress`服务端口443建链请求，如果客户端Client Hello未携带SNI，则`Tengine-Ingress`默认使用`证书1`完成TLS握手

###
* `证书2`: 加签域名包含根域名b.com
```
CN: [
b.com
*.b1.b.com
*.b2.b.com
*.b3.b.com
*.b4.b.com
*.b5.b.com
*.b6.b.com ]
```
* 在客户端向`Tengine-Ingress`服务端口4432建链请求，如果客户端Client Hello未携带SNI，则`Tengine-Ingress`默认使用`证书2`完成TLS握手

###
* `证书3`: 加签域名包含根域名c.com
CN: [
c.com
*.c1.c.com
*.c2.c.com
*.c3.c.com
*.c4.c.com
*.c5.c.com
*.c6.c.com ]
```
* 在客户端向`Tengine-Ingress`服务端口4432建链请求，如果客户端Client Hello未携带SNI，则`Tengine-Ingress`默认使用`证书3`完成TLS握手
