# Tengine-Ingress

Tengine以高性能和高可用著称，但Tengine的一些限制却一直为人诟病，最典型的就是应用域名新增和更新无法动态生效；新增证书和加签域名无法动态生效；用户侧HTTP(S)流量可配置性和可观测性能力弱；HTTP(S)路由能力弱；不支持应用分域名灰度变更等。随着云原生ingress入口网关规范的事实标准化以及K8s的大范围应用，Tengine-Ingress基于云原生ingress标准实现了对Tengine的架构升级，在深度优化kubernetes/ingress-nginx基础上融合Tengine-proxy，不断提升自身性能和可用性，彻底根除了上述痛点和问题，并反哺Tengine开源社区，持续保持Tengine业界领先地位。

## 架构
Tengine-Ingress由两部分组成，[Tengine-Ingress控制器](https://github.com/alibaba/tengine-ingress)和[Tengine-proxy](https://github.com/alibaba/tengine)。Tengine-Ingress控制器是一个基于Tengine-proxy的ingress控制器，在兼容云原生[ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)标准规范的基础上扩展了Server，Backend，TLS，Location和Canary。

Tengine-Ingress控制器通过订阅和处理ingress域名资源和secret证书资源，基于tengine ingress模板转换为动态配置写入共享内存。Tengine-proxy订阅共享内存变化写入内部运行时共享内存，将终端用户的外部流量路由到K8s集群中的应用服务。

Tengine-Ingress在Tengine基础上新增很多新特性和功能，最显著的变化是配置动态无损生效，无论是应用域名新增和路由变更，还是证书新增和加签域名，都**无需tengine reload**，配置无损实时生效，长连接保持不变，成功率不受影响，应用变更效率提升翻倍，集群稳定性进一步得到增强。支持分域名和单证书独立分批次逐级生效，用户可按需中断和继续变更，应用侧风险可控，变更影响面小。TLS加解密允许同时加载ECC，RSA和国密多证书。在应用域名灰度方面，支持基于request header，header值，header值正则匹配，cookie和权重的流量切分，满足应用在灰度发布，蓝绿部署和A/B测试不同场景的需求。在可观测性方面，支持应用分域名独立监控，用户可实时查看单域名QPS，成功率，RT和报文大小相关的监控信息。Tengine-Ingress复用k8s ingress注解（高级配置）规范，基于内部运行时共享内存，通过tengine ingress模板构造HTTP(S)高级功能，支持动态无损实时生效，满足用户基于不同应用场景下的HTTP(S)高级配置需求，例如用户可配置应用域名是否允许网络爬虫和应用域名CORS (跨域资源共享)。综上所述，Tengine-Ingress在应用配置更新模型，系统稳定性，TLS加解密，灰度路由，可观测，HTTP(S)高级配置等多方面得到了显著提升。

![image](/book/_images/tengine_ingress_container.png)

## 云原生
Tengine-Ingress全面兼容K8s [ingress标准](https://kubernetes.io/docs/concepts/services-networking/ingress/)，在此基础上不断扩展和完善，相对于原生Kubernetes Ingress和NGINX Ingress，主要有以下优点和增强：

1. 支持域名和证书接入的无损动态实时生效，Tengine-Ingress控制器实时监听ASI ingress存储集群中的ingress域名和secret证书资源对象，在ingress域名和secret证书配置发生变化时，校验域名和证书配置的合法性和全局一致性，符合[ingress标准](https://kubernetes.io/docs/concepts/services-networking/ingress/)和[X509证书规范](https://datatracker.ietf.org/doc/html/rfc5280)的配置信息将全量写入系统共享内存。Tengine-proxy感知系统共享内存变更，strategy进程刷新运行时共享内存，双缓存切换，worker进程运行时读取配置动态生效。

![image](/book/_images/tengine_ingress_dynamic.png)

2. Tengine-Ingress支持域名同时使用ECC和RSA双证书，默认原生系统只能使用单张证书，Tengine-Ingress扩展标准ingress规范，在兼容单证书的场景下，满足ECC和RSA双证书同时动态生效的应用场景，且可以继续扩展为ECC，RSA和国密的三证书复杂场景。
```yaml
  tls:
  - hosts:
    - {host1}
    secretName: {secret name1}
  - hosts:
    - {host1}
    secretName: {secret name2}
```

3. Tengine-Ingress在基于云原生ASI的基础上，利用标准化的k8s资源ingress和secret分别存储域名路由配置和TLS证书秘钥信息，在此基础上提出单个ingress域名和单张secret证书分批次逐级生效机制，这不仅满足了用户侧新增和修改应用域名和证书的灰度需求，同时保障接入层集群整体运行的稳定性和可靠性。新增下述ingress和secret注解，用于标识域名和证书逐级分批次灰度生效范围。
**注意：为了使用Ingress和Secret资源对象的分批次滚动生效功能，Tengine-Ingress需要以StatefulSet形式部署发布。**
```yaml
1. ingress灰度开关
● annotation: nginx.ingress.kubernetes.io/ingress-rollout
注释：是否灰度ingress
值类型：bool
默认值：false

2. ingress当前版本
● annotation: nginx.ingress.kubernetes.io/ingress-rollout-current-revision
注释：ingress当前运行版本号
值类型：string
默认值：""

3. ingress升级版本
● annotation: nginx.ingress.kubernetes.io/ingress-rollout-update-revision
注释：ingress升级版本号
值类型：string
默认值：""

4. ingress灰度范围
● annotation: nginx.ingress.kubernetes.io/ingress-rollout-index-id
注释：只有Pod序号小于ingress-rollout-index-id的Pod才会更新ingress。
○ 0..N-1为Pod所在的序号，从0开始到N-1。
○ For a StatefulSet with N replicas, each Pod in the StatefulSet will be assigned an integer ordinal, from 0 up through N-1, that is unique over the Set.
值类型：number
默认值：-1

5. secret灰度开关
● annotation: nginx.ingress.kubernetes.io/secret-rollout
注释：是否灰度secret
值类型：bool
默认值：false

6. secret当前版本
● annotation: nginx.ingress.kubernetes.io/secret-rollout-current-revision
注释：secret当前运行版本号
值类型：string
默认值：""

7. secret升级版本
● annotation: nginx.ingress.kubernetes.io/secret-rollout-update-revision
注释：secret升级版本号
值类型：string
默认值：""

8. secret灰度范围
● annotation: nginx.ingress.kubernetes.io/secret-rollout-index-id
注释：只有Pod序号小于secret-rollout-index-id的Pod才会更新secret。
○ 0..N-1为Pod所在的序号，从0开始到N-1。
○ For a StatefulSet with N replicas, each Pod in the StatefulSet will be assigned an integer ordinal, from 0 up through N-1, that is unique over the Set.
值类型：number
默认值：-1
```

4. Tengine-Ingress通过全局一致性校验机制保障内存中运行态持有的用户侧ingress域名和secret证书的有效性和正确性，快速校验10w+域名和1000+泛证书，在域名配置和证书信息不符合标准化k8s资源ingress和secret规范及其相关RFC标准时，将不再更新本地缓存，并实时告警通知，保障运行态永远可正常向外提供7层转发服务。新增CRD IngressCheckSum和SecretCheckSum，用于定义全局一致性校验信息。
```go
type IngressCheckSum struct {
	metav1.ObjectMeta
	Spec IngressCheckSumSpec
}

type IngressCheckSumList struct {
	metav1.TypeMeta
    metav1.ListMeta
	Items []IngressCheckSum
}

type IngressCheckSumSpec struct {
	// `Timestamp` is the time when the md5 of all the ingress was calculated.
	Timestamp metav1.Time
	// `Checksum` is the md5 of all the ingress.
	Checksum string
	// `ids` describes which id will match this ingress.
	Ids []string
}

type SecretCheckSum struct {
	metav1.ObjectMeta
	Spec SecretCheckSumSpec
}

type SecretCheckSumList struct {
	metav1.TypeMeta
    metav1.ListMeta
	Items []SecretCheckSum
}

type SecretCheckSumSpec struct {
	// `Timestamp` is the time when the md5 of all the secret was calculated.
	Timestamp metav1.Time
	// `Checksum` is the md5 of all the secret.
    // md5 = 
	Checksum string
	// `ids` describes which id will match this secret.
	Ids []string
}
```

5. Tengine-Ingress复用k8s ingress注解（高级配置）规范，基于内部运行时共享内存，通过tengine ingress模板构造HTTP(S)高级功能，支持ingress注解动态实时生效，满足用户基于不同应用场景下的HTTP(S)高级配置需求。

6. Tengine-Ingress在兼容[ingress canary注解](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#canary)的基础上，支持基于request header，header值，header值正则匹配，cookie和权重的流量切分，**无需tengine reload**，所有应用域名的ingress金丝雀规则实时动态无损生效。

![image](/book/_images/tengine_ingress_canary.png)

## 高可用
K8s原生资源对象包括ingress域名，secret证书，configmap配置，service服务等，在被写入etcd后，所有监听控制器默认都会处理资源对象的配置更新，即相同命名空间内的所有Pod会同时加载新的配置对象，如果配置存在错误和脏数据，变更影响将会触发全局风险。Tengine-Ingress作为云原生网关，通过K8s API处理和验证资源对象，扩展支持ingress应用域名和secret证书的灰度能力，保障变更操作的可灰度，可中断和可回滚。

以ingress应用域名变更为例，按照相同命名空间内Tengine-Ingress Pod数量，通过新增的ingress灰度注解确定每批次ingress资源对象动态生效的Pod范围。配置变更Pod范围内的Tengine-Ingress监听到ingress资源对象的更新事件，校验域名配置的合法性和全局一致性，将符合[ingress标准](https://kubernetes.io/docs/concepts/services-networking/ingress/)的配置信息全量写入系统共享内存。在ingress域名分批次灰度生效的变更过程中，用户可以基于应用域名成功率等监控指标随时主动终止和回滚本次配置变更，将风险缩小到可控范围内，保障应用域名变更的可灰度，可监控，可回滚。

![image](/book/_images/tengine_ingress_rollout.png)

Tengine-Ingress支持K8s core集群与K8s ingress存储集群相隔离的高可靠性部署方案，将运行态和存储态相分离，独立K8s ingress集群可以保证自身API服务器和etcd性能稳定，并且在core集群核心组件API服务器和etcd不可用的高危场景下也能正常向外提供7层转发服务。

![image](/book/_images/tengine_ingress_cluster.png)

K8s分布式系统本身可以保障单个ingress资源的一致性，但分布式环境是无法保证用户存储在etcd中ingress域名配置的全局正确性和全局完整性，并且在API服务器和etcd不可用的情况下，ingress域名配置的可用性更是无法保障。因此，Tengine-Ingress提出了一种分布式环境下ingress全局一致性方案，在新增和更新域名时，Tengine-Ingress基于ingress全局一致性校验算法计算全局MD5值，与CRD ingresschecksums资源对象中的MD5值相匹配，则表明本次更新的ingress资源对象是全局一致性，即可将ingress资源对象更新到本地缓存，并写入共享内存，开始使用最新的ingress域名配置对外提供HTTP(S)七层负载均衡，TLS卸载和路由转发功能；否则表明更新的ingress资源对象全局不一致，系统存在脏数据，不再更新本地缓存和共享内存，仍旧使用存量的ingress域名配置对外提供HTTP(S)接入服务，保证运行态域名接入和路由服务的正确性和可靠性。

![image](/book/_images/tengine_ingress_checksum_mod.png)

K8s分布式系统本身可以保障单个ingress资源的一致性，但分布式环境是无法保证用户存储在etcd中ingress域名配置的全局正确性和全局完整性，并且在API服务器和etcd不可用的情况下，ingress域名配置的可用性更是无法保障。因此，Tengine-ingress提出了一种分布式环境下ingress全局一致性方案，在新增和更新域名时，Tengine-ingress基于ingress全局一致性校验算法计算全局MD5值，与CRD ingresschecksums资源对象中的MD5值相匹配，则表明本次更新的ingress资源对象是全局一致性，即可将ingress资源对象更新到本地缓存，并写入共享内存，开始使用最新的ingress域名配置对外提供HTTP(S)七层负载均衡，TLS卸载和路由转发功能；否则表明更新的ingress资源对象全局不一致，系统存在脏数据，不再更新本地缓存和共享内存，仍旧使用存量的ingress域名配置对外提供HTTP(S)接入服务，保证运行态域名接入和路由服务的正确性和可靠性。Secret证书资源对象采用了类似的全局一致性方案。

![image](/book/_images/tengine_ingress_checksum.png)

## 高性能
由于Tengine实际运行时会加载大量的应用域名和路由的静态配置信息，每个worker进程需要各自申请一份内存，整个进程树就会占用较多的内存；而Tengine-Ingress使用动态配置，所有worker进程共享一份应用域名和路由配置信息，内存使用大幅下降。以32个work进程加载3万个域名为例，Tengine-Ingress相对Tengine，内存占用由20.4%下降至8.8%。

![image](/book/_images/tengine_ingress_mem.png)
