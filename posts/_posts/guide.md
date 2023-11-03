## 教程
Tengine-Ingress完全兼容云原生[ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)标准规范，用户可参照[kubernetes ingress-nginx](https://kubernetes.github.io/ingress-nginx/)相关文档。

在此列出[Tengine-Ingress](https://github.com/alibaba/tengine-ingress)原生扩展和增强功能的使用和配置教程。 

### 编译
*   [编译](document/ingress_install.html)

### 快速开始
*   [Tengine-Ingress快速开始](document/ingress_quickstart.html)

### 配置文档
*   [全局配置Configmap](document/ingress_configmap.html)
*   [高级注解配置Annotations](document/ingress_annotations.html)
*   [自定义资源CRD](document/ingress_crd.html)

### 使用教程
*   [动态无损生效](document/ingress_hotreload.html)
*   [高级路由](document_cn/ingress_routes.html) 
*   [ECC和RSA多证书](document/ingress_certs.html)
*   [分域名TLS协议多版本](document_cn/ingress_tls_protocols.html) 
*   [TLS端口映射默认证书](document_cn/ingress_tls_port_cert.html) 
*   [Ingress分批次动态生效](document/ingress_rollout_ingress.html)
*   [Secret分批次动态生效](document/ingress_rollout_secret.html)
*   [Ingress全局一致性校验](document/ingress_checksum_ingress.html)
*   [Secret全局一致性校验](document/ingress_checksum_secret.html)
*   [独立K8s存储集群](document/ingress_cluster.html)
