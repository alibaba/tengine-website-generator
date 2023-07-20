# 动态无损生效

**`Tengine-Ingress`在Tengine基础上新增很多新特性和功能，最显著的变化是配置动态无损生效，无论是应用域名新增和路由变更，还是证书新增和加签域名，都无需tengine reload，配置无损实时生效，长连接保持不变，成功率不受影响，应用变更效率提升翻倍，集群稳定性进一步得到增强。**

Tengine-Ingress由两部分组成：
* [Tengine-Ingress控制器](https://github.com/alibaba/tengine-ingress)
* [Tengine-proxy](https://github.com/alibaba/tengine)

`Tengine-Ingress`控制器是一个基于Tengine-proxy的ingress控制器，在兼容云原生[ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)标准规范的基础上扩展了Server，Backend，TLS，Location和Canary。

`Tengine-Ingress`控制器通过订阅和处理ingress域名资源和secret证书资源，基于tengine ingress模板转换为动态配置写入共享内存。Tengine-proxy订阅共享内存变化写入内部运行时共享内存，将终端用户的外部流量路由到K8s集群中的应用服务。

![image](/book/_images/tengine_ingress_container.png)

`Tengine-Ingress`支持域名和证书接入的无损动态实时生效，`Tengine-Ingress`控制器实时监听ASI ingress存储集群中的ingress域名和secret证书资源对象，在ingress域名和secret证书配置发生变化时，校验域名和证书配置的合法性和全局一致性，符合[ingress标准](https://kubernetes.io/docs/concepts/services-networking/ingress/)和[X509证书规范](https://datatracker.ietf.org/doc/html/rfc5280)的配置信息将全量写入系统共享内存。Tengine-proxy感知系统共享内存变更，strategy进程刷新运行时共享内存，双缓存切换，worker进程运行时读取配置动态生效。

![image](/book/_images/tengine_ingress_dynamic.png)

## 支持动态生效的场景
* 新增，更新和删除Ingress资源对象
* 新增，更新和删除Secret资源对象
* 高级注解配置[Annotations](ingress_annotations.html)
* 自定义资源[CRD](ingress_crd.html)
