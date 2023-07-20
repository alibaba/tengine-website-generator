# Ingress全局一致性校验


## 背景
`Tengine-Ingress`对外提供HTTP和HTTPS接入转发服务，作为七层入口网关，其稳定性和可靠性至关重要。`Tengine-Ingress`在兼容K8s云原生ingress标准的基础上，利用分布式环境下的etcd存储secret证书配置信息，通过API server标准的REST接口访问新增和变更的secret证书配置。K8s分布式系统本身可以保障单个secret资源的一致性，但分布式环境是无法保证用户存储在etcd中secret证书配置的全局正确性和全局完整性，并且在API server和etcd不可用的情况下，secret证书配置的可用性更是无法保障。因此，`Tengine-Ingress`提出了一种分布式环境下secret全局一致性方案，从而满足用户对于`Tengine-Ingress`高可靠性的要求，对外提供永不停机的HTTP和HTTPS接入服务。


## 方案
分布式环境下secret全局一致性方案主要由两部分配合实现完成，即控制面和数据面，其中控制面负责计算全局secret配置信息的一致性校验MD5，并写入CRD secretchecksums；数据面`Tengine-Ingress`监听secret证书资源和crd secretchecksums，通过与控制面相同的算法计算全局secret配置信息的一致性校验MD5，如果MD5完全相同，则secret全局一致性校验通过，`Tengine-Ingress`更新本地缓存，基于最新的ingress配置转发七层HTTP(S)流量。

控制面和数据面采用相同的MD5计算公式，在secret配置数据全局一致的情况下，控制面和数据面`Tengine-Ingress`分别计算得出的MD5值是完全相同的。如果数据面计算得出的MD5值与控制面的MD5值不完全相同，则表明etcd中存储的secret配置与控制面存储的secret配置在全局范围内是不一致的，在此类异常情况下，数据面`Tengine-Ingress`将暂时不再信任系统的secret配置，防止脏数据污染本地缓存，`Tengine-Ingress`会继续使用本地缓存中的secret证书配置对外提供HTTP(S)接入服务。

一个K8s标准secret资源对象如下所示，元数据name标识了secret资源对象的名称，通过末尾的自定义数字表示每个secret资源ID，自定义注解`nginx.ingress.kubernetes.io/version`则标识了secret证书配置的版本号。

