# Tengine-Ingress 快速开始

## 一、Ingress 镜像

开发者可以直接使用 Tengine-Ingress 提供的镜像，镜像基于  [Anolis OS](https://hub.docker.com/r/openanolis/anolisos) ，支持 AMD64 和 ARM64 架构。

镜像拉取方式：

```shell
docker pull tengine-ingress-registry.cn-hangzhou.cr.aliyuncs.com/tengine/tengine-ingress:1.0.0
```

如需额外增加功能，可以基于此镜像二次开发；也可通过源码重新编译构建，参考 [building-from-source](https://github.com/alibaba/tengine-ingress#building-from-source)

## 二、在 Kubernetes 集群使用

### 1. Tengine-Ingress Deployment

在 Kubernetes 集群中可以使用 Deployment 部署 Tengine-Ingress 集群，示例配置如下：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tengine-deployment
spec:
  selector:
    matchLabels:
      app: tengine
  replicas: 1
  template:
    metadata:
      labels:
        app: tengine
    spec:
      containers:
      - name: tengine
        image: tengine-ingress-registry.cn-hangzhou.cr.aliyuncs.com/tengine/tengine-ingress:1.0.0
        ports:
        - containerPort: 80
        command: ["/usr/bin/dumb-init"]
        args:
        - "--"
        - "/tengine-ingress-controller"
        - "--configmap=default/tengine-ingress-configuration"
        - "--annotations-prefix=nginx.ingress.kubernetes.io"
        - "--v=1"
        env:
        - name: log_level
          value: "1"
        - name: "POD_NAME"
          valueFrom:
            fieldRef:
              fieldPath: "metadata.name"
        - name: "POD_NAMESPACE"
          valueFrom:
            fieldRef:
              fieldPath: "metadata.namespace"
```

其中 `--configmap` 参数指定 Tengine Ingress Configmap 配置。Deployment 可以通过 `kubectl apply -f deployment.yaml` 执行生效。

### 2. Configmap

通过 Configmap 可以开启/关闭增强功能，创建示例

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: tengine-ingress-configuration
  namespace: default
data:
```

示例仅创建空 Configmap，通过 `kubectl create -f configmap.yaml` 执行生效

### 3. 权限

Tengine-Ingress 运行时需要一系列权限，以便于监听更新相关配置，权限配置示例如下：

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: tengine-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: [ "get", "list", "watch"]
- apiGroups: ["coordination.k8s.io"]
  resources: ["leases"]
  verbs: [ "get", "list", "watch", "create", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: default-tengine-reader
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: tengine-reader
subjects:
- kind: ServiceAccount
  name: default
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: tengine-cluster-role
  namespace: default
rules:
- apiGroups: [""]
  resources: ["secrets", "configmaps", "endpoints", "services"]
  verbs: [ "get", "list", "watch"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: [ "get", "list", "watch"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses/status"]
  verbs: [ "get", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tengine-cluster-role-binding
roleRef:
  kind: ClusterRole
  name: tengine-cluster-role
  apiGroup: rbac.authorization.k8s.io
subjects:
  - kind: ServiceAccount
    name: default
    namespace: default
```

通过 `kubectl apply -f auth.yaml` 执行生效。

### 4. 后端服务

示例中创建一个 http 后端服务用于测试，同时创建相对应的 service 用于服务发现：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-deployment
spec:
  selector:
    matchLabels:
      app: echo
  replicas: 1
  template:
    metadata:
      labels:
        app: echo
    spec:
      containers:
      - name: echo
        image: hashicorp/http-echo:latest
        ports:
        - containerPort: 80
        args: ["-text", "hello world"]
---
apiVersion: v1
kind: Service
metadata:
  name: echo-service
spec:
  ports:
  - name: http
    port: 80
    targetPort: 80
  selector:
    app: echo
```

### 5. Ingress 资源

创建一个 Ingress 资源，创建域名 `echo.test.com` 转发至测试的 `echo` 服务：

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: echo-test-ingress
spec:
  rules:
  - host: echo.test.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: echo-service
            port:
              number: 80
```

执行生效后，可以通过 `curl -k "https://${INGRESS_IP}/" -H "host:echo.test.com"` 验证可用性，得到结果 `hello world`。

## 三、增强功能示例

### 1. 开启 `xudp`

`xudp` 实现了内核的用户态的高性能 `UDP` 收发，可极大提升 `QUIC` 协议 `UDP` 传输性能，目前 xudp 能力仅在 [Anolis OS](https://hub.docker.com/r/openanolis/anolisos) 系统上支持（**注意：需要宿主机和 docker 都是 Anolis OS 系统才能支持 xudp 特性**）：。通过 `Configmap` 可以很方便的开启/关闭 `xudp`能力。

``` yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: tengine-ingress-configuration
  namespace: default
data:
  use-xquic-xudp: "true"
  main-snippet: |
    xudp_core_path /usr/local/lib64/xquic_xdp/kern_xquic.o;
    xudp_rcvnum 2048;
    xudp_sndnum 4096;
```

加载成功后可以看到 `listen` 指令增加了 `xudp` 的选项，同时 `main` 配置段增加了 `xudp_core_path` 配置。

### 2. 强制跳转 `https`

在 `ingress` 资源增加 `Annotations` 可以控制路由转发的部分逻辑，如通过 `nginx.ingress.kubernetes.io/ssl-redirect` 可以控制是否强制调整 `https`，默认开启，先增加示例关闭此功能：

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: echo-test-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - host: echo.test.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: echo-service
            port:
              number: 80
```

可以看到，在增加了 `nginx.ingress.kubernetes.io/ssl-redirect` 后，再次执行 `curl "http://${INGRESS_IP}/" -H "host:echo.test.com"` 就不会跳转至 `https`，直接返回内容 `hello world`。
