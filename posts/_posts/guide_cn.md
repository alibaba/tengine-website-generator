## 教程
Tengine-Ingress完全兼容云原生[ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)标准规范，用户可参照[kubernetes ingress-nginx](https://kubernetes.github.io/ingress-nginx/)相关文档。

在此列出[Tengine-Ingress](https://github.com/alibaba/tengine-ingress)原生扩展和增强功能的使用和配置教程。 

关于详细的[Tengine-Ingress](https://github.com/alibaba/tengine-ingress)与ingress-nginx的差别，可以访问[变更列表](changelog_ingress_cn.html)。

### 编译
*   [编译](document_cn/ingress_install_cn.html)

### 快速开始
*   [Tengine-Ingress快速开始](document_cn/ingress_quickstart_cn.html)

### 配置文档
*   [全局配置Configmap](document_cn/ingress_configmap_cn.html)
*   [高级注解配置Annotations](document_cn/ingress_annotations_cn.html)
*   [自定义资源CRD](document_cn/ingress_crd_cn.html)

### 使用教程
*   [动态无损生效](document_cn/ingress_hotreload_cn.html)
*   [高级路由](document_cn/ingress_routes_cn.html) 
*   [ECC和RSA多证书](document_cn/ingress_certs_cn.html)
*   [分域名TLS协议多版本](document_cn/ingress_tls_protocols_cn.html) 
*   [TLS端口映射默认证书](document_cn/ingress_tls_port_cert_cn.html) 
*   [Ingress分批次动态生效](document_cn/ingress_rollout_ingress_cn.html)
*   [Secret分批次动态生效](document_cn/ingress_rollout_secret_cn.html)
*   [Ingress全局一致性校验](document_cn/ingress_checksum_ingress_cn.html)
*   [Secret全局一致性校验](document_cn/ingress_checksum_secret_cn.html)
*   [独立K8s存储集群](document_cn/ingress_cluster_cn.html)
