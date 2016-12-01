# ngx_http_sysguard_module

This module can be used to protect your server in case system load, memory use goes too high or requests are responded too slow.

To use this module, you should enable it first:

./configure --with-http_sysguard_module

## Examples

```
server {
sysguard on;

sysguard_load load=10.5 action=/loadlimit;
sysguard_mem swapratio=20% action=/swaplimit;
sysguard_mem free=100M action=/memlimit;
sysguard_rt rt=0.01 period=5s action=/rtlimit;

location /loadlimit {
return 503;
}

location /swaplimit {
return 503;
}

location /memlimit {
return 503;
}

location /rtlimit {
return 503;
}

}
```

Note this module requires the sysinfo(2) system call, or getloadavg(3) function in glibc. It also requires the /proc file system to get memory information.

## Directive

Syntax: **sysguard** [on | off]

Default: sysguard off

Context: http, server, location

Turn on or off this module.


Syntax: **sysguard_load** load=number [action=/url]

Default: none

Context: http, server, location


Specify the load threshold.

When the system load exceeds this threshold, all subsequent requests will be redirected to the URL specified by the 'action' parameter. Tengine will return 503 if there's no 'action' URL defined. This directive also support using ncpu*ratio to instead of the fixed threshold, 'ncpu' means the number of cpu's cores, you can use this directive like this: load=ncpu*1.5


Syntax: **sysguard_mem** [swapratio=ratio%] [free=size] [action=/url]

Default: none

Context: http, server, location


Specify the used swap memory or free memory threshold.

When the swap memory use ratio exceeds this threshold or memory free less than the size, all subsequent requests will be redirected to the URL specified by the 'action' parameter. Tengine will return 503 if there's no 'action' URL. Sysguard uses this strategy to calculate memory free: "memfree = free + buffered + cached"


Syntax: **sysguard_rt** [rt=second] [period=time] [action=/url]

Default: none

Context: http, server, location


Specify the response time threshold.

Parameter rt is used to set a threshold of the average response time, in second. Parameter period is used to specifiy the period of the statistics cycle. If the average response time of the system exceeds the threshold specified by the user, the incoming request will be redirected to a specified url which is defined by parameter 'action'. If no 'action' is presented, the request will be responsed with 503 error directly.


Syntax: **sysguard_mode** [and | or]

Default: sysguard_mode or

Context: http, server, location


If there are more than one type of monitor, this directive is used to specified the relations among all the monitors which are: 'and' for all matching and 'or' for any matching.


Syntax: **sysguard_interval** time

Default: sysguard_interval 1s

Context: http, server, location


Specify the time interval to update your system information.

The default value is one second, which means tengine updates the server status once a second.


Syntax: **sysguard_log_level** [info | notice | warn | error]

Default: sysguard_log_level error

Context: http, server, location


Specify the log level of sysguard.
