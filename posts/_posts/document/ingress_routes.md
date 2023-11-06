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
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-header: test-header
  name: alibaba-tao-tengine-taobao-org-ingress-canary-header
  namespace: alibaba-ingress-tao
spec:
  ingressClassName: default-ingress-class
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
* Header值默认允许最多设置20个，只要其中1个相匹配，请求就会被转发到指定的后端upstream。
* 默认允许设置的header值个数是20，可以通过configmap配置**max-canary-header-val-num**调整header值个数。
* 当请求消息中不存在用于高级路由的header和header值，则路由规则不生效。
* 路由规则匹配，但用于高级路由的后端upstream不存在，则请求会被降级路由到`主域名`对应的后端upstream。

![image](/book/_images/tengine_ingress_canary.png)

### 示例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-header: test-header-val
    nginx.ingress.kubernetes.io/canary-by-header-value: h1||h2
  name: alibaba-tao-tengine-taobao-org-ingress-canary-header-value
  namespace: alibaba-ingress-tao
spec:
  ingressClassName: default-ingress-class
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

## 基于请求cookie的流量切分
> 注解名称: `nginx.ingress.kubernetes.io/canary-by-cookie`
> 值类型: `string`
> 默认值: ` `
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

基于请求cookie的高级路由
* 基于请求cookie的流量切分，当用于高级路由cookie的值等于`always`，则请求将被转发到指定的后端upstream。
* 当请求消息中不存在用于高级路由的cookie，或者cookie值不等于`always`，则路由规则不生效。
* 路由规则匹配，但用于高级路由的后端upstream不存在，则请求会被降级路由到`主域名`对应的后端upstream。
* 所谓`主域名`即Ingress资源对象中的host，全部相同host的Canary Ingress资源对象都是隶属于`主域名`的高级路由。

### 示例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-cookie: test-cookie
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: tengine-ingress-hello2-cookie-ing
  namespace: default
spec:
  ingressClassName: default-ingress-class
  rules:
  - host: echo.w1.com
    http:
      paths:
      - backend:
          service:
            name: tengine-ingress-hello2-service
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - echo.w1.com
    secretName: https-server-1
status:
  loadBalancer:
    ingress:
    - {}
```

## 基于请求cookie值的流量切分
> 注解名称: `nginx.ingress.kubernetes.io/canary-by-cookie-value`
> 值类型: `string`
> 默认值: ` `
> 值格式: `<cookie value>[||<cookie value>]*`
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

基于请求cookie值的高级路由
* 在上述基于请求cookie的高级路由基础上，可以指定具体匹配的cookie值，在cookie和cookie值完全匹配的情况下，请求将被转发到指定的后端upstream。
* Cookie值默认允许最多设置20个，只要其中1个相匹配，请求就会被转发到指定的后端upstream。
* 默认允许设置的cookie值个数是20，可以通过configmap配置**max-canary-cookie-val-num**调整cookie值个数。
* 当请求消息中不存在用于高级路由的cookie和cookie值，则路由规则不生效。
* 路由规则匹配，但用于高级路由的后端upstream不存在，则请求会被降级路由到`主域名`对应的后端upstream。

### 示例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-cookie: test-cookie-val
    nginx.ingress.kubernetes.io/canary-by-cookie-value: c1||c2||c3
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: tengine-ingress-hello2-cookie-val-ing
  namespace: default
spec:
  ingressClassName: default-ingress-class
  rules:
  - host: echo.w1.com
    http:
      paths:
      - backend:
          service:
            name: tengine-ingress-hello2-service
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - echo.w1.com
    secretName: https-server-1
status:
  loadBalancer:
    ingress:
    - {}
```

## 基于请求query参数的流量切分
> 注解名称: `nginx.ingress.kubernetes.io/canary-by-query`
> 值类型: `string`
> 默认值: ` `
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

基于请求query参数的高级路由
* 基于请求query参数的流量切分，当用于高级路由query参数的值等于`always`，则请求将被转发到指定的后端upstream。
* 当请求消息中不存在用于高级路由的query参数，或者query参数值不等于`always`，则路由规则不生效。
* 路由规则匹配，但用于高级路由的后端upstream不存在，则请求会被降级路由到`主域名`对应的后端upstream。
* 所谓`主域名`即Ingress资源对象中的host，全部相同host的Canary Ingress资源对象都是隶属于`主域名`的高级路由。

### 示例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-query: test-query
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: tengine-ingress-hello3-query-ing
  namespace: default
spec:
  ingressClassName: default-ingress-class
  rules:
  - host: echo.w1.com
    http:
      paths:
      - backend:
          service:
            name: tengine-ingress-hello3-service
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - echo.w1.com
    secretName: https-server-1
status:
  loadBalancer:
    ingress:
    - {}
