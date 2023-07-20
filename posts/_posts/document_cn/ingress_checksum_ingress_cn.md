# Ingress全局一致性校验


## 背景
`Tengine-Ingress`对外提供HTTP和HTTPS的域名接入转发服务，作为七层入口网关，其稳定性和可靠性至关重要。`Tengine-Ingress`在兼容K8s云原生ingress标准的基础上，利用分布式环境下的etcd存储ingress域名配置信息，通过API server标准的REST接口访问新增和变更的ingress域名配置。K8s分布式系统本身可以保障单个ingress资源的一致性，但分布式环境是无法保证用户存储在etcd中ingress域名配置的全局正确性和全局完整性，并且在API server和etcd不可用的情况下，ingress域名配置的可用性更是无法保障。因此，`Tengine-Ingress`提出了一种分布式环境下ingress全局一致性方案，从而满足用户对于`Tengine-Ingress`高可靠性的要求，对外提供永不停机的HTTP和HTTPS接入服务。


## 方案
分布式环境下ingress全局一致性方案主要由两部分配合实现完成，即控制面和数据面，其中控制面负责计算全局ingress配置信息的一致性校验MD5，并写入CRD ingresschecksums；数据面`Tengine-Ingress`监听ingress域名资源和crd ingresschecksums，通过与控制面相同的算法计算全局ingress配置信息的一致性校验MD5，如果MD5完全相同，则ingress全局一致性校验通过，`Tengine-Ingress`更新本地缓存，基于最新的ingress配置转发七层HTTP(S)流量。

控制面和数据面采用相同的MD5计算公式，在ingress配置数据全局一致的情况下，控制面和数据面`Tengine-Ingress`分别计算得出的MD5值是完全相同的。如果数据面计算得出的MD5值与控制面的MD5值不完全相同，则表明etcd中存储的ingress配置与控制面存储的ingress配置在全局范围内是不一致的，在此类异常情况下，数据面`Tengine-Ingress`将暂时不再信任系统的ingress配置，防止脏数据污染本地缓存，`Tengine-Ingress`会继续使用本地缓存中的ingress域名配置对外提供HTTP(S)接入服务。

一个K8s标准ingress资源对象如下所示，元数据name标识了ingress资源对象的名称，通过末尾的自定义数字表示每个ingress资源ID，自定义注解`nginx.ingress.kubernetes.io/version`则标识了ingress域名配置的版本号。

**注意：通过`IngressID`和`Ingress资源对象版本号`可以唯一确定一个ingress域名配置信息，即`Ingress域名配置ID`。**
**注意：`IngressID`: Ingress name的ID号**
**注意：`Version`: ingress注解nginx.ingress.kubernetes.io/version的值，即`Ingress资源对象版本号`**
**注意：Ingress域名配置ID的分隔符是'-'**
|    | Ingress资源类型 |   `Ingress域名配置ID`   |                          示例                       |
|:--:|----------------|---------------------|----------------------------------------------------|
|    | ingress<br>canary ingress | "`IngressID`-`Version`" | ingress名称: alibaba-taobao-com-27555<br>ingress注解 nginx.ingress.kubernetes.io/version: "1"<br>Ingress域名配置ID "27555-1" |

基于上述示例，`IngressID`是"27555"，而`Ingress资源对象的版本号`是"1"，通过`IngressID`和`Ingress资源对象版本号`可以唯一确定一个ingress域名配置信息，即`Ingress域名配置ID`（"27555-1"）。

**注意：计算全局MD5**
* md5.Sum("`Ingress域名配置ID`1","`Ingress域名配置ID`2",...)
* ingress域名配置ID之间的分隔符是','；
* ingress域名配置ID按照字符串顺序排序。

数据面`Tengine-Ingress`基于上述公式计算ingress全局一致性校验MD5值，通过匹配CRD ingresschecksums资源实例的checksum值（即控制面计算得出的MD5值），从而决定是否更新本地缓存中的ingress域名配置。在ingress全局一致性校验失败的情况下，数据面会继续匹配CRD ingresschecksums中的ids（即控制面本次计算ingress全局一致性校验MD5对应的所有ingress域名配置ID列表），从而找出不一致的单个ingress资源对象信息。

