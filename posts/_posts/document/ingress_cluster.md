# Tengine-Ingress 独立K8s存储集群

`Tengine-Ingress`支持K8s core集群与K8s ingress存储集群相隔离的高可靠性部署方案，将运行态和存储态相分离，独立K8s ingress集群可以保证自身API服务器和etcd性能稳定，并且在core集群核心组件API服务器和etcd不可用的高危场景下也能正常向外提供7层转发服务。

![image](/book/_images/tengine_ingress_cluster.png)

## Configmap配置
> 配置: **use-ingress-storage-cluster** `true`;
> 默认值: `false`

如果设置`use-ingress-storage-cluster: 'true'`，则tengine-ingress将通过启动命令行参数`--kubeconfig`中的kubeconfig从独立K8s ingress存储集群获取Ingress和Secret资源对象，而configmap仍然从tengine-ingress所在的K8s core集群中获取。

## 启动参数
> 参数名称: `--kubeconfig`
> 参数值: `${ing_kubeconfig}`

`Tengine-Ingress`支持K8s core集群与K8s ingress存储集群相隔离的高可靠性部署方案，将运行态和存储态相分离，独立K8s ingress集群可以保证自身API服务器和etcd性能稳定，并且在core集群核心组件API服务器和etcd不可用的高危场景下也能正常向外提供7层转发服务。

