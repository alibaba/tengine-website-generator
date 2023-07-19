# Tengine-Ingress

Tengine-Ingress完全兼容云原生[ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)标准规范，用户可参照[kubernetes ingress-nginx](https://kubernetes.github.io/ingress-nginx/)相关文档。

在此列出[Tengine-Ingress](https://github.com/alibaba/tengine-ingress)原生扩展和增强功能的Annotations。 

下述所有Annotations的变更生效都无需tengine reload，注解配置无损实时动态生效，长连接保持不变，成功率不受影响，配置变更效率提升翻倍，网关稳定性进一步得到增强。
对于文档[kubernetes ingress-nginx](https://kubernetes.github.io/ingress-nginx/)中的注解，如果不在下述Annotations列表范围，则暂不支持动态生效。


## Annotations

### HTTP
> 注解名称: `nginx.ingress.kubernetes.io/ssl-redirect`
> 值类型: `true` 或 `false`
> 默认值: `true`
> 注解类型: `ingress注解`
> 生效维度: `域名`

强制HTTPS：Ingress注解`nginx.ingress.kubernetes.io/ssl-redirect`，生效维度是`域名`，`域名/Path`继承`域名/`相同的`ssl-redirect`。
默认强制HTTPS`nginx.ingress.kubernetes.io/ssl-redirect: "true"`，即HTTP请求会被301重定向到HTTPS，客户端接收到301 HTTPS，需要通过TLS建链发送HTTPS请求到网关`Tengine-Ingress`。

---

> 注解名称: `nginx.ingress.kubernetes.io/proxy-read-timeout`
> 值类型: `number`
> 默认值: `60`
> 单位: `秒`
> 注解类型: `ingress注解`
> 生效维度: `域名` 或 `域名/path`

后端响应超时时间：Ingress注解`nginx.ingress.kubernetes.io/proxy-read-timeout`，生效维度是`域名`或`域名/path`，相同域名不同path可以设置不同的`proxy-read-timeout`。
请求从网关`Tengine-Ingress`向后端upstream发送后，等待后端upstream返回响应的最大时长，网关默认等待60秒，超过60秒未接收到upstream的响应报文，则网关`Tengine-Ingress`返回客户端HTTP 504错误响应消息。

### 高级路由
> 注解名称: `nginx.ingress.kubernetes.io/canary`
> 值类型: `true` 或 `false`
> 默认值: `false`
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

高级路由标识
* 如果Ingress资源对象有注解`nginx.ingress.kubernetes.io/canary: "true"`，则实际为Canary Ingress资源对象，专用于HTTP高级路由。
* 一个Canary Ingress资源对象定义一个高级路由，必须包含有注解`nginx.ingress.kubernetes.io/canary: "true"`。

---

> 注解名称: `nginx.ingress.kubernetes.io/canary-by-header`
> 值类型: `string`
> 默认值: ` `
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

基于请求header的高级路由
* 基于请求Header的流量切分，当用于高级路由header的值等于`always`，则请求将被转发到指定的后端upstream。
* 当请求消息中不存在用于高级路由的header，或者header值不等于`always`，则路由规则不生效。
* 路由规则匹配，但用于高级路由的后端upstream不存在，则请求会被降级路由到`主域名`对应的后端upstream。
* 所谓`主域名`即Ingress资源对象中的host，全部相同host的Canary Ingress资源对象都是隶属于`主域名`的高级路由。

---

> 注解名称: `nginx.ingress.kubernetes.io/canary-by-header-value`
> 值类型: `string`
> 默认值: ` `
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

基于请求header值的高级路由
* 在上述基于请求header的高级路由基础上，可以指定具体匹配的header值，在header和header值完全匹配的情况下，请求将被转发到指定的后端upstream。
* 当请求消息中不存在用于高级路由的header和header值，则路由规则不生效。
* 路由规则匹配，但用于高级路由的后端upstream不存在，则请求会被降级路由到`主域名`对应的后端upstream。

---

> 注解名称: `nginx.ingress.kubernetes.io/canary-weight`
> 值类型: `string`
> 默认值: ` `
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

基于服务权重的高级路由
* 基于服务权重的流量切分，其优先级低于上述基于请求header和header值的高级路由，优先级从高到低依次为 Header&Header值 --> Cookie --> 服务权重。
* 刨除上述基于请求header和header值的高级路由请求，其他所有请求消息将按照服务权重比例转发到指定的后端upstream。
* 例如：后端upstream=gray，服务权重=5，则5%请求被转发到后端upstream=gray，其它95%请求会被转发到`主域名`对应的后端upstream。
* 当高级路由的服务权重被设置为100，则所有请求消息都将默认转发到高级路由配置的后端upstream，请求消息将不再转发到`主域名`对应的后端upstream。

### 网页爬虫
> 注解名称: `nginx.ingress.kubernetes.io/disable-robots`
> 值类型: `true` 或 `false`
> 默认值: `false`
> 注解类型: `ingress注解`
> 生效维度: `域名`

禁止搜索引擎收录：默认允许网页爬虫，设置`nginx.ingress.kubernetes.io/disable-robots: "true"`，则禁止对应用域名执行网络爬虫。

### CORS (跨域资源共享)
> 注解名称: `nginx.ingress.kubernetes.io/enable-cors`
> 值类型: `true` 或 `false`
> 默认值: `false`
> 注解类型: `ingress注解`
> 生效维度: `域名` 或 `域名/path`

开启跨域资源共享：默认禁止跨域资源共享，如果设置`nginx.ingress.kubernetes.io/enable-cors: "true"`，则应用域名开启跨域资源共享。

---

> 注解名称: `nginx.ingress.kubernetes.io/cors-allow-origin`
> 值类型: `string`
> 默认值: `*`
> 值格式：`<origin>[, <origin>] | *`
> 注解类型: `ingress注解`
> 生效维度: `域名` 或 `域名/path`

服务端允许跨域请求的源列表：默认允许所有源都可以跨域资源请求。

---

> 注解名称: `nginx.ingress.kubernetes.io/cors-max-age`
> 值类型: `number`
> 默认值: `1728000`
> 单位: `秒`
> 注解类型: `ingress注解`
> 生效维度: `域名` 或 `域名/path`

预检请求的响应内容可缓存的最大时间：有效期内客户端跨域资源请求都不再需要预检请求。

---

> 注解名称: `nginx.ingress.kubernetes.io/cors-allow-credentials`
> 值类型: `true` 或 `false`
> 默认值: `true`
> 注解类型: `ingress注解`
> 生效维度: `域名` 或 `域名/path`

用于控制是否允许在跨域请求中携带认证信息：认证信息含cookies，header Authorization，客户端证书。

---

> 注解名称: `nginx.ingress.kubernetes.io/cors-allow-methods`
> 值类型: `string`
> 默认值: `GET, PUT, POST, DELETE, PATCH, OPTIONS`
> 值格式：`<method>[, <method>]*`
> 值校验：`以','分割，只允许字母`
> 注解类型: `ingress注解`
> 生效维度: `域名` 或 `域名/path`

服务端允许跨域资源请求的HTTP Method列表。

---

> 注解名称: `nginx.ingress.kubernetes.io/cors-allow-headers`
> 值类型: `string`
> 默认值: `DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization`
> 值格式：`<header-name>[, <header-name>]*`
> 值校验：`以','分割，只允许字母，数字，_ 和 -`
> 注解类型: `ingress注解`
> 生效维度: `域名` 或 `域名/path`

服务端允许跨域资源请求的HTTP Header列表。

### 来源标识

> 注解名称: `nginx.ingress.kubernetes.io/ingress-referrer`
> 值类型: `string`
> 默认值: ` `
> 值格式：`<referrer>[, <referrer>]`
> 值校验：`以','分割`
> 注解类型: `ingress注解`
> 生效维度: `域名` 或 `域名/path`

注解`nginx.ingress.kubernetes.io/ingress-referrer`用于标识Ingress资源对象的来源。
网关`Tengine-Ingress`基于configmap的配置`ingress-referrer`，校验Ingress资源对象的来源是否在授权允许创建Ingress资源对象的应用列表中。
以下场景的ingress资源对象将被丢弃处理：
* 注解ingress-referrer值非空，且不在configmap配置`ingress-referrer`授权应用列表中。   

---

> 注解名称: `nginx.ingress.kubernetes.io/canary-referrer`
> 值类型: `string`
> 默认值: ` `
> 值格式：`<referrer>[, <referrer>]`
> 值校验：`以','分割`
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

注解`nginx.ingress.kubernetes.io/canary-referrer`用于标识Canary Ingress资源对象的来源。
网关`Tengine-Ingress`基于configmap的配置`canary-referrer`，校验Canary Ingress资源对象的来源是否在授权允许创建Canary Ingress资源对象的应用列表中。
以下场景的ingress资源对象将被丢弃处理：
* 注解canary-referrer值非空，且不在configmap配置`canary-referrer`授权应用列表中。 

### Ingress分批次滚动生效

> 注解名称: `nginx.ingress.kubernetes.io/ingress-rollout`
> 值类型: `true` 或 `false`
> 默认值: `false`
> 注解类型: `ingress注解`
> 生效维度: `域名` 或 `域名/path`

Ingress资源对象分批次滚动生效开关
* 为了使用Ingress域名资源对象的分批次滚动生效功能，Tengine-Ingress需要以statefulset形式部署发布。
* 如果注解`nginx.ingress.kubernetes.io/ingress-rollout: "true"`，ingress资源对象将在网关`Tengine-Ingress`集群内部分批次滚动生效，无需tengine reload，实时动态无损生效。

---

> 注解名称: `nginx.ingress.kubernetes.io/ingress-rollout-current-revision`
> 值类型: `string`
> 默认值: ` `
> 注解类型: `ingress注解`
> 生效维度: `域名` 或 `域名/path`

Ingress资源对象的当前运行版本号

---

> 注解名称: `nginx.ingress.kubernetes.io/ingress-rollout-update-revision`
> 值类型: `string`
> 默认值: ` `
> 注解类型: `ingress注解`
> 生效维度: `域名` 或 `域名/path`

Ingress资源对象的升级版本号

---

> 注解名称: `nginx.ingress.kubernetes.io/ingress-rollout-index-id`
> 值类型: `number`
> 默认值: `-1`
> 注解类型: `ingress注解`
> 生效维度: `域名` 或 `域名/path`

Ingress资源对象的生效范围
* 网关`Tengine-Ingress`集群需要以statefulset形式部署发布，0..N-1为Tengine-Ingress的Pod序号，从0开始到N-1结束。
* 例如：网关`Tengine-Ingress`集群有10个实例，则Tengine-Ingress的Pod序号的为0..9。
* 只有Pod序号小于`ingress-rollout-index-id`的Tengine-Ingress实例才会动态更新ingress资源对象。

### Secret分批次滚动生效

> 注解名称: `nginx.ingress.kubernetes.io/secret-rollout`
> 值类型: `true` 或 `false`
> 默认值: `false`
> 注解类型: `secret注解`
> 生效维度: `域名` 或 `域名/path`

Secret资源对象分批次滚动生效开关
* 为了使用Secret域名资源对象的分批次滚动生效功能，Tengine-Ingress需要以statefulset形式部署发布。
* 如果注解`nginx.ingress.kubernetes.io/secret-rollout: "true"`，secret资源对象将在网关`Tengine-Ingress`集群内部分批次滚动生效，无需tengine reload，实时动态无损生效。

---

> 注解名称: `nginx.ingress.kubernetes.io/secret-rollout-current-revision`
> 值类型: `string`
> 默认值: ` `
> 注解类型: `secret注解`
> 生效维度: `域名` 或 `域名/path`

Secret资源对象的当前运行版本号

---

> 注解名称: `nginx.ingress.kubernetes.io/secret-rollout-update-revision`
> 值类型: `string`
> 默认值: ` `
> 注解类型: `secret注解`
> 生效维度: `域名` 或 `域名/path`

Secret资源对象的升级版本号

---

> 注解名称: `nginx.ingress.kubernetes.io/secret-rollout-index-id`
> 值类型: `number`
> 默认值: `-1`
> 注解类型: `secret注解`
> 生效维度: `域名` 或 `域名/path`

Secret资源对象的生效范围
* 网关`Tengine-Ingress`集群需要以statefulset形式部署发布，0..N-1为Tengine-Ingress的Pod序号，从0开始到N-1结束。
* 只有Pod序号小于`ingress-rollout-index-id`的Tengine-Ingress实例才会动态更新secret资源对象。

### 全局一致性校验

> 注解名称: `nginx.ingress.kubernetes.io/version`
> 值类型: `number`
> 默认值: `0`
> 注解类型: `ingress注解`
> 生效维度: `域名` 或 `域名/path`

Ingress资源对象的ID号：唯一标识一个ingress资源对象。

---

> 注解名称: `nginx.ingress.kubernetes.io/version`
> 值类型: `number`
> 默认值: `0`
> 注解类型: `secret注解`
> 生效维度: `域名` 或 `域名/path`

Secret资源对象的ID号：唯一标识一个secret资源对象。

