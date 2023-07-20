# mod_xudp

Tengine XUDP Module主要用于在服务端启用XUDP，支持bypass内核的用户态高性能UDP转发。
服务端启用QUIC/HTTP3监听服务，通过配合使用XUDP，可大幅提升HTTP3转发性能。

目前，xudp能力仅在[Anolis](https://hub.docker.com/r/openanolis/anolisos)系统上支持（**注意：需要宿主机和docker都是Anolis操作系统才能支持xudp特性**）。

## 配置示例
配置文件: conf/nginx.conf
---
```
    # begin for xudp
    xudp_core_path /usr/lib64/xquic_xdp/kern_xquic.o;
    xudp_rcvnum 2048;
    xudp_sndnum 4096;
    # end for xudp

    http {
        ...
        server {
            listen 2443 xquic xudp reuseport;
            ...
        }
    }
```

## 指令
> Syntax: **listen** 2443 `reuseport xudp`;
> Default: -
> Context: `server`

在listen指令中添加xudp选项，表示该端口启用xudp。
配合xquic使用，可大幅提升HTTP3转发性能。

---
> Syntax: **xudp_rcvnum** `2048`;
> Default: `1024`
> Context: `main`

配置XUDP套接字接收缓冲区大小。

---
> Syntax: **xudp_sndnum** `4096`;
> Default: `1024`
> Context: `main`

配置XUDP套接字发送缓冲区大小。
