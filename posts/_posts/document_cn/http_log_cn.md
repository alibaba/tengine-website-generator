# ngx_http_log_module

扩展日志模块，提供syslog和pipe，以及日志采样。

开启syslog日志功能需要在编译是添加参数**--with-syslog**，否则syslog不会生效。

syslog模块兼容syslogd。使用syslog-ng需要修改配置文件以支持udp和unix-dgram，并屏蔽unix-stream：

```
source s_sys {
file ("/proc/kmsg" program_override("kernel: "));
unix-dgram ("/dev/log");
internal();
udp(ip(0.0.0.0) port(514));
};
```



## 指令

Syntax: **access_log** log_target [format [ratio=ratio] [buffer=size]] | off

Default: access_log logs/access.log combined ratio=1

Context: http, server, location


format（含）前面的各参数顺序固定，后面的参数可乱序。此格式兼容nginx原有access_log格式。

log_target

兼容以前的log_file参数，并添加下面三种日志类型：

```
file:/path/to/file
syslog:facility[:[loglevel][:[target_ip:[target_port] | target_udgram_addr][:ident]]]
"pipe:/path/to/exec parms"
```


ratio

在buffer参数前，指定tengine以固定的采样率记录日志。例如：ratio=0.0001，那么每经过10000条记录，tengine会记录一条。

如果需要使用buffer参数而不需要设置日志采样，不能省略此参数，需要设置ratio=1。

下面介绍下支持的三种log_target：

*   file

与nginx的log_file对应的类型；

*   syslog

支持通过syslog方式记录日志；

```
facility := auth | authpriv | cron | daemon | ftp | kern | lpr | mail | mark | news | security | syslog
| user | uucp | local0 | local1 | local2 | local3 | local4 | local5 | local6 | local7

loglevel := crit | err | error | emerg | panic | alert | warn | warning | info | notice | debug
loglevel默认值 = info

target_ip:[target_port]：日志输出目的主机的IP地址和端口，端口默认是UDP(514)。这里syslog只支持UDP协议

target_udgram_addr：unix dgram地址，默认为Unix dgram(/dev/log)。这里syslog只支持UNIX DGRAM协议

ident: 自定义标志，可以用于应用信息
```

例如：

```
syslog:user:info:127.0.0.1:514:ident          以user类型和info级别将日志发送给127.0.0.1:514的UDP端口，并设置应用标记为ident
syslog的输出样例："May  4 15:44:15 local ident[26490]: XXXXXXXX"
syslog:auth:err:10.232.4.28::ident            以auth类型和err级别将日志发送到主机10.232.4.28:514的UDP端口，并设置应用标记为ident
syslog:user:info:/dev/log:ident               以user类型和info级别将日志发送给本机Unix dgram(/dev/log)，并设置应用标记为ident
syslog:user::/dev/log:ident                   以user类型和info级别将日志发送给本机Unix dgram(/dev/log)，并设置应用标记为ident
syslog:user:info::ident                       以user类型和info级别将日志发送给本机Unix dgram(/dev/log)，并设置应用标记为ident
syslog:cron:debug:/dev/log                    以cron类型和debug级别将日志发送到主机Unix dgram(/dev/log)，并使用默认标记
syslog的输出样例："May  4 15:44:15 local NGINX[26490]: XXXXXXXX"
syslog:user::127.0.0.1                        以user类型和info级别将日志发送给127.0.0.1:514的UDP端口，并使用默认标记
syslog:user:debug                             以user类型和debug级别将日志发送给本机Unix dgram(/dev/log)，并使用默认标记
syslog:user                                   以user类型和info级别将日志发送给本机Unix dgram(/dev/log)，并使用默认标记
```


*   pipe

因为pipe命令行中含有空格的缘故，pipe需要使用双引号引用，命令行中的双引号需要转义。

另外pipe进程的(user, group)遵循tengine指令user的配置，如果没有使用user指令配置的话，pipe进程将遵循tengine的默认用户设置，在编译时没有制定的情况下，默认设置是(nobody, nobody)。请注意给与pipe进程适当的权限。



Syntax: **error_log** log_target [debug | info | notice | warn | error | crit]

Default: error_log logs/error.log

Context: core, http, server, location


为error_log增加syslog和pipe支持，使用同access_log。


Syntax: **syslog_retry_interval** seconds

Default: syslog_retry_interval 1800

Context: core


建立连接失败后，下一次重试的时间间隔，单位：秒。


Syntax: **log_escape ** on | off | ascii

Default: log_escape on

Context: core, http, server, location


*   'on': access日志里面对特殊字符(除了[保留或者非保留字符](http://en.wikipedia.org/wiki/Percent-encoding#Types_of_URI_characters)) 编码。
*   'off': 对所有的特殊字符都不编码。
*   'acsii': 只对不可见字符字符进行编码。

