# Tengine-Ingress ECC和RSA多证书

`Tengine-Ingress`支持域名同时使用ECC和RSA双证书，默认原生系统只能使用单张证书，Tengine-Ingress扩展标准ingress规范，在兼容单证书的场景下，满足ECC和RSA双证书同时动态生效的应用场景，且可以继续扩展为ECC，RSA和国密的三证书复杂场景。

```yaml
  tls:
  - hosts:
    - {host1}
    secretName: {secret name1}
  - hosts:
    - {host1}
    secretName: {secret name2}
```

## 示例

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: alibaba-tao-tengine-taobao-org-ingress
  namespace: alibaba-ingress-tao
spec:
  ingressClassName: default-ingress-class
  rules:
  - host: tengine.taobao.org
    http:
      paths:
      - backend:
          service:
            name: tengine-taobao-org-service
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
