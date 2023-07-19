# ngx_http_xquic_module

Tengine XQUIC Module主要用于在服务端启用QUIC/HTTP3监听服务。
配置主要由HTTP main conf和listen配置两部分组成，标注「必选项」为启用QUIC的必选配置项，未标注则为可选配置项（不配则启用默认配置）。

## 配置示例

配置文件: conf/nginx.conf
---

```
    xquic_log   "pipe:rollback /home/admin/tengine/logs/tengine-xquic.log baknum=10 maxsize=1G interval=1d adjust=600" info;

    http {

        ## add for xquic ####
        xquic_ssl_certificate        /etc/tengine/ssl/certificate.crt;
        xquic_ssl_certificate_key    /etc/tengine/ssl/certificate.key;
        xquic_ssl_session_ticket_key /etc/tengine/ssl/session_ticket.key;

        xquic_congestion_control bbr;
        xquic_socket_rcvbuf 5242880;
        xquic_socket_sndbuf 5242880;
        xquic_anti_amplification_limit 5;
        ## end for xquic ####

        server {
            listen 2443 xquic reuseport;
            ...
        }
    }
```

## 指令

> (必选项)
> Syntax: **listen** 2443 `reuseport xquic`;
> Default: -
> Context: `server`

在listen指令中添加xquic选项，表示该端口启用quic/http3监听检查，一般和reuseport搭配使用。
该配置项强依赖xquic证书配置项启用tls/1.3握手和证书校验。

---

> (必选项)
> Syntax: **xquic_ssl_certificate** `/certificate/file path`;
> Default: -
> Context: `http`

从配置的指定目录读取quic(tls/1.3)加密握手需要的证书文件。

---

> (必选项)
> Syntax: **xquic_ssl_certificate_key** `/certificate key/file path`;
> Default: -
> Context: `http`

从配置的指定目录读取quic(tls/1.3)加密握手需要的证书私钥文件，私钥与证书公钥配套。

---

> Syntax: **xquic_ssl_session_ticket_key** `/ticket/file path`;
> Default: -
> Context: `http`

从配置的指定目录读取quic(tls/1.3)加密session ticket需要的秘钥文件，格式与ssl_session_ticket_key相同，配置后才可以启用session ticket功能。

---

> Syntax: **xquic_log** `"pipe:rollback /home/admin/tengine/logs/tengine-xquic.log baknum=10 maxsize=1G interval=1d adjust=600" info`;
> Default: -
> Context: `main`

向配置的指定目录打印xquic协议栈统计日志，支持滚动日志方式（可与rollback模块联动），可用xquic日志等级控制日志信息，日志等级可选范围为:
* report
* fatal
* error
* warn
* stats
* info
* debug
和Tengine日志等级类似，日志等级>=配置等级的日志内容都会被打印出来，生产环境建议配置到info. 
Debug日志等级会包含大量调试日志，对性能有影响，一般在日常测试启用，生产环境切勿启用。

---

> Syntax: **xquic_congestion_control** `bbr`;
> Default: `cubic`
> Context: `http`

配置xquic使用的congestion control算法，当前支持的算法类型有:
* reno
* cubic
* bbr
BBR当前对应的是BBR v1，默认值为cubic（与TCP默认congestion control算法对齐）。

---

> Syntax: **xquic_socket_rcvbuf** `5242880`;
> Default: `1048576`
> Context: `http`

xquic使用socket rcvbuf大小设置，默认是1M大小，配置后会使用socket option设置到内核。

---

> Syntax: **xquic_socket_sndbuf** `5242880`;
> Default: `1048576`
> Context: `http`

xquic使用socket rcvbuf大小设置，默认是1M大小，配置后会使用socket option设置到内核。

---

> Syntax: **xquic_anti_amplification_limit** `5`;
> Default: `5`
> Context: `http`

xquic在握手期间限制的反射放大倍数，这个参数用于在握手未完成地址校验前，限制服务端返回的数据量倍数N（即服务端返回的数据量 <= 收到客户端发送的数据量 * N）。
这个参数在RFC草案中的建议是不超过3倍，由于考虑到实际握手返回的证书大小，一般最大设置为5倍（从安全性角度不建议更大）。
