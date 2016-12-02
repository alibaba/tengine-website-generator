# ngx_http_headers_module

在nginx本身原有的设置过期时间的基础上，增加了expires_by_types指令，用于根据Content-Type来设置过期时间。

原有的功能介绍看[这里](http://wiki.nginx.org/HttpHeadersModule)。

```
expires_by_types       24h text/html;
expires_by_types       modified +24h text/xml;
expires_by_types       @15h30m text/xml;
expires_by_types       0 text/xml;
expires_by_types       -1 text/xml;
expires_by_types       epoch text/xml;
```

## 指令

> Syntax: expires_by_types [[modified] time | @time-of-day | epoch | max | off] content-type1 [content-type2] [content-type3] ...
> Default: -
> Context: http, server, location


该指令配置过期时间及其对应的content-type。过期时间的配置可参考expires的配置。在配置时间之后，可加上一到多个content-type。

注意，在即有expires也有expires_by_types出现时，规则如下：

*   在同一级别中，如果同时出现expires与expires_by_type时，出现在expires_by_type中的content-type会优先选择expires_by_types中配置的，而没有出现在content-type中的，会选择expires中配置的；
*   当本级别与上一级别都没有配置expires off时，expires与expires_by_types当本级别没有配置时分配继承上一级别的配置信息，然后再按照规则一执行；
*   当本级别配置有expires off时，此时模块会忽略expires_by_types的所有配置，并禁用掉expires；
*   当本级别没有配置expires，而上一级别有配置expires off时，本级别的expires_by_types将不受上一级别的expires的影响。

如：

```
location /url {
expires                10s;
expires_by_types       24s text/html;
}
```

此时，/url下面的文档，text/html类型的会返回24s的过期时间，而其它类型的会返回10s的过期时间。

```
expires                    10s;
expires_by_types           24s text/html;

location /url {
expires_by_types       20s text/rss;
}
```

此时，/url下面的文档，text/rss类型的会返回20s的过期时间，而其它类型的会返回10s的过期时间。因为location里面的expires_by_types将上层的expires_by_types覆盖了。而expires 10s则被继承了下来。

```
expires                    10s;
expires_by_types           24s text/html;

location /url {
expires off;
expires_by_types       20s text/rss;
}
```

此时，/url下面的所有文档，都不会有过期时间。

```
expires off;
expires_by_types           24s text/html;

location /url {
expires_by_types       20s text/rss;
}
```

此时，/url下面的文档，text/rss类型的会返回20s的过期时间，其它类型的没有过期时间。注意，expires off不会继承过来。
