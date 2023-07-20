# 高级路由

**`Tengine-Ingress`在兼容[ingress canary注解](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#canary)的基础上，支持基于request header，header值，header值正则匹配，cookie和权重的流量切分，无需tengine reload，所有应用域名的ingress金丝雀规则实时动态无损生效。**

## 基于请求Header的流量切分
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

![image](/book/_images/tengine_ingress_canary_header.png)

### 示例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: alibaba-ingress-tao
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-header: test-header
  name: alibaba-tao-tengine-taobao-org-ingress-canary-header
  namespace: alibaba-ingress-tao
spec:
  rules:
  - host: tengine.taobao.org
    http:
      paths:
      - backend:
          service:
            name: tengine-taobao-org-service-canary-a
            port:
              number: 2080
        path: /
        pathType: ImplementationSpecific
  tls:
  - hosts:
    - tengine.taobao.org
    secretName: alibaba-taobao-ecc
  - hosts:
    - tengine.taobao.org
    secretName: alibaba-taobao-rsa
```

## 基于请求Header值的流量切分
> 注解名称: `nginx.ingress.kubernetes.io/canary-by-header-value`
> 值类型: `string`
> 默认值: ` `
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

基于请求header值的高级路由
* 在上述基于请求header的高级路由基础上，可以指定具体匹配的header值，在header和header值完全匹配的情况下，请求将被转发到指定的后端upstream。
* 当请求消息中不存在用于高级路由的header和header值，则路由规则不生效。
* 路由规则匹配，但用于高级路由的后端upstream不存在，则请求会被降级路由到`主域名`对应的后端upstream。

![image](/book/_images/tengine_ingress_canary.png)

### 示例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: aserver
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-header: test-header-val
    nginx.ingress.kubernetes.io/canary-by-header-value: test
  name: alibaba-tao-tengine-taobao-org-ingress-canary-header-value
  namespace: alibaba-ingress-tao
spec:
  rules:
  - host: tengine.taobao.org
    http:
      paths:
      - backend:
          service:
            name: tengine-taobao-org-service-canary-b
            port:
              number: 3080
        path: /
        pathType: ImplementationSpecific
  tls:
  - hosts:
    - tengine.taobao.org
    secretName: alibaba-taobao-ecc
  - hosts:
    - tengine.taobao.org
    secretName: alibaba-taobao-rsa
```

## 基于服务权重的流量切分
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

![image](/book/_images/tengine_ingress_canary_weight.png)

### 示例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: aserver
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "20"
  name: alibaba-tao-tengine-taobao-org-ingress-canary-weight
  namespace: alibaba-ingress-tao
spec:
  rules:
  - host: tengine.taobao.org
    http:
      paths:
      - backend:
          service:
            name: tengine-taobao-org-service-canary-c
            port:
              number: 5080
        path: /
        pathType: ImplementationSpecific
  tls:
  - hosts:
    - tengine.taobao.org
    secretName: alibaba-taobao-ecc
  - hosts:
    - tengine.taobao.org
    secretName: alibaba-taobao-rsa
```