![image](/book/_images/tengine_ingress_checksum_mod.png)


### 控制面CRD
* ingresschecksums.tengine.taobao.org

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: ingresschecksums.tengine.taobao.org
spec:
  group: tengine.taobao.org
  names:
    kind: IngressCheckSum
    listKind: IngressCheckSumList
    plural: ingresschecksums
    singular: ingresschecksum
  scope: Namespaced
  versions:
    - name: v1
      schema:
        openAPIV3Schema:
          description: IngressCheckSum is the Schema for the ingresschecksums API
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
              description: IngressCheckSumSpec defines the desired state of IngressCheckSum
              properties:
                checksum:
                  description: Checksum value which generated using a hash method
                  type: string
                ids:
                  description: 'The IDs of all ingress are used to calculate the
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
```


### Ingress注解

> 注解名称: `nginx.ingress.kubernetes.io/version`
> 值类型: `number`
> 默认值: `0`
> 注解类型: `ingress注解`
> 生效维度: `域名` 或 `域名/path`

Ingress资源对象的ID号：唯一标识一个ingress资源对象。


### 实例
* CRD对象

```yaml
apiVersion: tengine.taobao.org/v1
kind: IngressCheckSum
metadata:
  name: ingress-checksum-ryayrf909x
  namespace: alibaba-ingress-tao
