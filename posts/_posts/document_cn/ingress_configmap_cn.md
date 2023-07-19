# Tengine-Ingress

Tengine-Ingress完全兼容云原生[ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)标准规范，用户可参照[kubernetes ingress-nginx](https://kubernetes.github.io/ingress-nginx/)相关文档。
在此列出[Tengine-Ingress](https://github.com/alibaba/tengine-ingress)原生扩展和增强功能的Configmap。 

【注意】Tengine-Ingress基于默认初始化的Configmap可以正常运行，如果需要修改Configmap中的配置，则必须tengine reload生效配置。

## Configmap

> Syntax: **https-allow-http** `true`;
> Default: `false`

如果设置`https-allow-http: 'true'`，则在listen指令中添加https_allow_http选项，表示该端口允许在SSL开启的情况下接收HTTP请求。

---

> Syntax: **tengine-reload** `false`;
> Default: `false`

默认设置`tengine-reload: 'false'`，则在新增，修改或删除ingress和secret资源对象时，都不再tengine reload，即开启配置动态无损生效模式。

---

> Syntax: **tengine-static-service-cfg** `false`;
> Default: `false`

默认设置`tengine-static-service-cfg: 'false'`，则在新增，修改或删除ingress和secret资源对象时，都不再更新nginx.conf配置文件，tengine仅从共享内存中获取应用域名和证书配置。

---

> Syntax: **filelock-shm-service-cfg** `/etc/nginx/shm_service_cfg.lock`;
> Default: `/etc/nginx/shm_service_cfg.lock`

通过配置`filelock-shm-service-cfg`设置共享内存文件锁的路径。Tengine-Ingress控制器通过订阅和处理ingress域名资源和secret证书资源，基于tengine ingress模板转换为动态配置写入共享内存。Tengine-proxy订阅共享内存变化写入内部运行时共享内存，将终端用户的外部流量路由到K8s集群中的应用服务。

---

> Syntax: **filepath-status-tengine** `/etc/nginx/htdocs/status.tengine`;
> Default: `/etc/nginx/htdocs/status.tengine`

对tengine设置HTTP健康检查的文件路径，通过默认80和443端口请求`/status.tengine`，如果tengine-proxy健康状态正常，则返回`/etc/nginx/htdocs/status.tengine`。
默认封禁应用域名的`/status.tengine`请求，tengine-proxy直接返回404。

---

> Syntax: **max-canary-ing-num** `200`;
> Default: `200`

默认每个Ingress域名允许最多创建200个高级路由，每个高级路由都是独立的Canary Ingress资源对象。
对于超过默认200个的Canary Ingress资源对象，都将被忽略梳理。

---

> Syntax: **canary-referrer** `a,b,c`;
> Default: -

设置高级路由Canary Ingress资源对象的来源范围，仅允许`canary-referrer`中的应用列表创建高级路由Canary Ingress资源对象。
默认情况下`canary-referrer`为空，即允许所有应用创建高级路由Canary Ingress资源对象。

---

> Syntax: **ingress-referrer** `a,b,c`;
> Default: -

设置Ingress资源对象的来源范围，仅允许`ingress-referrer`中的应用列表创建Ingress资源对象。
默认情况下`ingress-referrer`为空，即允许所有应用创建Ingress资源对象。

---

> Syntax: **ingress-shm-size** `268435456`;
> Default: `268435456`

设置Ingress共享内存大小，默认256MB共享内存可存储超过3万个Ingress资源对象。

---

> Syntax: **tengine-ingress-app-name** `tengine-ingress`;
> Default: `tengine-ingress`

设置请求header `X-Request-From: tengine-ingress`，标识请求是通过网关`tengine-ingress`路由转发。  

---

> Syntax: **use-ingress-storage-cluster** `true`;
> Default: `false`

Tengine-Ingress支持K8s core集群与K8s ingress存储集群相隔离的高可靠性部署方案，将运行态和存储态相分离，独立K8s ingress集群可以保证自身API服务器和etcd性能稳定，并且在core集群核心组件API服务器和etcd不可用的高危场景下也能正常向外提供7层转发服务。如果设置`use-ingress-storage-cluster: 'true'`，则tengine-ingress将通过启动命令行参数`--kubeconfig`中的kubeconfig从独立K8s ingress存储集群获取Ingress和Secret资源对象，而configmap仍然从tengine-ingress所在的K8s core集群中获取。

---

> Syntax: **use-ingress-checksum** `true`;
> Default: `false`

Tengine-Ingress通过全局一致性校验机制保障内存中运行态持有的用户侧ingress域名的有效性和正确性，在域名配置不符合标准化k8s资源ingress规范及其相关RFC标准时，将不再更新本地缓存，保障运行态永远可正常向外提供7层转发服务。如果设置`use-ingress-checksum: 'true'`，Tengine-ingress基于ingress全局一致性校验算法计算全局MD5值，与CRD ingresschecksums资源对象中的MD5值相匹配，则表明本次更新的ingress资源对象是全局一致性，即可将ingress资源对象更新到本地缓存，并写入共享内存，开始使用最新的ingress域名配置对外提供HTTP(S)七层负载均衡，TLS卸载和路由转发功能；否则表明更新的ingress资源对象全局不一致，系统存在脏数据，不再更新本地缓存和共享内存，仍旧使用存量的ingress域名配置对外提供HTTP(S)接入服务，保证运行态域名接入和路由服务的正确性和可靠性。

---

> Syntax: **use-secret-checksum** `true`;
> Default: `false`

Secret证书资源对象采用了类似的全局一致性方案。如果设置`use-secret-checksum: 'true'`，Tengine-Ingress通过全局一致性校验机制保障内存中运行态持有的用户侧secret证书的有效性和正确性，在证书信息不符合标准化k8s资源secret规范及其相关RFC标准时，将不再更新本地缓存，保障运行态永远可正常向外提供7层转发服务。

---

> Syntax: **use-http3-xquic** `true`;
> Default: `true`

默认启用HTTP3/QUIC协议，如果设置`use-http3-xquic: 'false'`，则Tengine-Ingress将无法处理HTTP3/QUIC报文。

---

> Syntax: **use-xquic-xudp** `true`;
> Default: `false`

默认不启用XUDP，如果设置`use-xquic-xudp: 'true'`，操作系统必须是Anolis OS 8.8及其以上版本才能使用XUDP。
Tengine XUDP Module主要用于在服务端启用XUDP，支持bypass内核的用户态高性能UDP转发。
服务端启用HTTP3/QUIC监听服务，通过配合使用XUDP，可大幅提升HTTP3转发性能。

---

> Syntax: **http3-xquic-default-port** `2443`;
> Default: `2443`

Tengine-Ingress默认设置HTTP3/QUIC监听端口号2443。Tengine-Ingress通过响应消息头`Alt-Svc: h3=":2443"`协商通知客户端，客户端如果支持HTTP3，将通过端口2443建立UDP连接。
如果需要修改`http3-xquic-default-port`，因tengine worker进程的权限限制，HTTP3/QUIC监听端口号必须大于1024，且必须同步更新tengine-ingress的启动命令行参数`--quic-port int`。
例如：设置`http3-xquic-default-port: 3443`，tengine-ingress启动命令行参数`--quic-port 3443`。
