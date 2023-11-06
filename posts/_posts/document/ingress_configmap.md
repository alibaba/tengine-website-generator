# Tengine-Ingress 全局配置Configmap

`Tengine-Ingress`完全兼容云原生[ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)标准规范，用户可参照[kubernetes ingress-nginx](https://kubernetes.github.io/ingress-nginx/)相关文档。
在此列出[Tengine-Ingress](https://github.com/alibaba/tengine-ingress)原生扩展和增强功能的Configmap。 

**注意：Tengine-Ingress基于默认初始化的Configmap可以正常运行，如果需要修改Configmap中的配置，则必须tengine reload生效配置。**

## Configmap

> Syntax: **https-allow-http** `true`;
> Default: `false`

如果设置`https-allow-http: 'true'`，则在listen指令中添加https_allow_http选项，表示该端口允许在SSL开启的情况下接收HTTP请求。

---
> Syntax: **custom-port-domain** `443: aaa.com, 2443: bbb.com, 3443: ccc.com`;
> Default: ``

设置证书端口映射表，通过不同的TLS端口与根域名的映射关系，动态匹配对应的证书。
当客户端TLS建链Client Hello请求不携带SNI，Tengine-Ingress通过端口匹配对应的证书用于TLS握手。

---
> Syntax: **tengine-reload** `false`;
> Default: `false`

默认设置`tengine-reload: 'false'`，则在新增，修改或删除ingress和secret资源对象时，都**无需tengine reload**，即开启配置动态无损生效模式。

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

默认不启用XUDP，如果设置`use-xquic-xudp: 'true'`，容器和宿主机的操作系统都必须是[Anolis](https://hub.docker.com/r/openanolis/anolisos)才能使用XUDP。
Tengine XUDP Module主要用于在服务端启用XUDP，支持bypass内核的用户态高性能UDP转发。
服务端启用HTTP3/QUIC监听服务，通过配合使用XUDP，可大幅提升HTTP3转发性能。

---
> Syntax: **http3-xquic-default-port** `443`;
> Default: `443`

Tengine-Ingress默认设置HTTP3/QUIC监听端口号443。Tengine-Ingress通过响应消息头`Alt-Svc: h3=":443"`协商通知客户端，客户端如果支持HTTP3，将通过端口443建立UDP连接。
如果需要修改`http3-xquic-default-port`，则必须同步更新tengine-ingress的启动命令行参数`--quic-port int`。
例如：设置`http3-xquic-default-port: 3443`，tengine-ingress启动命令行参数`--quic-port 3443`。

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
> Syntax: **max-canary-ing-num** `200`;
> Default: `200`

默认每个Ingress域名允许最多创建200个高级路由，每个高级路由都是独立的Canary Ingress资源对象。
对于超过默认200个的Canary Ingress资源对象，都将被忽略梳理。

---
> Syntax: **max-canary-action-num** `10`;
> Default: `10`

每个基于Canary Ingress高级路由的流量染色默认最大规则数量。
对于单个Canary Ingress，超过默认10条的流量染色规则都将被忽略梳理。
流量染色规则包括：向后端upstream转发的HTTP请求头中增加Header，在已有Header中追加Header值，或者是增加Query参数；以及向客户端转发的HTTP响应头中增加Header。

---
> Syntax: **default-canary-weight-total** `100`;
> Default: `100`

基于Canary Ingress高级路由的默认服务权重总和。

---
> Syntax: **max-canary-weight-total** `10000`;
> Default: `100`

基于Canary Ingress高级路由的最大服务权重总和。

---
> Syntax: **max-canary-header-val-num** `20`;
> Default: `20`

基于Header值的Canary Ingress高级路由默认允许匹配的Header值个数。

---
> Syntax: **max-canary-cookie-val-num** `20`;
> Default: `20`

基于Cookie值的Canary Ingress高级路由默认允许匹配的Cookie值个数。

---
> Syntax: **max-canary-query-val-num** `20`;
> Default: `20`

基于Query参数值的Canary Ingress高级路由默认允许匹配的Query参数值个数。

---
> Syntax: **max-canary-req-add-header-num** `2`;
> Default: `2`

基于Canary Ingress高级路由，向后端upstream转发HTTP请求中默认允许增加的Header个数。

---
> Syntax: **max-canary-req-append-header-num** `2`;
> Default: `2`

基于Canary Ingress高级路由，向后端upstream转发HTTP请求中默认允许追加的Header个数。

---
> Syntax: **max-canary-req-add-query-num** `2`;
> Default: `2`

基于Canary Ingress高级路由，向后端upstream转发HTTP请求中默认允许增加的Query参数个数。

---
> Syntax: **max-canary-resp-add-header-num** `2`;
> Default: `2`

基于Canary Ingress高级路由，向客户端转发HTTP响应中默认允许增加的Header个数。

---
> Syntax: **user** `root`;
> Default: `root`

默认启动tengine进程的用户角色。

---
> Syntax: **max-stop-sleep-time-for-stop** `35`;
> Default: `35`

Tengine进程停止阶段，等待4层负载均衡流量清零的时间。
在4层负载均衡流量清零，4层LB不再转发报文到Tengine后，再优雅关停Tengine进程。
