# Ingress分批次动态生效

K8s原生资源对象ingress域名在被写入etcd后，所有监听控制器默认都会处理资源对象的配置更新，即相同命名空间内的所有Pod会同时加载新的配置对象，如果配置存在错误和脏数据，变更影响将会触发全局风险。
`Tengine-Ingress`作为云原生网关，通过K8s API处理和验证资源对象，扩展支持ingress应用域名的灰度能力，保障变更操作的可灰度，可中断和可回滚。

**注意：为了使用Ingress域名资源对象的分批次滚动生效功能，Tengine-Ingress需要以StatefulSet形式部署发布。**

## 注解
> 注解名称: `nginx.ingress.kubernetes.io/ingress-rollout`
> 值类型: `true` 或 `false`
> 默认值: `false`
> 注解类型: `ingress注解`
> 生效维度: `域名` 或 `域名/path`

Ingress资源对象分批次滚动生效开关
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
* 网关`Tengine-Ingress`集群需要以StatefulSet形式部署发布，0..N-1为Tengine-Ingress的Pod序号，从0开始到N-1结束。
* 注解`ingress-rollout-index-id`标识了本次灰度生效的Pod个数。
* 只有Pod序号小于`ingress-rollout-index-id`的Tengine-Ingress实例才会动态更新ingress资源对象。

## 示例

例如：网关`Tengine-Ingress`集群有10个实例，则Tengine-Ingress的Pod序号的为0..9。
* `ingress-rollout-index-id: "1"`，灰度生效Tengine-Ingress Pod序号为0的实例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/ingress-rollout: "true"
    nginx.ingress.kubernetes.io/ingress-rollout-index-id: "1"
    nginx.ingress.kubernetes.io/ingress-rollout-current-revision: ingress-revision-0cfoyid0ze
    nginx.ingress.kubernetes.io/ingress-rollout-update-revision: ingress-revision-1cfoyid0ze
```

* `ingress-rollout-index-id: "4"`，灰度生效Tengine-Ingress Pod序号为1，2和3的实例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/ingress-rollout: "true"
    nginx.ingress.kubernetes.io/ingress-rollout-index-id: "4"
    nginx.ingress.kubernetes.io/ingress-rollout-current-revision: ingress-revision-0cfoyid0ze
    nginx.ingress.kubernetes.io/ingress-rollout-update-revision: ingress-revision-1cfoyid0ze
```

* `ingress-rollout-index-id: "7"`，灰度生效Tengine-Ingress Pod序号为4，5和6的实例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/ingress-rollout: "true"
    nginx.ingress.kubernetes.io/ingress-rollout-index-id: "7"
    nginx.ingress.kubernetes.io/ingress-rollout-current-revision: ingress-revision-0cfoyid0ze
    nginx.ingress.kubernetes.io/ingress-rollout-update-revision: ingress-revision-1cfoyid0ze
```

* `ingress-rollout-index-id: "10"`，灰度生效Tengine-Ingress Pod序号为7，8和9的实例
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/ingress-rollout: "true"
    nginx.ingress.kubernetes.io/ingress-rollout-index-id: "10"
    nginx.ingress.kubernetes.io/ingress-rollout-current-revision: ingress-revision-1cfoyid0ze
    nginx.ingress.kubernetes.io/ingress-rollout-update-revision: ingress-revision-1cfoyid0ze
```