```

## 基于请求query参数值的流量切分
> 注解名称: `nginx.ingress.kubernetes.io/canary-by-query-value`
> 值类型: `string`
> 默认值: ` `
> 值格式: `<query value>[||<query value>]*`
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

基于请求query参数值的高级路由
* 在上述基于请求query参数的高级路由基础上，可以指定具体匹配的query参数值，在query参数和query参数值完全匹配的情况下，请求将被转发到指定的后端upstream。
* Query参数值默认允许最多设置20个，只要其中1个相匹配，请求就会被转发到指定的后端upstream。
* 默认允许设置的query参数值个数是20，可以通过configmap配置**max-canary-query-val-num**调整cookie值个数。
* 当请求消息中不存在用于高级路由的query参数和query参数值，则路由规则不生效。
* 路由规则匹配，但用于高级路由的后端upstream不存在，则请求会被降级路由到`主域名`对应的后端upstream。

### 示例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-query: test-query-val
    nginx.ingress.kubernetes.io/canary-by-query-value: abc1||abc2||abc3||abc4||abc5||abc6||abc7||abc8||abc9||abc10||abc11||abc12||abc13||abc14||abc15||abc16||abc17||abc18||abc19
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: tengine-ingress-hello3-query-val-ing
  namespace: default
spec:
  ingressClassName: default-ingress-class
  rules:
  - host: echo.w1.com
    http:
      paths:
      - backend:
          service:
            name: tengine-ingress-hello3-service
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - echo.w1.com
    secretName: https-server-1
status:
  loadBalancer:
    ingress:
    - {}
```

## 基于header/cookie/query参数取模的流量切分
> 注解名称: `nginx.ingress.kubernetes.io/canary-mod-divisor`
> 值类型: `number`
> 值范围: `[2, 100]`
> 默认值: `0`
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

基于Header取模/Cookie取模/Query参数取模的高级路由，设置对应的取模除数

> 注解名称: `nginx.ingress.kubernetes.io/canary-mod-relational-operator`
> 值类型: `string`
> 值范围: `==  >  >=  <  <=`
> 默认值: ` `
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

基于Header取模/Cookie取模/Query参数取模的高级路由，设置对应的取模关系运算符

> 注解名称: `nginx.ingress.kubernetes.io/canary-mod-remainder`
> 值类型: `number`
> 值范围: `[0, 取模除数)`
> 默认值: `0`
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

基于Header取模/Cookie取模/Query参数取模的高级路由，设置对应的取模余数

### 基于header取模的流量切分
* 基于请求header取模的流量切分，可以指定具体匹配的header，当header值取模运算得到余数满足关系运算符的匹配条件，则将请求转发到指定的后端upstream。
* 如果 [header值] mod [除数] 关系运算符 [余数] 为真，那么路由规则生效，请求就会被转发到指定的后端upstream。
* 如果除数，关系运算符和余数的取值范围非法，则路由规则降级为基于请求header的流量切分。
* 路由规则匹配，但用于高级路由的后端upstream不存在，则请求会被降级路由到主域名对应的后端upstream。

#### 示例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-header: test-header-mod
    nginx.ingress.kubernetes.io/canary-mod-divisor: "100"
    nginx.ingress.kubernetes.io/canary-mod-relational-operator: ==
    nginx.ingress.kubernetes.io/canary-mod-remainder: "1"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: tengine-ingress-echo2-header-mod-ing
  namespace: default
spec:
  ingressClassName: default-ingress-class
  rules:
  - host: echo.w1.com
    http:
      paths:
      - backend:
          service:
            name: tengine-ingress-echo2-service
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - echo.w1.com
    secretName: https-server-1
status:
  loadBalancer:
    ingress:
    - {}
```

### 基于cookie取模的高级路由**
* 基于请求cookie取模的流量切分，可以指定具体匹配的cookie，当cookie值取模运算得到余数满足关系运算符的匹配条件，则将请求转发到指定的后端upstream。
* 如果 [cookie值] mod [除数] 关系运算符 [余数] 为真，那么路由规则生效，请求就会被转发到指定的后端upstream。
* 如果除数，关系运算符和余数的取值范围非法，则路由规则降级为基于请求cookie的流量切分。
* 路由规则匹配，但用于高级路由的后端upstream不存在，则请求会被降级路由到主域名对应的后端upstream。

#### 示例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-cookie: test-cookie-mod
    nginx.ingress.kubernetes.io/canary-mod-divisor: "100"
    nginx.ingress.kubernetes.io/canary-mod-relational-operator: '>'
    nginx.ingress.kubernetes.io/canary-mod-remainder: "5"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: tengine-ingress-echo3-cookie-mod-ing
  namespace: default
spec:
  ingressClassName: default-ingress-class
  rules:
  - host: echo.w1.com
    http:
      paths:
      - backend:
          service:
            name: tengine-ingress-echo3-service
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - echo.w1.com
    secretName: https-server-1
status:
  loadBalancer:
    ingress:
    - {}
```

