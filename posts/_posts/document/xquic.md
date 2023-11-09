# ngx_http_xquic_module

Tengine XQUIC Module is used to enable QUIC/HTTP3 listening service on the server side.

The configuration consists of two parts: HTTP main conf and listen configuration. Marked "required options" are required configuration items to enable QUIC, while unmarked ones are optional configuration items (if not qualified, the default configuration is enabled).

## Configuration example

Configuration file: conf/nginx.conf
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

## Command

> (required)
> Syntax: **listen** 2443 `reuseport xquic`;
> Default: -
> Context: `server`

Adding the xquic option to the listen command indicates that the port enables quic/http3 listening and checking, and is generally used with reuseport.

This configuration item strongly relies on the xquic certificate configuration item to enable TLS/1.3 handshake and certificate verification.

---
> (required)
> Syntax: **xquic_ssl_certificate** `/certificate/file path`;
> Default: -
> Context: `http`

Read the certificate file required for the quic (tls/1.3) encryption handshake from the specified directory in the configuration.

---
> (required)
> Syntax: **xquic_ssl_certificate_key** `/certificate key/file path`;
> Default: -
> Context: `http`

Read the certificate private key file required for the quic (tls/1.3) encryption handshake from the specified directory in the configuration. The private key is matched with the certificate public key.

---
> Syntax: **xquic_ssl_session_ticket_key** `/ticket/file path`;
> Default: -
> Context: `http`

Read the secret key file required for quic (tls/1.3) encrypted session ticket from the specified directory in the configuration. The format is the same as ssl_session_ticket_key. The session ticket function can be enabled only after configuration.

---
> Syntax: **xquic_log** `"pipe:rollback /home/admin/tengine/logs/tengine-xquic.log baknum=10 maxsize=1G interval=1d adjust=600" info`;
> Default: -
> Context: `main`

Print xquic protocol stack statistical logs to the configured specified directory. It supports rolling log mode (can be linked with the rollback module). The xquic log level can be used to control log information.

The optional range of log levels is:

* report
* fatal
* error
* warn
* stats
* info
* debug

Similar to the Tengine log level, log content with log level >= configuration level will be printed. For production environments, it is recommended to configure it to info.
The Debug log level will contain a large number of debugging logs, which will have an impact on performance. It is generally enabled for daily testing and should not be enabled in production environments.

---
> Syntax: **xquic_congestion_control** `bbr`;
> Default: `bbr`
> Context: `http`

Configure the congestion control algorithm used by xquic. The currently supported algorithm types are:

* reno
* cubic
* bbr

BBR currently corresponds to BBR v1, and the default value is bbr.(The default for Tengine 3.1.0 and previous versions is cubic.)

---
> Syntax: **xquic_socket_rcvbuf** `5242880`;
> Default: `1048576`
> Context: `http`

xquic uses socket rcvbuf size setting. The default size is 1M. After configuration, it will use socket option to set it to the kernel.

---
> Syntax: **xquic_socket_sndbuf** `5242880`;
> Default: `1048576`
> Context: `http`

xquic uses socket sndbuf size setting. The default size is 1M. After configuration, it will use socket option to set it to the kernel.

---
> Syntax: **xquic_anti_amplification_limit** `5`;
> Default: `5`
> Context: `http`

The reflection amplification factor limited by xquic during the handshake. This parameter is used to limit the amount of data returned by the server by N before the handshake completes address verification. (that is, the amount of data returned by the server <= the amount of data sent by the client * N).

The recommendation in the RFC draft for this parameter is not to exceed 3 times. Considering the size of the certificate returned by the actual handshake, the maximum setting is generally 5 times (larger is not recommended from a security perspective).
