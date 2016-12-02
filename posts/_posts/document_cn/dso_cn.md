# 动态加载模块


## 描述

*   这个模块主要是用来运行时动态加载模块，而不用每次都要重新编译Tengine.

*   如果你想要编译官方模块为动态模块，你需要在configure的时候加上类似这样的指令(--with-http_xxx_module),./configure --help可以看到更多的细节.

*   如果只想要安装官方模块为动态模块(不安装Nginx)，那么就只需要configure之后，执行 make dso_install命令.

*   动态加载模块的个数限制为128个.

*   如果已经加载的动态模块有修改，那么必须重起Tengine才会生效.

*   只支持HTTP模块.

*   模块 在Linux/FreeeBSD/MacOS下测试成功.

## 例子

```
worker_processes  1;

dso {
    load ngx_http_lua_module.so;
    load ngx_http_memcached_module.so;
}

events {
    worker_connections  1024;
}
```

## 指令

> **Syntax**: _path path_
> **Default**: _none_
> **Context**: _dso_

path 主要是设置默认的动态模块加载路径。

### 例子

```
path /home/dso/module/;

```

设置默认的动态模块加载路径为`/home/dso/module/`.

---

> **Syntax**: _load [module_name] [module_path]_
> **Default**: _none_
> **Context**: _dso_

load命令用于在指定的路径(module_path),将指定的模块(module_name)动态加载到Nginx中。

其中module_path和module_name可以只写一个,如果没有module_path参数，那么默认path是 $(modulename).so.

如果没有module_name参数，那么默认name就是module_path删除掉".so"后缀.

对于module_path的路径查找，这里是严格按照下面的顺序的

1. module_path指定的是绝对路径。
2. 相对于dso_path设置的相对路径.
3. 相对于默认的加载路径的相对路径(NGX_PREFIX/modules或者说configure时通过--dso-path设置的路径).

### 例子

```
load ngx_http_empty_gif_module  ngx_http_empty_gif_module.so;
load ngx_http_test_module;
load ngx_http_test2_module.so;

```

将会从ngx_http_empty_gif_module.so.加载empty_gif模块。以及从ngx_http_test_module.so加载ngx_http_test_module模块.第三条指令是从ngx_http_test2_module.so加载ngx_http_test2_module模块.

---

> **Syntax**: _module_stub module_name_
> **Default**: _none_
> **Context**: _dso_

这个指令主要是将你需要的动态模块插入到你所需要的位置(可以看conf/module_stubs这个文件),这个命令要很小心使用，因为它将会改变你的模块的运行时顺序(在Nginx中模块都是有严格顺序的).而大多数时候这个命令都是不需要设置的。

### 示例


```
module_stub ngx_core_module;
module_stub ngx_errlog_module;
module_stub ngx_conf_module;
module_stub ngx_events_module;
module_stub ngx_event_core_module;
module_stub ngx_epoll_module;
module_stub ngx_openssl_module;
module_stub ngx_http_module;
module_stub ngx_http_core_module;
.......................
module_stub ngx_http_addition_filter_module;
module_stub ngx_http_my_filter_module;
```

上面这个例子将会插入my_filter模块到addition_filter之前执行。

---

> **Syntax**: _include file_name_
> **Default**: _none_
> **Context**: _dso_

include命令主要用于指定一个文件，这个文件里面包含了对应模块顺序(module_stub指令),有关于module_stub指令可以看下面的module_stubs部分.

### 示例


```
include module_stubs

```

将会加载conf/module_stubs这个文件，这个文件主要是由(module_stub指令组成).

---

## 如何编译动态模块

如果你想要在安装完Tengine之后，编译官方模块为动态模块，那么你需要按照如下的步骤:

*   在configure的时候打开你想要编译的模块.
```
$ ./configure --with-http_sub_module=shared
```
*   编译它.
```
$ make
```
*   安装动态模块.
```
$ make dso_install
```

它将会复制动态库文件到你的动态模块目录，或者你也可以手工拷贝动态模块文件(文件是在objs/modules)到你想要加载的目录.

你能够使用dso_tool(在Nginx安装目录的sbin下)这个工具来编译第三方模块.

### 示例

```
./dso_tool --add-module=/home/dso/lua-nginx-module
```

将会编译ngx_lua模块为动态库，然后安装到默认的模块路径.如果你想要安装到指定位置，那么需要指定--dst选项(更多的选项请使用dso_tool -h查看).
