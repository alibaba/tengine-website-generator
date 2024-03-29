## 简介

>    Tengine是由[淘宝](http://en.wikipedia.org/wiki/Taobao)发起的Web服务器项目。它在[Nginx](https://nginx.org/)的基础上，针对大访问量网站的需求，添加了很多高级功能和特性。Tengine的性能和稳定性已经在大型的网站如[淘宝网](https://www.taobao.com/)，[天猫](https://www.tmall.com/)，[优酷](https://www.youku.tv/)，[全球速卖通](https://www.aliexpress.com/)，[Lazada](https://www.lazada.com/)，[阿里云](https://www.aliyun.com/)等得到了很好的检验。它的最终目标是打造一个高效、稳定、安全、易用的Web平台。

>   从2011年12月开始，Tengine成为一个开源项目，Tengine团队在积极地开发和维护着它。Tengine团队的核心成员来自于[淘宝](http://www.taobao.com/)，[蚂蚁](https://www.antgroup.com/)，[阿里云](https://www.aliyun.com/)，[搜狗](http://www.sogou.com/)等互联网企业。Tengine是社区合作的成果，我们欢迎大家[参与其中](source_cn.html)，贡献自己的力量。</div>


## 特性
*   继承Nginx-1.24.0的所有特性，兼容Nginx的配置；
*   支持[域名，证书，路由的动态无损生效](document_cn/ingress/ingress_cn.html)；
*   支持[HTTP/3 (QUIC v1和draft-29)](document_cn/xquic_cn.html)；
*   支持[bypass内核的用户态高性能UDP转发](document_cn/xudp_cn.html)；
*   支持[基于header，header值和服务权重的高级路由动态无损生效](document_cn/ingress/ingress_canary_cn.html)；
*   支持[配置timeout，强制HTTPS，CORS和robots的动态无损生效](document_cn/ingress/ingress_config_cn.html)；
*   支持HTTP的[CONNECT](document_cn/proxy_connect_cn.html)方法，可用于正向代理场景；
*   [支持异步OpenSSL](document_cn/ngx_http_ssl_asynchronous_mode_cn.html)，可使用硬件如:[QAT](document_cn/tengine_qat_ssl_cn.html)进行HTTPS的加速与卸载；
*   增强相关运维、监控能力,比如[异步打印日志及回滚](document_cn/ngx_log_pipe_cn.html),[本地DNS缓存](document_cn/core_cn.html),[内存监控](document_cn/ngx_debug_pool_cn.html)等；
*   Stream模块支持[server_name](document_cn/stream_sni_cn.html)指令；
*   更加强大的负载均衡能力，包括[一致性hash模块](document_cn/http_upstream_consistent_hash_cn.html)、[会话保持模块](document_cn/http_upstream_session_sticky_cn.html)，[还可以对后端的服务器进行主动健康检查](document_cn/http_upstream_check_cn.html)，根据服务器状态自动上线下线，以及[动态解析upstream中出现的域名](document_cn/http_upstream_dynamic_cn.html)；
*   支持输入过滤器机制，通过使用这种机制Web应用防火墙的编写更为方便；
*   支持设置proxy、memcached、fastcgi、scgi、uwsgi[在后端失败时的重试次数](document_cn/ngx_limit_upstream_tries_cn.html)；
*   [动态脚本语言Lua](https://github.com/alibaba/tengine/blob/master/modules/ngx_http_lua_module/README.markdown)支持。扩展功能非常高效简单；
*   支持按指定关键字(域名，url等)[收集Tengine运行状态](document_cn/http_reqstat_cn.html)；
*   [组合多个CSS、JavaScript文件的访问请求变成一个请求](document_cn/http_concat_cn.html)；
*   [自动去除空白字符和注释](document_cn/http_trim_filter_cn.html)从而减小页面的体积
*   自动根据CPU数目设置进程个数和绑定CPU亲缘性；
*   [监控系统的负载和资源占用从而对系统进行保护](document_cn/http_sysguard_cn.html)；
*   [显示对运维人员更友好的出错信息，便于定位出错机器；](document_cn/http_footer_filter_cn.html)；
*   [更强大的防攻击（访问速度限制）模块](document_cn/http_limit_req_cn.html)；
*   [更方便的命令行参数，如列出编译的模块列表、支持的指令等](document_cn/commandline_cn.html)；
*   [支持Dubbo协议](https://github.com/alibaba/tengine/blob/master/docs/modules/ngx_http_dubbo_module_cn.md)；
*   可以根据访问文件类型设置过期时间；
*   ……


## 动态

*   [2021-03-25] [Tengine-3.0.0](download/tengine-3.1.0.tar.gz) 开发版正式发布 ([changelog](changelog_cn.html#3_1_0))
*   [2021-03-25] [Tengine-3.0.0](download/tengine-3.0.0.tar.gz) 开发版正式发布 ([changelog](changelog_cn.html#3_0_0))
*   [2021-03-25] [Tengine-2.4.1](download/tengine-2.4.1.tar.gz) 开发版正式发布 ([changelog](changelog_cn.html#2_4_1))
*   [2021-03-25] [Tengine-2.4.0](download/tengine-2.4.0.tar.gz) 开发版正式发布 ([changelog](changelog_cn.html#2_4_0))
*   [2021-03-25] [Tengine-2.3.4](download/tengine-2.3.4.tar.gz) 开发版正式发布 ([changelog](changelog_cn.html#2_3_4))
*   [2021-03-25] [Tengine-2.3.3](download/tengine-2.3.3.tar.gz) 开发版正式发布 ([changelog](changelog_cn.html#2_3_3))
*   [2019-08-20] [Tengine-2.3.2](download/tengine-2.3.2.tar.gz) 开发版正式发布 ([changelog](changelog_cn.html#2_3_2))
*   [2019-06-18] [Tengine-2.3.1](download/tengine-2.3.1.tar.gz) 开发版正式发布 ([changelog](changelog_cn.html#2_3_1))
*   [2019-03-25] [Tengine-2.3.0](download/tengine-2.3.0.tar.gz) 开发版正式发布 ([changelog](changelog_cn.html#2_3_0))
*   [2018-11-11] [Tengine-2.2.3](download/tengine-2.2.3.tar.gz) 开发版正式发布 ([changelog](changelog_cn.html#2_2_3))
*   [2018-01-25] [Tengine-2.2.2](download/tengine-2.2.2.tar.gz) 开发版正式发布 ([changelog](changelog_cn.html#2_2_2))
*   [2017-09-27] [Tengine-2.2.1](download/tengine-2.2.1.tar.gz) 开发版正式发布 ([changelog](changelog_cn.html#2_2_1))
*   [2016-12-02] [Tengine-2.2.0](download/tengine-2.2.0.tar.gz) 开发版正式发布 ([changelog](changelog_cn.html#2_2_0))
*   [2015-12-31] [Tengine-2.1.2](download/tengine-2.1.2.tar.gz) 稳定版正式发布 ([changelog](changelog_cn.html#2_1_2))
*   [2015-08-12] [Tengine-2.1.1](download/tengine-2.1.1.tar.gz) 稳定版正式发布 ([changelog](changelog_cn.html#2_1_1))
*   [2014-12-19] [Tengine-2.1.0](download/tengine-2.1.0.tar.gz) 开发版正式发布 ([changelog](changelog_cn.html#2_1_0))
*   [2014-05-30] [Tengine-2.0.3](download/tengine-2.0.3.tar.gz) 开发版正式发布（[changelog](changelog_cn.html#2_0_3)）
*   [2014-03-28] [Tengine-2.0.2](download/tengine-2.0.2.tar.gz) 开发版正式发布（[changelog](changelog_cn.html#2_0_2)）
*   [2014-03-06] [Tengine-2.0.1](download/tengine-2.0.1.tar.gz) 开发版正式发布（[changelog](changelog_cn.html#2_0_1)）
*   [2014-01-08] [Tengine-2.0.0](download/tengine-2.0.0.tar.gz) 开发版正式发布（[changelog](changelog_cn.html#2_0_0)）
*   [2013-11-22] [Tengine-1.5.2](download/tengine-1.5.2.tar.gz) 稳定版正式发布（[changelog](changelog_cn.html#1_5_2)）
*   [2013-08-29] [Tengine-1.5.1](download/tengine-1.5.1.tar.gz) 稳定版正式发布（[changelog](changelog_cn.html#1_5_1)）
*   [2013-08-04] 我们受邀在台湾[开源人年会](http://coscup.org/2013/zh-cn/program/#day2_am)上做了[《Nginx深度开发与定制》](download/tengine@alibaba.pdf)的技术分享
*   [2013-07-31] [Tengine-1.5.0](download/tengine-1.5.0.tar.gz) 稳定版正式发布（[changelog](changelog_cn.html#1_5_0)）
*   [2013-05-14] [Tengine-1.4.6](download/tengine-1.4.6.tar.gz) 开发版正式发布（[changelog](changelog_cn.html#1_4_6)）
*   [2013-05-01] [Tengine-1.4.5](download/tengine-1.4.5.tar.gz) 开发版正式发布（[changelog](changelog_cn.html#1_4_5)）
*   [2013-03-21] [Tengine-1.4.4](download/tengine-1.4.4.tar.gz) 开发版正式发布（[changelog](changelog_cn.html#1_4_4)）
*   [2013-01-21] [Tengine-1.4.3](download/tengine-1.4.3.tar.gz) 开发版正式发布（[changelog](changelog_cn.html#1_4_3)）
*   [2012-11-22] [Tengine-1.4.2](download/tengine-1.4.2.tar.gz) 开发版正式发布（[changelog](changelog_cn.html#1_4_2)）
*   [2012-10-10] [Tengine-1.4.1](download/tengine-1.4.1.tar.gz) 开发版正式发布（[changelog](changelog_cn.html#1_4_1)）
*   [2012-09-05] [Tengine-1.4.0](download/tengine-1.4.0.tar.gz) 开发版正式发布（[changelog](changelog_cn.html#1_4_0)）
*   [2012-07-10] [Nginx文档中文翻译项目](nginx_docs/cn/)开始
*   [2012-06-28] 我们翻译的[Nginx中文文档](http://nginx.org/cn/)正式被Nginx官方接受
*   [2012-06-09] 我们在华东运维技术大会做了[《淘宝网Nginx应用、定制与开发实战》](download/taobao_nginx_2012_06.pdf)的技术分享
*   [2012-05-25] [Tengine-1.3.0](download/tengine-1.3.0.tar.gz) 稳定版正式发布（[changelog](changelog_cn.html#1_3_0)）
*   [2012-05-09] [Tengine-1.2.5](download/tengine-1.2.5.tar.gz) 稳定版正式发布（[changelog](changelog_cn.html#1_2_5)）
*   [2012-03-30] [Tengine-1.2.4](download/tengine-1.2.4.tar.gz) 稳定版正式发布（[changelog](changelog_cn.html#1_2_4)）
*   [2012-03-08] Tengine开发团队开始编写开放书籍[《Nginx开发从入门到精通》](book/index.html)
*   [2012-02-27] [Tengine-1.2.3](download/tengine-1.2.3.tar.gz) 稳定版正式发布（[changelog](changelog_cn.html#1_2_3)）
*   [2012-01-11] [Tengine-1.2.2](download/tengine-1.2.2.tar.gz) 稳定版正式发布（[changelog](changelog_cn.html#1_2_2)）
*   [2011-12-07] Tengine开发团队在Velocity大会上介绍了[《淘宝网Nginx定制实战》](http://velocity.oreilly.com.cn/2011/index.php?func=session&name=%E6%89%93%E9%80%A0%E5%AE%89%E5%85%A8%E3%80%81%E6%98%93%E8%BF%90%E7%BB%B4%E7%9A%84%E9%AB%98%E6%80%A7%E8%83%BDWeb%E5%B9%B3%E5%8F%B0%EF%BC%9A%E6%B7%98%E5%AE%9D%E7%BD%91Nginx%E5%AE%9A%E5%88%B6%E5%BC%80%E5%8F%91%E5%AE%9E%E6%88%98)的一些经验
*   [2011-12-06] [Tengine-1.2.1](download/tengine-1.2.1.tar.gz) 版本正式发布（[changelog](changelog_cn.html#1_2_1)）
*   [2011-12-02] [Tengine宣布开源](opensource_cn.html)
