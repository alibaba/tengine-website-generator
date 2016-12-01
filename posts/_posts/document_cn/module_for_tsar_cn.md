# Tengine/Nginx module for tsar

这是一个tsar模块，它可以从Tengine/Nginx端采集数据.

# 源文件

下载源文件 ([https://github.com/taobao/tsar-mod_nginx](https://github.com/taobao/tsar-mod_nginx))


# 使用指南

1. 安装 [tsar](http://code.taobao.org/p/tsar/src/).

2. 使用tsar的模块开发工具[tsardevel](http://code.taobao.org/p/tsar/src/trunk/devel/tsardevel)生成一个模块模板.(see tsar [wiki](http://code.taobao.org/p/tsar/wiki/mod/))


```
tsardevel mod_ngx
```

3. 替换模板中的mod_ngx.c.

```
make
make install
```

4. 启动tsar.

```
tsar --nginx
```




# 配置

1. 默认采集地址和端口分别为127.0.0.1,80。可以通过环境变量来修改:

**example:**

```
export NGX_TSAR_HOST=192.168.0.1
export NGX_TSAR_PORT=8080
```

2. Tengine/Nginx必须编译了stub_status模块，而且必须在配置文件中增加类似如下配置：


```
location = /nginx_status {
stub_status on;
}
```

3. 另外我们也可以使用unix域套接字，比如将NGX_TSAR_HOST指定为一个文件路径：


```
export NGX_TSAR_HOST=/tmp/nginx-tsar.sock
```

同时，Tengine/Nginx的配置文件中包含location /nginx_status的server也必须是监听在该域套接口路径上


```
listen unix:/tmp/nginx-tsar.sock;
```

4. tsar模块发送给Tengine/Nginx的uri和主机名也可以通过如下环境变量设置：

**example:**

```
export NGX_TSAR_SERVER_NAME=status.taobao.com
export NGX_TSAR_URI=/nginx_status
```
