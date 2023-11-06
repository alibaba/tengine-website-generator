# Tengine-Ingress 分域名TLS协议多版本

`Tengine-Ingress`支持不同域名配置不同的TLS协议版本，以满足分域名的不同安全级别和需求。

> 注解名称: `nginx.ingress.kubernetes.io/ssl-protocols`
> 值类型: `string`
> 默认值: ` `
> 值格式：`<TLS版本>[ <TLS版本>]*`
> 值校验：`以' '分割，只允许TLSv1 TLSv1.1 TLSv1.2 TLSv1.3`
> 注解类型: `ingress注解`
> 生效维度: `域名`

允许的TLS协议版本
* 每个Ingress资源对象设置允许的TLS协议版本
* 例如：nginx.ingress.kubernetes.io/ssl-protocols: TLSv1.2 TLSv1.3，仅允许使用TLSv1.2和TLSv1.3访问应用域名
* 例如：nginx.ingress.kubernetes.io/ssl-protocols: TLSv1.3，仅允许使用TLSv1.3访问应用域名


## 示例
* 全局SSL协议版本配置
```
ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
```

* 分域名Ingress资源对象
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/ssl-protocols: TLSv1.2 TLSv1.3
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: tengine-ingress-echo-ing
  namespace: default
spec:
  ingressClassName: default-ingress-class
  rules:
  - host: echo.w1.com
    http:
      paths:
      - backend:
          service:
            name: tengine-ingress-echo-service
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

* 基于上述示例，只允许使用TLSv1.2和TLSv1.3访问应用域名echo.w1.com

```
$ curl -i --tlsv1.0 --tls-max 1.0 https://echo.w1.com
curl: (35) error:1409442E:SSL routines:ssl3_read_bytes:tlsv1 alert protocol version

$ curl -i --tlsv1.1 --tls-max 1.1 https://echo.w1.com
curl: (35) error:1409442E:SSL routines:ssl3_read_bytes:tlsv1 alert protocol version

$ curl -i --tlsv1.2 --tls-max 1.2 https://echo.w1.com
HTTP/2 200 
server: Tengine/3.1.0
date: Thu, 02 Nov 2023 07:05:11 GMT
content-type: text/plain; charset=utf-8
content-length: 7
strict-transport-security: max-age=31536000
ups-target-key: default-tengine-ingress-echo-service-80
x-protocol: HTTP/2.0
alt-svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000

echo ok

$ curl -i --tlsv1.3 --tls-max 1.3 https://echo.w1.com
HTTP/2 200 
server: Tengine/3.1.0
date: Thu, 02 Nov 2023 07:05:19 GMT
content-type: text/plain; charset=utf-8
content-length: 7
strict-transport-security: max-age=31536000
ups-target-key: default-tengine-ingress-echo-service-80
x-protocol: HTTP/2.0
alt-svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000

echo ok
```