spec:
  checksum: 1bc5a4a332e9941cd12c3db6946cda9c
  ids:
  - 123992-1
  - 143379-1
  - 144201-1
  - 146606-1
  - 153488-1
  - 209473-1
  - 221938-1
  - 235333-1
  - 238210-1
  - 27524-1
  - 27529-1
  - 27563-1
  - 310496-1
  - 38679-1
  - 396078-1
  - 401337-1
  - 406937-1
  - 417679-1
  - 424413-1
  - 438632-1
  - 446827-1
  - 448857-1
  - 451211-1
  - 455916-1
  - 468259-1
  - 534026-1
  - 536005-1
  - 541766-1
  - 542537-1
  - 548553-1
  - 570718-1
  - 572326-1
  - 578729-1
  - 585053-1
  - 592270-2
  - 593613-1
  - 596753-1
  - 599098-2
  - 599332-1
  - 599342-1
  - 599343-1
  - 599348-1
  - 599352-1
  - 599357-1
  - 599361-1
  - 599366-1
  - 601165-1
  - 60582-1
  - 606225-1
  - 60694-1
  - 609415-1
  - 609416-1
  - 609417-1
  - 609419-1
  - 609420-1
  - 609424-1
  - 609430-1
  - 609434-1
  - 609438-1
  - 612033-2
  - 614872-1
  - 615423-1
  - 615425-1
  - 615426-1
  - 615428-1
  - 615453-1
  - 615454-1
  - 615458-1
  - 615469-1
  - 617951-1
  - 622004-1
  - 622357-1
  - 623401-1
  - 624423-1
  - 627139-1
  - 628098-1
  - 628617-1
  - 630010-2
  - 632704-1
  - 636178-1
  - 637522-1
  - 637862-1
  - 637867-1
  - 638857-1
  - 638909-1
  - 639260-1
  - 640992-1
  - 641014-1
  - 641019-1
  - 641022-1
  - 641025-1
  - 641026-1
  - 641027-1
  - 641028-1
  - 641029-1
  - 641030-1
  - 641032-1
  - 641036-1
  - 641037-1
  - 641038-1
  - 641560-1
  - 642189-3
  - 647199-1
  - 647201-1
  - 647203-1
  - 647414-1
  - 647919-1
  - 648227-1
  - 648624-1
  - 648631-1
  - 649151-1
  - 649154-1
  - 649161-1
  - 652983-1
  - 656799-1
  - 656803-1
  - 657224-1
  - 658025-1
  - 659906-1
  - 661260-1
  - 662118-1
  - 663943-1
  - 675484-1
  - 675683-1
  - 676555-2
  - 677238-1
  - 678960-1
  - 679880-1
  - 680225-1
  - 680889-1
  - 685241-1
  - 685587-1
  - 687178-1
  - 687228-1
  - 688645-1
  - 689560-2
  - 691877-1
  - 692530-1
  - 693198-1
  - 698173-1
  - 699253-1
  - 699869-2
  - 699968-1
  - 705527-1
  - 706359-1
  - 707794-1
  - 709166-1
  - 709958-1
  - 710883-1
  - 710908-1
  - 711346-1
  - 712630-1
  - 713576-1
  - 713618-1
  - 714741-1
  - 714988-2
  - 715850-1
  - 716139-1
  - 716787-1
  - 718844-1
  - 719706-2
  - 723748-1
  - 724510-1
  - 724595-1
  - 724628-1
  - 724672-1
  - 725190-1
  - 725348-1
  - 725456-1
  - 725674-1
  - 726129-1
  - 726812-1
  - 728035-1
  - 728853-1
  - 732735-1
  - 733505-1
  - 733509-1
  - 733510-1
  - 736849-1
  - 738713-1
  - 738832-1
  - 738855-1
  - 738924-1
  - 742004-1
  - 742070-1
  - 742433-2
  - 742629-1
  - 742639-1
  - 742640-1
  - 742641-1
  - 742642-1
  - 742643-1
  - 743146-1
  - 743174-1
  - 743212-1
  - 743318-1
  - 743320-1
  - 743436-1
  - 743490-1
  - 743526-1
  - 744237-1
  - 745148-1
  - 747286-1
  - 750032-1
  - 750219-1
  - 751162-1
  - 752279-1
  - 753428-1
  - 753542-2
  - 755074-1
  - 759276-2
  - 759896-1
  - 761181-1
  - 762315-1
  - 763858-1
  - 763880-1
  - 764021-1
  - 765203-1
  - 765472-1
  - 765490-1
  - 766301-1
  - 766831-2
  - 770165-1
  - 772603-1
  - 772618-1
  - 772639-1
  - 772803-1
  - 773910-1
  - 774075-1
  - 774084-1
  - 775184-1
  - 775251-1
  - 776732-4
  - 778460-1
  - 783368-1
  - 783827-2
  - 788005-1
  - 789086-1
  - 789200-1
  - 789222-1
  - 789964-1
  - 790342-1
  - 790401-1
  - 793866-1
  - 794265-1
  - 794447-3
  - 795029-1
  - 796800-1
  - 798632-1
  - 805862-1
  - 808486-1
  - 808830-1
  - 811992-1
  - 814439-1
  - 815128-1
  - 819624-1
  - 819851-1
  - 820016-1
  - 821109-1
  - 827035-1
  - 829182-1
  - 830329-1
  - 831491-1
  - 831548-1
  - 832990-1
```

* Ingres资源对象
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/version: "1"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    kubernetes.io/ingress.class: alibaba-ingress-tao
  name: alibaba-dt-com-123992
  namespace: alibaba-ingress-tao
spec:
  rules:
  - host: dt.alibaba.com
    http:
      paths:
      - backend:
          service:
            name: dt-alibaba-com-vipserver
            port:
              number: 80
        path: /
        pathType: ImplementationSpecific
  tls:
  - hosts:
    - dt.alibaba.com
    secretName: alibaba-com-ecc
  - hosts:
    - dt.alibaba.com
    secretName: alibaba-com-rsa

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/version: "1"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    kubernetes.io/ingress.class: alibaba-ingress-tao
  name: alibaba-work-alilang-hermes-alibaba-inc-com-143379
  namespace: alibaba-ingress-tao
spec:
  rules:
  - host: hermes.alibaba.com
    http:
      paths:
      - backend:
          service:
            name: hermes-alibaba-com-vipserver
            port:
              number: 80
        path: /
        pathType: ImplementationSpecific
  tls:
  - hosts:
    - hermes.alibaba.com
    secretName: alibaba-com-ecc
  - hosts:
    - hermes.alibaba.com
    secretName: alibaba-com-rsa
status:
  loadBalancer: {}
  ... ...
  ... ...
```
