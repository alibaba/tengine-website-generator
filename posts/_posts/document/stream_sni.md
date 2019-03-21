## Name

* Tengine Stream SNI

## Description

Provide information about how to enable SNI in Stream module.

## Compilation

Build Tengine with configuration item `--with-stream_ssl_module` and `--with-stream_sni`.

## Directives

**Syntax**:   server_name hostname;

**Default**:  None;

**Context**:  server

`server_name` used in Stream module makes Tengine have the ability to listen same ip:port in multiply server blocks. 

The connection will be attached to a certain server block by SNI extension in TLS. That means `server_name` should be used with SSL offloading(using `ssl` after `listen`).

---

**Syntax**:   ssl_sni_force on|off;

**Default**:  off;

**Context**:  stream, server

`ssl_sni_force` will determine whether the TLS handsheke is rejected or not if SNI is not matched with server name which we configure by `server_name` in Stream module.


## Example

file: conf/nginx.conf

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

        #Default server, first server block will be used
        #if not such default server is provied.
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
            #reject all requests whose SNI don't match "www.tmall.com"
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


## Note
This feature is experimental. We will deprecate this feature if there is any conflict with similar feature of Nginx official.
