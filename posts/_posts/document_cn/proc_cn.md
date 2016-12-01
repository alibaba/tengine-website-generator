# 提供一种可以通过实现模块来启动独立进程的机制

你可以在[http://tengine.taobao.org/examples/ngx_proc_daytime_module](../../examples/ngx_proc_daytime_module)这里找到一个示例模块

## 例子

processes {
process echo {
echo on;
echo_str "hello, world";
listen 8888;
count 1;
priority 1;
delay_start 10s;
respawn off;
}

process example {
count 1;
priority 0;
delay_start 0s;
respawn on;
}
}

## 指令


Syntax: **process** `name { }`

Default: `none`

Context: `processes`


Syntax: **count** `num`

Default: `1`

Context: `process`

指定启动的进程数。


Syntax: **priority** `num`

Default: `0`

Context: `process`

指定进程的优先级(-20 - 20 之间)，越低的数值其被调度的优先级越高。


Syntax: **delay_start** `time`

Default: `0s`

Context: `process`

设置进程启动的延迟时间。


Syntax: **respawn** `on | off`

Default: `on`

Context: `process`

如果设置了这个指令，进程在异常推出时会被Tengine重新启动。