### 基于query参数取模的高级路由**
* 基于请求query参数取模的流量切分，可以指定具体匹配的query参数，当query参数值取模运算得到余数满足关系运算符的匹配条件，则将请求转发到指定的后端upstream。
* 如果 [query参数值] mod [除数] 关系运算符 [余数] 为真，那么路由规则生效，请求就会被转发到指定的后端upstream。
* 如果除数，关系运算符和余数的取值范围非法，则路由规则降级为基于请求query参数的流量切分。
* 路由规则匹配，但用于高级路由的后端upstream不存在，则请求会被降级路由到主域名对应的后端upstream。

#### 示例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-query: test-query-mod
    nginx.ingress.kubernetes.io/canary-mod-divisor: "100"
    nginx.ingress.kubernetes.io/canary-mod-relational-operator: <
    nginx.ingress.kubernetes.io/canary-mod-remainder: "8"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: tengine-ingress-hello4-query-mod-ing
  namespace: default
spec:
  ingressClassName: default-ingress-class
  rules:
  - host: echo.w1.com
    http:
      paths:
      - backend:
          service:
            name: tengine-ingress-hello4-service
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - echo.w1.com
    secretName: https-server-1
status:
  loadBalancer:
    ingress:
    - {}
```

## 流量染色
### 在请求消息中增加header
> 注解名称: `nginx.ingress.kubernetes.io/canary-request-add-header`
> 值类型: `string`
> 值格式: `<header name>:<header value>[||<header name>:<header value>]*`
> 默认值: ` `
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

基于Canary Ingress高级路由，在请求消息中增加header
* 如果存在相同的header名，重复添加
* header以`||`分割，`<header name>`和`<header value>`以`:`分割，`<header name>`和`<header value>`不允许包含`:`和`||`，默认最多允许增加2个header
* 可以通过configmap配置**max-canary-req-add-header-num**调整请求消息中流量染色增加的header个数
* `<header value>`: header值 或 nginx变量
* `nginx变量`: `$变量名`

#### 示例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-header: test-header-mod-with-action
    nginx.ingress.kubernetes.io/canary-mod-divisor: "100"
    nginx.ingress.kubernetes.io/canary-mod-relational-operator: ==
    nginx.ingress.kubernetes.io/canary-mod-remainder: "1"
    nginx.ingress.kubernetes.io/canary-request-add-header: test-result:B0-236-564-29117||test-ssl-cipher:$ssl_cipher
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: tengine-ingress-echo2-header-mod-with-action-ing
  namespace: default
spec:
  ingressClassName: default-ingress-class
  rules:
  - host: echo.w1.com
    http:
      paths:
      - backend:
          service:
            name: tengine-ingress-echo2-service
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - echo.w1.com
    secretName: https-server-1
status:
  loadBalancer:
    ingress:
    - {}
```

### 在请求消息的header中追加header值
> 注解名称: `nginx.ingress.kubernetes.io/canary-request-append-header`
> 值类型: `string`
> 值格式: `<header name>:<header value>[||<header name>:<header value>]*`
> 默认值: ` `
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

基于Canary Ingress高级路由，在请求消息的header中追加header值
* 如果存在相同的header名，在已有的header值后增加`,`分割符，再追加header值
* 如果请求消息的header不存在，则直接增加
* header以`||`分割，`<header name>`和`<header value>`以`:`分割，`<header name>`和`<header value>`不允许包含`:`和`||`，默认最多允许追加2个header
* 可以通过configmap配置**max-canary-req-append-header-num**调整请求消息中流量染色追加的header个数
* `<header value>`：header值 或 nginx变量
* `nginx变量`: `$变量名`

#### 示例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-query: test-query-with-action
    nginx.ingress.kubernetes.io/canary-by-query-value: abc1||abc2||abc3||abc4||abc5||abc6||abc7||abc8||abc9||abc10||abc11||abc12||abc13||abc14||abc15||abc16||abc17||abc18||abc19||abc20
    nginx.ingress.kubernetes.io/canary-request-append-header: UserData:user=236-564-29121||test-ssl-protocol:$ssl_protocol
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: tengine-ingress-hello3-query-with-action-ing
  namespace: default
spec:
  ingressClassName: default-ingress-class
  rules:
  - host: echo.w1.com
    http:
      paths:
      - backend:
          service:
            name: tengine-ingress-hello3-service
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - echo.w1.com
    secretName: https-server-1
status:
  loadBalancer:
    ingress:
    - {}
