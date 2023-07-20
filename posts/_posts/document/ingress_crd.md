# Tengine-Ingress

Tengine-Ingress完全兼容云原生[ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)标准规范，用户可参照[kubernetes ingress-nginx](https://kubernetes.github.io/ingress-nginx/)相关文档。
在此列出[Tengine-Ingress](https://github.com/alibaba/tengine-ingress)原生扩展和增强功能的CRD。

Tengine-Ingress通过全局一致性校验机制保障内存中运行态持有的用户侧ingress域名和secret证书的有效性和正确性，快速校验10w+域名和1000+泛证书，在域名配置和证书信息不符合标准化k8s资源ingress和secret规范及其相关RFC标准时，将不再更新本地缓存，并实时告警通知，保障运行态永远可正常向外提供7层转发服务。新增CRD IngressCheckSum和SecretCheckSum，用于定义全局一致性校验信息。

![image](/book/_images/tengine_ingress_checksum.png)

## CRD

### ingresschecksums.tengine.taobao.org
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

### secretchecksums.tengine.taobao.org
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
    - name: v1
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
```
