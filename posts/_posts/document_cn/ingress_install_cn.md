# 编译

Tengine-Ingress由两部分组成，[Tengine-Ingress控制器](https://github.com/alibaba/tengine-ingress)和[Tengine-proxy](https://github.com/alibaba/tengine)。Tengine-Ingress控制器是一个基于Tengine-proxy的ingress控制器，在兼容云原生[ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)标准规范的基础上扩展了Server，Backend，TLS，Location和Canary。

Tengine-Ingress控制器通过订阅和处理ingress域名资源和secret证书资源，基于tengine ingress模板转换为动态配置写入共享内存。Tengine-proxy订阅共享内存变化写入内部运行时共享内存，将终端用户的外部流量路由到K8s集群中的应用服务。

![image](/book/_images/tengine_ingress_container.png)

```bash
# ./build.sh tengine
# ./build.sh ingress
```

## 构建tengine-proxy镜像

```bash
# ./build.sh tengine
```

## 构建tengine-ingress镜像

在tengine-proxy镜像基础上，构建tengine-ingress镜像

```bash
# ./build.sh ingress
```

最后，使用tengine-ingress镜像部署您的网关。

## 启动模板
```yaml
containers:
- args:
  - "/home/admin/start.sh"
  - "$(POD_NAMESPACE)"
  - "${DEPLOYMENT_NAME}"
```
* $(POD_NAMESPACE): `Tengine-Ingress`集群所在命名空间；
* ${DEPLOYMENT_NAME}: 部署`Tengine-Ingress`集群的deployment或statefulset的名称。

## 启动脚本
* /home/admin/start.sh
```shell
/usr/bin/dumb-init -- /tengine-ingress-controller --configmap=${1}/${2}-nginx-configuration --tcp-services-configmap=${1}/${2}-tcp-services --udp-services-configmap=${1}/${2}-udp-services --annotations-prefix=nginx.ingress.kubernetes.io --v=${log_level} --kubeconfig=${ing_kubeconfig} --watch-namespace=${watch_namespace} --ingress-class=${ingress_class} &
```

## 启动命令行参数

> 参数名称: `--configmap`
> 参数值: `${1}/${2}-nginx-configuration`

`Tengine-Ingress`的全局配置
* 参数${1}: `Tengine-Ingress`集群所在命名空间；
* 参数${2}：部署`Tengine-Ingress`集群的deployment或statefulset的名称。

---

> 参数名称: `--tcp-services-configmap`
> 参数值: `${1}/${2}-nginx-configuration`

TCP服务配置
* 参数${1}: `Tengine-Ingress`集群所在命名空间；
* 参数${2}：部署`Tengine-Ingress`集群的deployment或statefulset的名称。

---

> 参数名称: `--udp-services-configmap`
> 参数值: `${1}/${2}-nginx-configuration`

UDP服务配置
* 参数${1}: `Tengine-Ingress`集群所在命名空间；
* 参数${2}：部署`Tengine-Ingress`集群的deployment或statefulset的名称。

---

> 参数名称: `--annotations-prefix`
> 默认值: `nginx.ingress.kubernetes.io`

设置`Tengine-Ingress`注解的默认前缀，默认前缀为`nginx.ingress.kubernetes.io`。

---

> 参数名称: `--v`
> 参数值: `${log_level}`
> 值类型: `环境变量log_level`

设置`Tengine-Ingress`的日志级别，日志级别范围1..5，最大日志级别5属于debug模式。
通过环境变量`log_level`设置日志级别。

---

> 参数名称: `--kubeconfig`
> 参数值: `${ing_kubeconfig}`
> 值类型: `环境变量ing_kubeconfig`

`Tengine-Ingress`支持K8s core集群与K8s ingress存储集群相隔离的高可靠性部署方案，将运行态和存储态相分离，独立K8s ingress集群可以保证自身API服务器和etcd性能稳定，并且在core集群核心组件API服务器和etcd不可用的高危场景下也能正常向外提供7层转发服务。
通过环境变量`ing_kubeconfig`设置K8s ingress存储集群的kubeconfig。

---

> 参数名称: `--watch-namespace`
> 参数值: `${watch_namespace}`
> 值类型: `环境变量watch_namespace`

设置`Tengine-Ingress`监听处理的命名空间
* `Tengine-Ingress`只监听处理环境变量`watch_namespace`指定命名空间下的K8s资源对象。
* K8s资源对象包括Ingress，Secret，Service等相关配置资源。
* 如果环境变量`watch_namespace`为空，则监听所有命名空间下的资源对象。

---

> 参数名称: `--ingress-class`
> 参数值: `${ingress_class}`
> 值类型: `环境变量ingress_class`

设置`Tengine-Ingress`监听处理Ingress资源对象的类别
* `Tengine-Ingress`只监听处理环境变量`ingress_class`指定类别的Ingress资源对象。
* Ingress资源对象通过注解`kubernetes.io/ingress.class`标识其类别。
* 如果环境变量`ingress_class`为空，则监听所有类别的Ingress资源对象。
