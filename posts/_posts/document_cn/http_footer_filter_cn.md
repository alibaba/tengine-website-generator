# ngx_http_footer_filter_module

在请求的响应末尾输出一段内容。输出内容可配置，并支持内嵌变量。

```
location / {
    root html;
    footer_types "text/plain" "text/css" "application/x-javascript";
    footer "$host_comment";
}
```

## 指令

> Syntax: **footer** format
> Default: -
> Context: http, server, location

在每个HTTP响应的正文结尾插入指定的format内容。如果format中含有变量，会被替换为变量当前的值。

举例：

```
location / {
    footer "<!-- $hostname, $year/$month/$day $hour:$minute:$second, $request -->";
    index index.html;
}
```


---

> Syntax: **footer_types** type1 [type2] [type3]
> Default: footer_types text/html
> Context: http, server, location

定义需要插入footer的响应类型（Response Content-Type）。