```

### 在请求消息中增加query参数
> 注解名称: `nginx.ingress.kubernetes.io/canary-request-add-query`
> 值类型: `string`
> 值格式: `<query name>=<query value>[&<query name>=<query value>]*`
> 默认值: ` `
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

基于Canary Ingress高级路由，在请求消息中增加query参数
* 如果存在相同的query参数，重复添加
* Query参数以`&`分割，`<query name>`和`<query value>`以`=`分割，`<query name>`和`<query value>`不允许包含`=`和`&`，默认最多允许增加2个query参数
* 可以通过configmap配置**max-canary-req-add-query-num**调整请求消息中流量染色增加的query参数个数
* `<query value>`：query参数值 或 nginx变量
* `nginx变量`: `$变量名`

#### 示例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-query: test-cookie1-with-action
    nginx.ingress.kubernetes.io/canary-by-query-value: k1||k2||k3
    nginx.ingress.kubernetes.io/canary-request-add-query: test-query=query2&test-host=$host
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: tengine-ingress-hello6-cookie1-with-action-ing
  namespace: default
spec:
  ingressClassName: default-ingress-class
  rules:
  - host: echo.w1.com
    http:
      paths:
      - backend:
          service:
            name: tengine-ingress-hello6-service
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - echo.w1.com
    secretName: https-server-1
status:
  loadBalancer:
    ingress:
    - {}
```

### 在响应消息中增加header
> 注解名称: `nginx.ingress.kubernetes.io/canary-response-add-header`
> 值类型: `string`
> 值格式: `<header name>:<header value>[||<header name>:<header value>]*`
> 默认值: ` `
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

基于Canary Ingress高级路由，在响应消息中增加header
* 如果存在相同的header名，重复添加
* Header以`||`分割，`<header name>`和`<header value>`以`:`分割，`<header name>`和`<header value>`不允许包含`:`和`||`，默认最多允许增加2个header
* 可以通过configmap配置**max-canary-resp-add-header-num**调整响应消息中流量染色增加的header个数
* `<header value>`：header值 或 nginx变量
* `nginx变量`: $变量名

#### 示例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-cookie: test-cookie2-with-action
    nginx.ingress.kubernetes.io/canary-by-cookie-value: c1||c2
    nginx.ingress.kubernetes.io/canary-response-add-header: test-result:564-29122||test-result-host:$host
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: tengine-ingress-hello2-cookie2-with-action-ing
  namespace: default
spec:
  ingressClassName: default-ingress-class
  rules:
  - host: echo.w1.com
    http:
      paths:
      - backend:
          service:
            name: tengine-ingress-hello2-service
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - echo.w1.com
    secretName: https-server-1
status:
  loadBalancer:
    ingress:
    - {}
```

## 基于服务权重的流量切分
> 注解名称: `nginx.ingress.kubernetes.io/canary-weight`
> 值类型: `string`
> 默认值: ` `
> 注解类型: `canary ingress注解`
> 生效维度: `域名` 或 `域名/path`

基于服务权重的高级路由
* 基于服务权重的流量切分，其优先级低于上述基于请求header，cookie和query参数的高级路由
* 默认优先级从高到低依次为 Header&Header值&Header取模 --> Cookie&Cookie值&Cookie取模 --> Query参数&Query参数值&Query参数取模 --> 服务权重；
* 多个Header (含Header&Header值&Header取模) 高级路由规则之间的默认优先级按照高级路由的添加顺序从高到低排序，Cookie (Cookie&Cookie值&Cookie取模)和Query参数 (Query参数&Query参数值&Query参数取模) 采用相同的优先级排序规则。
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
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "20"
  name: alibaba-tao-tengine-taobao-org-ingress-canary-weight
  namespace: default
spec:
  ingressClassName: default-ingress-class
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

> 注解名称: `nginx.ingress.kubernetes.io/canary-weight-total`
> 值类型: `number`
> 值范围: `[100, 10000]`
> 默认值: `100`
> 注解类型: `ingress注解`
> 生效维度: `域名`

服务权重总和
* 如果调整服务权重总和，域名的所有基于服务权重的高级路由将重新基于新的服务权重总和计算其服务权重值。
* 例如：域名tengine.taobao.org，service=tengine-taobao-org-service-c；基于服务权重的高级路由：服务权重=20，service=tengine-taobao-org-service-canary-c
* 默认服务权重总和=100，则20%请求被转发到service=tengine-taobao-org-service-canary-c，其它99%请求会被转发到主域名对应的service=tengine-taobao-org-service-c
* 如果修改服务权重总和=1000，则2%请求被转发到service=tengine-taobao-org-service-canary-c，其它98%请求会被转发到主域名对应的service=tengine-taobao-org-service-c

### 示例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/canary-weight-total: "1000"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: alibaba-tao-tengine-taobao-org-ingress
  namespace: default
spec:
  ingressClassName: default-ingress-class
  rules:
  - host: tengine.taobao.org
    http:
      paths:
      - backend:
          service:
            name: tengine-taobao-org-service-c
            port:
              number: 80
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