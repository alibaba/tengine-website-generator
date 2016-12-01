---
title: "ngx_http_stub_status_module"
date: "2016-12-02 03:37:32"
---


The total requests' response time, which is in millisecond, is also recorded in the Tengine.

So you can calculate the mean response time. Here is an example of the output of stub_status:

```
Active connections: 1
server accepts handled requests request_time
1140 1140 1140 75806
Reading: 0 Writing: 1 Waiting: 0
```


If you want to use tsar with Tengine/Nginx, you can use the module for tsar.([quick start](module_for_tsar.html))
