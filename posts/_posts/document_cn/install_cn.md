# 简单例子

如果你想编译和安装Tengine，下面是一个简单的例子：

```
$ ./configure

$ make

$ sudo make install
```

Tengine默认将安装在/usr/local/nginx目录。你可以用'--prefix'来指定你想要的安装目录。

## configure脚本的选项

大部分的选项跟Nginx是兼容的。下面列出的都是Tengine特有的选项。如果你想查看Tengine支持的所有选项，你可以运行'./configure --help'命令来获取帮助。


#### --dso-path

设置DSO模块的安装路径。


#### --dso-tool-path

设置dso_tool脚本本身的安装路径。


#### --without-dso

关闭动态加载模块的功能。


#### --with-jemalloc

让Tengine链接jemalloc库，运行时用jemalloc来分配和释放内存。


#### --with-jemalloc=path

设置jemalloc库的源代码路径，Tengine可以静态编译和链接该库。

## make的目标选项

大部分的目标选项跟Nginx是兼容的。下面列出的是Tengine特有的选项。


#### make test

运行Tengine的测试用例。你首先需要安装perl来运行这个指令。


#### make dso_install

将动态模块的so文件拷贝到目标目录。这个目录可以通过'--dso-path'设置。默认是在Tengine安装目录下面的modules目录。

