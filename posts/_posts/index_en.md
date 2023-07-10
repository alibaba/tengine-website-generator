## Introduction


> Tengine is a web server originated by [Taobao](http://en.wikipedia.org/wiki/Taobao), the largest e-commerce website in Asia. It is based on the [Nginx](https://nginx.org/) HTTP server and has many advanced features. Tengine has proven to be very stable and efficient on some popular websites in the world, including [Taobao.com](http://www.taobao.com), [Tmall.com](http://www.tmall.com/), [Youku](https://www.youku.tv/), [AliExpress](https://www.aliexpress.com/), [Lazada](https://www.lazada.com/) and [Alibaba Cloud](https://www.aliyun.com/). 

> Tengine has been an open source project since December 2011. It is being actively developed by the Tengine team, whose core members are from [Taobao](http://en.wikipedia.org/wiki/Taobao), [Ant Group](https://en.wikipedia.org/wiki/Ant_Group), [Alibaba Cloud](https://en.wikipedia.org/wiki/Alibaba_Cloud), [Sogou](http://en.wikipedia.org/wiki/Sogou) and other Internet companies. Tengine is a community effort and everyone is encouraged to [get involved](source.html).</div>


## Features

*   All features of Nginx-1.24.0 are inherited, i.e., it is compatible with Nginx.
*   [Dynamically reconfigure the servers, locations and upstreams without reloading or restarting worker processes](document_cn/ingress/ingress.html).
*   [HTTP/3 support (QUIC v1 and draft-29)](document_cn/xquic.html).
*   [High-speed UDP transmission with kernel-bypass](document_cn/xudp.html).
*   [Dynamically reconfigure routing based on standard and custom HTTP headers, header value, and weights](document_cn/ingress/ingress_canary.html).
*   [Dynamically reconfigure timeout setting, SSL Redirects, CORS and enabling/disabling robots for the server and location](document_cn/ingress/ingress_config_cn.html).
*   Support the [CONNECT](document/proxy_connect.html) HTTP method for forward proxy.
*   Support [asynchronous SSL/TLS mode](document_cn/ngx_http_ssl_asynchronous_mode_cn.html), Could use [QAT to offload and accelerated SSL](document/tengine_qat_ssl.html).
*   Enhanced operations monitoring, such as [asynchronous log & rollback](document/ngx_log_pipe.html), [DNS caching](document/core.html), memory usage(document/ngx_debug_pool.html), etc.
*   Support [server_name](document/stream_sni.html) in Stream modlue.
*   More load balancing methods, e.g., [consistent hashing](document/http_upstream_consistent_hash.html), [session persistence](document/http_upstream_session_sticky.html), [upstream health check](document/http_upstream_check.html), and [resolving upstream domain names on the fly](document/http_upstream_dynamic.html).
*   [Input body filter](http://blog.zhuzhaoyuan.com/2012/01/a-mechanism-to-help-write-web-application-firewalls-for-nginx/) support. It's quite handy to write Web Application Firewalls using this mechanism.
*   [Dynamic scripting language (Lua)](https://github.com/alibaba/tengine/blob/master/modules/ngx_http_lua_module/README.markdown) support, which is very efficient and makes it easy to extend core functionalities.
*   Support [collecting the running status of Tengine](document/http_reqstat.html) according to specific key (domain, url, etc).
*   [Limits retries for upstream servers](document/ngx_limit_upstream_tries.html) (proxy, memcached, fastcgi, scgi, uwsgi).
*   Includes a mechanism to support [standalone processes](document/proc.html).
*   [Protects the server](document/http_sysguard.html) in case system load or memory use goes too high.
*   [Multiple CSS or JavaScript requests can be combined](document/http_concat.html) into one request to reduce download time.
*   [Removes unnecessary white spaces and comments](document/http_trim_filter.html) to reduce the size of a page.
*   The number of worker processes and CPU affinities can be set automatically.
*   [The limit_req module](document/http_limit_req.html) is enhanced with whitelist support and more conditions are allowed in a single location.
*   [Enhanced diagnostic information](document/http_footer_filter.html) makes it easier to troubleshoot errors.
*   [More user-friendly command lines](document/commandline.html), e.g., showing all compiled-in modules and supported directives.
*   Support [Dubbo protocol](https://github.com/alibaba/tengine/blob/master/docs/modules/ngx_http_dubbo_module.md)；
*   Expiration times can be specified for certain MIME types.
*   Error pages can be reset to 'default'.
*   ...


## News

*   [03/25/2021] [Tengine-2.3.3](download/tengine-2.3.3.tar.gz) development version released ([changes](changelog.html#2_3_3)).
*   [08/20/2019] [Tengine-2.3.2](download/tengine-2.3.2.tar.gz) development version released ([changes](changelog.html#2_3_2)).
*   [06/18/2019] [Tengine-2.3.1](download/tengine-2.3.1.tar.gz) development version released ([changes](changelog.html#2_3_1)).
*   [03/25/2019] [Tengine-2.3.0](download/tengine-2.3.0.tar.gz) development version released ([changes](changelog.html#2_3_0)).
*   [11/11/2018] [Tengine-2.2.3](download/tengine-2.2.3.tar.gz) development version released ([changes](changelog.html#2_2_3)).
*   [01/25/2018] [Tengine-2.2.2](download/tengine-2.2.2.tar.gz) development version released ([changes](changelog.html#2_2_2)).
*   [09/27/2017] [Tengine-2.2.1](download/tengine-2.2.1.tar.gz) development version released ([changes](changelog.html#2_2_1)).
*   [12/02/2016] [Tengine-2.2.0](download/tengine-2.2.0.tar.gz) development version released ([changes](changelog.html#2_2_0)).
*   [12/31/2015] [Tengine-2.1.2](download/tengine-2.1.2.tar.gz) stable version released ([changes](changelog.html#2_1_2)).
*   [08/12/2015] [Tengine-2.1.1](download/tengine-2.1.1.tar.gz) stable version released ([changes](changelog.html#2_1_1)).
*   [12/19/2014] [Tengine-2.1.0](download/tengine-2.1.0.tar.gz) development version released ([changes](changelog.html#2_1_0)).
*   [05/30/2014] [Tengine-2.0.3](download/tengine-2.0.3.tar.gz) development version released ([changes](changelog.html#2_0_3)).
*   [03/28/2014] [Tengine-2.0.2](download/tengine-2.0.2.tar.gz) development version released ([changes](changelog.html#2_0_2)).
*   [03/06/2014] [Tengine-2.0.1](download/tengine-2.0.1.tar.gz) development version released ([changes](changelog.html#2_0_1)).
*   [01/08/2014] [Tengine-2.0.0](download/tengine-2.0.0.tar.gz) development version released ([changes](changelog.html#2_0_0)).
*   [11/22/2013] [Tengine-1.5.2](download/tengine-1.5.2.tar.gz) stable version released ([changes](changelog.html#1_5_2)).
*   [08/29/2013] [Tengine-1.5.1](download/tengine-1.5.1.tar.gz) stable version released ([changes](changelog.html#1_5_1)).
*   [08/04/2013] We presented [Nginx Hacking at Alibaba](download/tengine@alibaba.pdf) at [COSCUP 2013](http://coscup.org/2013/en/program/#day2_am).
*   [07/31/2013] [Tengine-1.5.0](download/tengine-1.5.0.tar.gz) stable version released ([changes](changelog.html#1_5_0)).
*   [05/14/2013] [Tengine-1.4.6](download/tengine-1.4.6.tar.gz) development version released ([changes](changelog.html#1_4_6)).
*   [05/01/2013] [Tengine-1.4.5](download/tengine-1.4.5.tar.gz) development version released ([changes](changelog.html#1_4_5)).
*   [03/21/2013] [Tengine-1.4.4](download/tengine-1.4.4.tar.gz) development version released ([changes](changelog.html#1_4_4)).
*   [01/21/2013] [Tengine-1.4.3](download/tengine-1.4.3.tar.gz) development version released ([changes](changelog.html#1_4_3)).
*   [11/22/2012] [Tengine-1.4.2](download/tengine-1.4.2.tar.gz) development version released ([changes](changelog.html#1_4_2)).
*   [10/10/2012] [Tengine-1.4.1](download/tengine-1.4.1.tar.gz) development version released ([changes](changelog.html#1_4_1)).
*   [09/05/2012] [Tengine-1.4.0](download/tengine-1.4.0.tar.gz) development version released ([changes](changelog.html#1_4_0)).
*   [07/10/2012] We started the [Nginx Chinese Documentation Translation Project](nginx_docs/cn/).
*   [06/28/2012] Our [Chinese translation of Nginx's documentation](http://nginx.org/cn/) was accepted by the Nginx team.
*   [06/09/2012] We presented [Nginx Use Cases and Development at Taobao](download/taobao_nginx_2012_06.pdf) at ECOC Conference.
*   [05/25/2012] [Tengine-1.3.0](download/tengine-1.3.0.tar.gz) stable version released ([changes](changelog.html#1_3_0)).
*   [05/09/2012] [Tengine-1.2.5](download/tengine-1.2.5.tar.gz) stable version released ([changes](changelog.html#1_2_5)).
*   [03/30/2012] [Tengine-1.2.4](download/tengine-1.2.4.tar.gz) stable version released ([changes](changelog.html#1_2_4)).
*   [03/08/2012] We are writing [an open book on Nginx development](book/index.html).
*   [02/27/2012] [Tengine-1.2.3](download/tengine-1.2.3.tar.gz) stable version released ([changes](changelog.html#1_2_3)).
*   [01/11/2012] [Tengine-1.2.2](download/tengine-1.2.2.tar.gz) stable version released ([changes](changelog.html#1_2_2)).
*   [12/07/2011] We gave a talk on [Hacking Nginx](http://velocity.oreilly.com.cn/2011/index.php?func=session&name=%E6%89%93%E9%80%A0%E5%AE%89%E5%85%A8%E3%80%81%E6%98%93%E8%BF%90%E7%BB%B4%E7%9A%84%E9%AB%98%E6%80%A7%E8%83%BDWeb%E5%B9%B3%E5%8F%B0%EF%BC%9A%E6%B7%98%E5%AE%9D%E7%BD%91Nginx%E5%AE%9A%E5%88%B6%E5%BC%80%E5%8F%91%E5%AE%9E%E6%88%98) at Velocity China 2011.
*   [12/06/2011] [Tengine-1.2.1](download/tengine-1.2.1.tar.gz) stable version released ([changes](changelog.html#1_2_1)).
*   [12/02/2011] [Tengine goes open source.](opensource.html)
