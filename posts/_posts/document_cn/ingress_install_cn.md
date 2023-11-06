# 简介

`Tengine-Ingress`由两部分组成，[Tengine-Ingress控制器](https://github.com/alibaba/tengine-ingress)和[Tengine-proxy](https://github.com/alibaba/tengine)。Tengine-Ingress控制器是一个基于Tengine-proxy的ingress控制器，在兼容云原生[ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)标准规范的基础上扩展了Server，Backend，TLS，Location和Canary。

`Tengine-Ingress`控制器通过订阅和处理ingress域名资源和secret证书资源，基于tengine ingress模板转换为动态配置写入共享内存。Tengine-proxy订阅共享内存变化写入内部运行时共享内存，将终端用户的外部流量路由到K8s集群中的应用服务。

![image](/book/_images/tengine_ingress_container.png)

## 使用官方镜像
支持操作系统：[Anolis](https://hub.docker.com/r/openanolis/anolisos), [Alpine](https://hub.docker.com/_/alpine)
支持系统架构：AMD64, ARM64

[Anolis](https://hub.docker.com/r/openanolis/anolisos)
```bash
docker pull tengine-ingress-registry.cn-hangzhou.cr.aliyuncs.com/tengine/tengine-ingress:1.1.0
```

[Alpine](https://hub.docker.com/_/alpine)
```bash
docker pull tengine-ingress-registry.cn-hangzhou.cr.aliyuncs.com/tengine/tengine-ingress:1.1.0-alpine
```
![image](/book/_images/tengine_ingress_vers_table.png)

## 自助编译镜像

### 第一步：构建tengine镜像
* [Anolis](https://hub.docker.com/r/openanolis/anolisos): `BASE_IMAGE="docker.io/openanolis/anolisos:latest"`, `LINUX_RELEASE="anolisos"`
* [Alpine](https://hub.docker.com/_/alpine): `BASE_IMAGE="alpine:latest"`, `LINUX_RELEASE="alpine"`
```bash
# docker build --no-cache --build-arg BASE_IMAGE="docker.io/openanolis/anolisos:latest" --build-arg LINUX_RELEASE="anolisos" -t tengine:3.1.0 images/tengine/rootfs/
```

### 第二步：构建tengine-ingress镜像
在tengine镜像基础上，构建tengine-ingress镜像
```bash
# docker build --no-cache --build-arg BASE_IMAGE="tengine:3.1.0" --build-arg VERSION="1.1.0" -f build/Dockerfile -t tengine-ingress:1.1.0 .
```

### 最后，使用tengine-ingress镜像部署您的网关。

## 启动命令行参数

> 参数名称: `--configmap`
> 参数值: `${tengine-configuration}`

`Tengine-Ingress`的全局配置，示例如下：
```yaml
apiVersion: v1
data:
  access-log-path: '"pipe:rollback /home/admin/tengine-ingress/logs/tengine-access.log baknum=10 maxsize=5G interval=1d adjust=600"'
  allow-backend-server-header: "true"
  client-body-buffer-size: 3m
  client-header-timeout: "60"
  default-type: application/octet-stream
  enable-multi-accept: "false"
  enable-real-ip: "true"
  enable-underscores-in-headers: "true"
  error-log-level: warn
  error-log-path: '"pipe:rollback /home/admin/tengine-ingress/logs/tengine-error.log baknum=10 maxsize=2G interval=1d adjust=600"'
  forwarded-for-header: X-Forwarded-For
  gzip-level: "1"
  gzip-min-length: "1024"
  gzip-types: application/atom+xml application/javascript application/x-javascript
    application/json application/rss+xml application/vnd.ms-fontobject application/x-font-ttf
    application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype
    image/svg+xml image/x-icon text/css text/javascript text/plain text/x-component
    text/xml
  http-redirect-code: "301"
  http-snippet: |
    sendfile                           on; 
    postpone_output                    0; 
    send_timeout                       60s; 
    req_status_zone server "$log_host" 512M; 
    req_status                         server; 
    req_status_bypass                  $no_reqstatus; 
    expires                            off; 
    error_page 509 @wait; 
    server_info                        on; 
    index index.html index.htm; 
    log_not_found                      off; 
    gzip_disable                       msie6; 
    gzip_buffers                       96 8k; 
    sysguard off;
  http3-xquic-default-cert: /etc/ingress-controller/ssl/default-fake-certificate.pem
  http3-xquic-default-key: /etc/ingress-controller/ssl/default-fake-certificate.pem
  large-client-header-buffers: 4 32k
  log-format-upstream: $time_local|$status|$upstream_status|$http_x_appkey|$remote_addr|$upstream_addr|$request_time|$upstream_response_time|$request_method|$scheme|$host|$server_port|$request_uri|$body_bytes_sent|$http_referer|$http_user_agent|$proxy_add_x_forwarded_for|$http_x_forwarded_for|$http_ns_client_ip|$http_accept_language|$connection_requests|$ssl_protocol|$ssl_cipher|$ssl_session_reused|$sent_http_set_cookie|$http_resp_cookie_govern|$cookie_cookie2|$cookie_thw|$sent_http_x_cache|$cookie_unb|$host|$request_length|$bytes_sent|$ingress_route_target|$xquic|$xquic_off|$xquic_connection_id|$xquic_stream_id|$xquic_ssl_protocol|$xquic_ssl_cipher|$xquic_ssl_session_reused|
  lua-shared-dicts: 'configuration_data: 160, certificate_data: 160, certificate_servers: 40'
  main-snippet: 
   "worker_rlimit_core    20000000000; \n
    error_log  \"pipe:rollback /home/admin/tengine-ingress/logs/tengine-error.log baknum=10 maxsize=2G interval=1d adjust=600\" warn; \n
    xquic_log  \"pipe:rollback /home/admin/tengine-ingress/logs/tengine-xquic.log baknum=10 maxsize=1G interval=1d adjust=600\" info;\n
    master_env NGX_DNS_RESOLVE_BACKUP_PATH=/home/admin/tengine-ingress/conf/local/dns/;\n"
  map-hash-bucket-size: "256"
  max-worker-connections: "40960"
  max-worker-open-files: "100000"
  nginx-status-ipv4-whitelist: 10.0.0.0/8,11.0.0.0/8,172.16.0.0/12,127.0.0.1/32,192.168.0.0/16,33.0.0.0/8
  proxy-body-size: 4096m
  proxy-buffer-size: 64k
  proxy-buffers-number: "256"
  proxy-connect-timeout: "60"
  proxy-headers-hash-bucket-size: "128"
  proxy-headers-hash-max-size: "1024"
  proxy-http-version: "1.1"
  proxy-next-upstream: error timeout invalid_header http_500 http_502 http_503 http_504
  proxy-next-upstream-tries: "1"
  proxy-read-timeout: "60"
  proxy-redirect-from: "off"
  proxy-send-timeout: "60"
  server-name-hash-bucket-size: "128"
  server-name-hash-max-size: "4096"
  server-tokens: "true"
  ssl-ciphers: ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:AES128-SHA:AES256-SHA:RSA+3DES:!DES-CBC3-SHA:!aNULL:!eNULL:!LOW:!MD5:!EXP:!DSS:!PSK:!SRP:!kECDH:!CAMELLIA:!IDEA:!SEED;
  ssl-protocols: TLSv1 TLSv1.1 TLSv1.2 TLSv1.3
  upstream-keepalive-timeout: "40"
  use-gzip: "true"
  variables-hash-bucket-size: "256"
  variables-hash-max-size: "2048"
  worker-cpu-affinity: auto
  worker-processes: auto
  worker-shutdown-timeout: 300s
kind: ConfigMap
metadata:
  name: tengine-configuration
  namespace: alibaba-ingress-tao
```

---
> 参数名称: `--annotations-prefix`
> 默认值: `nginx.ingress.kubernetes.io`

设置`Tengine-Ingress`注解的默认前缀，默认前缀为`nginx.ingress.kubernetes.io`。

---
> 参数名称: `--v`
> 参数值: `${log_level}`

设置`Tengine-Ingress`的日志级别，日志级别范围1..5，最大日志级别5属于debug模式。

---
> 参数名称: `--kubeconfig`
> 参数值: `${ing_kubeconfig}`

`Tengine-Ingress`支持K8s core集群与K8s ingress存储集群相隔离的高可靠性部署方案，将运行态和存储态相分离，独立K8s ingress集群可以保证自身API服务器和etcd性能稳定，并且在core集群核心组件API服务器和etcd不可用的高危场景下也能正常向外提供7层转发服务。

---
> 参数名称: `--watch-namespace`
> 参数值: `${watch_namespace}`

设置`Tengine-Ingress`监听处理的命名空间
* `Tengine-Ingress`只监听处理环境变量`watch_namespace`指定命名空间下的K8s资源对象。
* K8s资源对象包括Ingress，Secret，Service等相关配置资源。
* 如果${watch_namespace}`为空，则监听所有命名空间下的资源对象。

---
> 参数名称: `--controller-class`
> 参数值: `${controller_class}`

设置`Tengine-Ingress`的类别
* 在Kubernetes 1.19.0及其更高版本，通过IngressClass资源对象定义Ingress资源对象的类别。
* IngressClass的.spec.controller值与`Tengine-Ingress`启动参数${controller_class}值保持一致，则`Tengine-Ingress`才会监听处理对应的Ingress资源对象。
