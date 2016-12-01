# ngx_http_stub_status_module

增加对每请求的响应时间的统计：在stub status模块中增加了自Tengine启动以来所有请求的总响应时间(request_time)，单位为ms，可以用来统计一段时间的平均RT(response time)：

```
Active connections: 1
server accepts handled requests request_time
1140 1140 1140 75806
Reading: 0 Writing: 1 Waiting: 0
```


在tsar中监控Tengine/Nginx可以使用我们开发的tsar模块。([使用介绍](module_for_tsar_cn.html))
