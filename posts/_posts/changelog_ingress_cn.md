## 变更列表

#### Tengine-Ingress-1.1.0 [2023-11-06]

**Image:** `tengine-ingress-registry.cn-hangzhou.cr.aliyuncs.com/tengine/tengine-ingress:1.1.0` (Anolis)
**Image:** `tengine-ingress-registry.cn-hangzhou.cr.aliyuncs.com/tengine/tengine-ingress:1.1.0-alpine` (Alpine)

_特性:_

- 支持不同Ingress域名配置多TLS版本，动态无损生效，无需reload或重启tengine worker进程 (lianglli)
- 可配置多张默认Secret证书，允许client-hello不含SNI的TLS建链请求 (lianglli)  
- 支持IngressClass (lianglli)
- 基于Canary Ingress，支持多个Header值，Cookie值，Query参数值的灰度路由，动态无损生效 (lianglli)
- 基于Canary Ingress，支持Header值取模，Cookie值取模，Query参数值取模的灰度路由，动态无损生效 (lianglli)
- 基于Canary Ingress，支持请求流量染色，在向后端upstream转发请求中增加Header和追加Header值，动态无损生效 (lianglli)
- 基于Canary Ingress，支持响应流量染色，在向客户端转发响应中增加Header，动态无损生效 (lianglli)
- 基于服务权重的灰度路由，支持服务权重总和的动态配置更新 (lianglli) 
- 支持CORS (跨域资源共享) 多origins (lianglli) 
- 可通过configmap 'user'配置tengine worker进程的用户角色 (lianglli) 
- 支持单个ingress域名和单张secret证书分批次逐级生效时，一键全局配置生效 (lianglli) 

_变更:_

- 从配置模板文件中去除重复和无用的location (lianglli) 
- 更新Go语言的相关API，并删除已废弃的API (lianglli)
- 退出时，先等待4层负载均衡流量清零，再关停tengine进程 (lianglli) 

_缺陷:_

- 解决HTTP请求/configuration/certs?hostname=_返回500问题 (drawing)
- 解决静态配置模式下，重复location robots.txt和未知变量https_use_timing的问题 (lianglli) 
- 解决Configmap配置use-ingress-storage-cluster不生效的问题 (lianglli)
- 解决静态配置模式下，HTTP路由不生效的问题 (lianglli)
- 解决部分场景下CORS (跨域资源共享) 配置无法动态生效的问题 (lianglli) 


#### Tengine-Ingress-1.0.0 [2023-07-21]

**Image:** `tengine-ingress-registry.cn-hangzhou.cr.aliyuncs.com/tengine/tengine-ingress:1.0.0` (Anolis)
**Image:** `tengine-ingress-registry.cn-hangzhou.cr.aliyuncs.com/tengine/tengine-ingress:1.0.0-alpine` (Alpine)

- 基于K8s Ingress，Secret，Service和Endpoint资源对象，动态无损更新tengine的servers，locations和upstreams, 无需reload或重启tengine worker进程 (lianglli)
- 基于Canary Ingress，支持Header，Header值和服务权重的灰度路由，动态无损生效，满足应用在灰度发布，蓝绿部署和A/B测试不同场景的需求 (lianglli)
- 基于内部运行时共享内存，支持Ingress域名维度的后端响应超时时间，强制HTTPS，CORS跨域资源共享，网络爬虫等相关ingress注解（高级配置）的动态无损生效 (lianglli)
- 动态配置证书和私钥 (lianglli)
- 支持不同Ingress域名同时配置生效ECC和RSA双证书 (lianglli)
- 支持HTTP/3(兼容QUIC v1和draft-29标准) (lianglli)
- 支持运行态和存储态相分离，实时监听独立k8s集群内的Ingress域名和Secret证书资源 (lianglli)
- Tengine-Ingress在StatefulSet部署模式下，支持单个ingress域名和单张secret证书分批次逐级生效机制 (lianglli)
- 通过新增CRD IngressCheckSum和SecretCheckSum，通过全局一致性校验机制保障内存中运行态持有的用户侧ingress域名和secret证书的有效性和正确性 (lianglli)
