## 名称

* Tengine Stream SNI

## Description

允许Tengine在Stream模块根据TLS的SNI选择Server块.

## 编译

Tengine的编译选项必须加上 `--with-stream_ssl_module` and `--with-stream_sni`.

## 指令

**Syntax**:   server_name hostname;

**Default**:  None;

**Context**:  server

在Stream模块中，`server_name` 可以用来允许多个server块监听同一个ip:port。Tengine会根据TLS的SNI来决定请求连接匹配到哪个server块。这意味着，Stream模块的`server_name`必须用在SSL卸载的情况下（即`listen`指令后面有`ssl`这个参数）。

---

**Syntax**:   ssl_sni_force on|off;

**Default**:  off;

**Context**:  stream, server

在Stream模块中，`ssl_sni_force`决定了如果TLS的SNI和配置的`server_name`不匹配，TLS握手是否被拒绝。


## 例子

文件: conf/nginx.conf

```
    stream {
        server {
            listen 443 ssl;
            server_name www.taobao.com;
            ......
        }

        server {
            listen 443 ssl;
            server_name www.tmall.com;
            ......
        }
   
        #默认server块，如果没有default server块
        #则会请求会命中stream中配置的第一个server块
        server {
            listen 443 ssl default;
            .... 
        }
    }
    
```
---

```
    stream {
        server {
            listen 443 ssl default;
            #使得没有命中www.tmall.com的请求全部拒绝连接
            ssl_sni_force on;
            ......
        }

        server {
            listen 443 ssl;
            server_name www.tmall.com;
            ......
        }
    }

```

## 注意
这个特性是实验性的。如果Nginx官方有类似的功能和该功能有冲突，那么改功能将被废弃。
