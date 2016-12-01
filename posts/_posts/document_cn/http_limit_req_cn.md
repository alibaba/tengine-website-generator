# ngx_http_limit_req_module

## 指令

Syntax: **limit_req_log_level** info | notice | warn | error

Default: limit_req_log_level warn

Context: http

和nginx相同。

Syntax: **limit_req_zone** $session_variable1 $session_variable2 ... zone=name_of_zone:size rate=rate

Default: -

Context: http

和nginx类似，不过支持多个变量，并且支持多个limit_req_zone的设置。比如：

```
limit_req_zone $binary_remote_addr zone=one:3m rate=1r/s;
limit_req_zone $binary_remote_addr $uri zone=two:3m rate=1r/s;
limit_req_zone $binary_remote_addr $request_uri zone=thre:3m rate=1r/s;
```

上面的第二个指令表示当相同的ip地址并且访问相同的uri，会导致进入limit req的限制（每秒1个请求）。

Syntax: **limit_req** [on | off] | zone=zone burst=burst [forbid_action=action] [nodelay]

Default: -

Context: http, server, location

zone，burst以及nodelay的使用与nginx的limit req模块中相同。

支持开关，默认是打开状态。并且一个location支持多个limit_req指令，当有多个limit_req指令的话，这些指令是或的关系，也就是当其中任意一个限制被触发，则执行对应的limit_req。

forbid_action表示当条件被触发时，nginx所要执行的动作，支持name location和页面(/)，默认是返回503。比如：

```
limit_req_zone $binary_remote_addr zone=one:3m rate=1r/s;
limit_req_zone $binary_remote_addr $uri zone=two:3m rate=1r/s;
limit_req_zone $binary_remote_addr $request_uri zone=three:3m rate=1r/s;

location / {
limit_req zone=one burst=5;
limit_req zone=two forbid_action=@test1;
limit_req zone=three burst=3 forbid_action=@test2;
}

location /off {
limit_req off;
}

location @test1 {
rewrite ^ /test1.html;
}

location @test2 {
rewrite ^  /test2.html;
}
```


Syntax: **limit_req_whitelist** geo_var_name=var_name geo_var_value=var_value

Default: -

Context: http, server, location

表示白名单，要协同geo模块进行工作，其中geo_var_name表示geo模块设置的变量名，而geo_var_value表示geo模块设置的变量值。比如：

```
geo $white_ip {
ranges;
default 0;
127.0.0.1-127.0.0.255 1;
}

limit_req_whitelist geo_var_name=white_ip geo_var_value=1;
```

上面表示ip 127.0.0.1-127.0.0.255这个区间都会跳过limit_req的处理。