**注意：通过`Secret ID`，`Secret资源对象版本号`和`证书SHA-1 hashes值`可以唯一确定一个secret证书配置信息，即Secret证书配置ID。**
**注意：`Secret ID`: secret name的ID号**
**注意：`Version`: secret注解nginx.ingress.kubernetes.io/version的值，即`Secret资源对象版本号`**
**注意：`PemSHA`: [证书SHA-1 hashes值](https://en.wikipedia.org/wiki/SHA-1)值**
**注意：Secret证书配置ID的分隔符是'-'**
|    |  Secret资源类型 |       Secret证书配置ID       |                                 示例                              |
|:--:|--------------- |----------------------------|-------------------------------------------------------------------|
|    |    secret      | "`Secret ID`-`Version`-`PemSHA`" | secret名称: alibaba-taobao-com-27555<br>secret注解 nginx.ingress.kubernetes.io/version: "1"<br>PemSHA: 44a72405d239fbffde3e0f49f1c0713636dcda60<br>Secret证书配置ID "27555-1-44a72405d239fbffde3e0f49f1c0713636dcda60" |

基于上述示例，`SecretID`是"27555"，而`Secret资源对象版本号`是"1"，`PemSHA`是"44a72405d239fbffde3e0f49f1c0713636dcda60"，通过`Secret ID`，`Secret资源对象版本号`和`证书SHA-1 hashes值`可以唯一确定一个secret证书配置信息，即`Secret证书配置ID`（27555-1-44a72405d239fbffde3e0f49f1c0713636dcda60）。

**注意：计算全局MD5**
* md5.Sum("`Secret证书配置ID`1","`Secret证书配置ID`2",...)
* secret证书配置ID之间的分隔符是','；
* secret证书配置ID按照字符串顺序排序。

数据面`Tengine-Ingress`基于上述公式计算secret全局一致性校验MD5值，通过匹配CRD secretchecksums资源实例的checksum值（即控制面计算得出的MD5值），从而决定是否更新本地缓存中的secret证书配置。在secret全局一致性校验失败的情况下，数据面会继续匹配CRD secretchecksums中的ids（即控制面本次计算secret全局一致性校验MD5对应的所有secret证书配置ID列表），从而找出不一致的单个secret资源对象信息。

![image](/book/_images/tengine_ingress_checksum_mod.png)


### 控制面CRD
* secretchecksums.tengine.taobao.org

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: secretchecksums.tengine.taobao.org
spec:
  group: tengine.taobao.org
  names:
    kind: SecretCheckSum
    listKind: SecretCheckSumList
    plural: secretchecksums
    singular: secretchecksum
  scope: Namespaced
  versions:
    - name: v1alpha1
      schema:
        openAPIV3Schema:
          description: SecretCheckSum is the Schema for the secretchecksums API
          properties:
            apiVersion:
              description: 'APIVersion defines the versioned schema of this representation
              of an object. Servers should convert recognized schemas to the latest
              internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
              type: string
            kind:
              description: 'Kind is a string value representing the REST resource this
              object represents. Servers may infer this from the endpoint the client
              submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
              type: string
            metadata:
              type: object
            spec:
              description: SecretCheckSumSpec defines the desired state of SecretCheckSum
              properties:
                checksum:
                  description: Checksum value which generated using a hash method
                  type: string
                ids:
                  description: 'The IDs of all Secret are used to calculate the
                  checksum. When the checksum is inconsistent, it can be used
                  to compare the differences'
                  items:
                    type: string
                  type: array
                timestamp:
                  description: The timestamp when the checksum was generated
                  format: date-time
                  type: string
              required:
                - timestamp
              type: object
          type: object
      served: true
      storage: true
      subresources:
        status: {}
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: []
  storedVersions: []
```


### Secret注解

> 注解名称: `nginx.ingress.kubernetes.io/version`
> 值类型: `number`
> 默认值: `0`
> 注解类型: `secret注解`
> 生效维度: `证书`

Secret资源对象的ID号：唯一标识一个secret资源对象。


### 实例
* CRD对象

```yaml
apiVersion: v1
items:
- apiVersion: tengine.taobao.org/v1
  kind: SecretCheckSum
  metadata:
    name: secret-aii2kzb9gl
    namespace: alibaba-ingress-tao
  spec:
    checksum: 50d00d896e16a82a5fe3e9b741abf04e
    ids:
    - 118-5792-8c0483a291c2252a455c95084d98ccc2d0e14ae7
    - 119-5793-1cf61c5ababc59763fbe93707bcc8ed4ba33c53b
    - 150-4527-9ff9ec8e87e2a07542f2bcd962d019976e872892
    - 151-4528-1fc9c2611ea665d5c4d75dbd36925d8b216b8081
    - 234-4886-a2ea71a0123762ae44a49da3508bbc67a9f02863
    - 235-4887-8a0246a2f6aa51bbc9d32a1353e3e63d0037a9da
    - 260-5981-871c6a02d2232093e689795f5a0df7e953bcb570
    - 261-5980-1ab5a6f64c8091060ab48382b303c7bffaeb4b26
    - 264-6463-dff7c772437916727c43e3767b8cf0d4452dd719
    - 265-6464-c5eea9758e7b3724ffed53e9384576c67a24dc1d
    - 266-6292-a41493642e0e8d615afa70d24bc9dfe54fe17217
    - 267-6293-c8dbd1cabfd474b6fd5bbbee6f39bc68aa456fe8
    - 285-6272-e221079b1d85019a1b70ab14de00baa8404956ac
    - 286-6273-11254b5b51a3874ecfd85e061a4da10f483fd6a4
    - 287-6214-8233074567ed69da4015578343a4e84b04cf9be6
    - 288-6215-44a72405d239fbffde3e0f49f1c0713636dcda60
    - 305-4535-ad183f5fc3362f39c39e770591e18e44f34d92e3
    - 306-4536-871848aac0e233351ab9e75ff26624575e76df84
    - 332-4964-e139a84129d95fa995d4121e51c4ca0d578909b2
    - 333-4965-66990d215429631cd7febaaf64cbe9e98bddfed7
    - 68-6197-724bf09c63274a551e4203b1c135a9df8e9f46f4
    - 69-6198-75f488f260e9320003b2748ae9069cae0e3d6e0f
    - 72-6082-5e9d2740f1054e553c285e7c2e53a4dc701ec571
    - 73-6083-214b26a9585203ec073866003b3933f39b56e716
    - 76-6443-c60175b3410ca4afd94636238029aaa351b0c24c
    - 77-6442-3e3c599315315e2ac55cc28539fa6e126f0355be
```

* Secret资源对象
```yaml
apiVersion: v1
data:
  tls.crt: *
  tls.key: *
kind: Secret
metadata:
  annotations:
    fs.ingress.alibaba/version: "5792"
  name: alibaba-com-ecc-118
  namespace: alibaba-ingress-tao
type: kubernetes.io/tls

apiVersion: v1
data:
  tls.crt: *
  tls.key: *
kind: Secret
metadata:
  annotations:
    fs.ingress.alibaba/version: "5793"
  name: alibaba-com-rsa-119
  namespace: alibaba-ingress-tao
type: kubernetes.io/tls
  ... ...
  ... ...
```
