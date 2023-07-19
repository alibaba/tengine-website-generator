# Tengine-Ingress

Tengine-Ingress完全兼容云原生[ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)标准规范，用户可参照[kubernetes ingress-nginx](https://kubernetes.github.io/ingress-nginx/)相关文档。
在此列出[Tengine-Ingress](https://github.com/alibaba/tengine-ingress)原生扩展和增强功能的Prometheus统计指标。 

## Prometheus

> 指标名称: `nginx_ingress_controller_ing_checksum_success`
> 指标类型: `Counter`

如果Ingress全局一致性校验成功，则累加指标。

---

> 指标名称: `nginx_ingress_controller_ing_checksum_errors`
> 指标类型: `Gauge`

如果Ingress全局一致性校验失败，则累加指标。
在Ingress全局一致性校验成功后，指标即刻清零。

---

> 指标名称: `nginx_ingress_controller_secret_checksum_success`
> 指标类型: `Counter`

如果Secret全局一致性校验成功，则累加指标。

---

> 指标名称: `nginx_ingress_controller_secret_checksum_errors`
> 指标类型: `Gauge`

如果Secret全局一致性校验失败，则累加指标。
在Secret全局一致性校验成功后，指标即刻清零。

---

> 指标名称: `nginx_ingress_controller_sslcert_verify_fail`
> 指标类型: `Counter`

SSL证书校验失败
当Secret资源对象不符合[X509证书规范](https://datatracker.ietf.org/doc/html/rfc5280)，则证书校验失败，需要累加指标。

---

> 指标名称: `nginx_ingress_controller_ing_referrer_verify_fail`
> 指标类型: `Counter`

Ingress资源对象来源异常
注解`nginx.ingress.kubernetes.io/ingress-referrer`用于标识Ingress资源对象的来源。
网关`Tengine-Ingress`基于configmap的配置`ingress-referrer`，校验Ingress资源对象的来源是否在授权允许创建Ingress资源对象的应用列表中。
注解ingress-referrer值非空，且不在configmap配置`ingress-referrer`授权应用列表中，则Ingress资源对象来源异常，需要累加指标。

---

> 指标名称: `nginx_ingress_controller_canary_referrer_verify_fail`
> 指标类型: `Counter`

Canary Ingress资源对象来源异常
注解`nginx.ingress.kubernetes.io/canary-referrer`用于标识Canary Ingress资源对象的来源。
网关`Tengine-Ingress`基于configmap的配置`canary-referrer`，校验Canary Ingress资源对象的来源是否在授权允许创建Canary Ingress资源对象的应用列表中。
注解canary-referrer值非空，且不在configmap配置`canary-referrer`授权应用列表中，则Canary Ingress资源对象来源异常，需要累加指标。 

---

> 指标名称: `nginx_ingress_controller_canary_num_limit_exceeded`
> 指标类型: `Counter`

Configmap配置`max-canary-ing-num`默认每个Ingress域名允许最多创建200个高级路由，每个高级路由都是独立的Canary Ingress资源对象。
如果某个Ingress域名对应的Canary Ingress资源对象超过200个，则累加指标。
