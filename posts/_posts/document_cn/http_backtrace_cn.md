# ngx_http_backtrace_module

## 指令

> Syntax: **backtrace_log** log_path
> Default: backtrace_log error.log
> Context: main

设置backtrace log的名字，如果log_path以'/'开头，则将会是绝对路径，否则将会放入nginx安装目录的conf文件夹下。比如：

```
backtrace_log test.log
```

---


> Syntax: **backtrace_max_stack_size** size
> Default: backtrace_max_stack_size 30
> Context: main

设置backtrace模块所打印的栈的最大长度。
