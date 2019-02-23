## 简介

本项目为Tengine提供了基于OpenSSL异步SSL/TLS模式的增强。启用异步模式下使用外部专用算法加速硬件如Intel® QuickAssist Technology(QAT) 加速器可以显著提高SSL/TLS握手阶段性能。

## 安装方法 

### 设置环境变量    


例如

```     
$ export ICP_ROOT=/QAT/QAT1.6
$ export ICP_BUILD_OUTPUT=$ICP_ROOT/build
$ export OPENSSL_ROOT=/openssl
$ export OPENSSL_LIB=$OPENSSL_ROOT/.openssl
$ export LD_LIBRARY_PATH=$OPENSSL_ROOT/.openssl/lib
$ export OPENSSL_ENGINES=$OPENSSL_LIB/lib/engines-1.1
$ export NGINX_INSTALL_DIR=/tengine-installed/tengine-2.2.2
```

注意：

```    
ICP_ROOT 指向QAT驱动的目录
NGINX_INSTALL_DIR 指向Tengine的安装目录
OPENSSL_LIB 指向OpenSSL的安装目录
```


### 编译OpenSSL库

```   
$ cd / 
$ git clone --branch OpenSSL_1_1_0f https://github.com/openssl/openssl.git
$ mv OpenSSL_1_1_0f openssl
$ cd openssl
$ mkdir .openssl
$ ./config --prefix=`pwd`/.openssl
$ make
$ make install
```

### 编译QAT驱动程序 

```   
$ mkdir /QAT
$ cd /QAT/
$ wget https://01.org/sites/default/files/page/qatmux.l.2.6.0-60.tgz
$ tar xzvf qatmux.l.2.6.0-60.tgz
$ ./installer.sh (选择 3)
```

### 编译QAT engine

```  
$ cd / 
$ git clone --branch v0.5.30 https://github.com/01org/QAT_Engine.git
$ cd QAT_Engine-0.5.30/qat_contig_mem
$ make
$ make load
$ make test
$ cd /QAT_Engine-0.5.30
$ ./configure \
    --with-qat_dir=$ICP_ROOT \
    --with-openssl_dir=$OPENSSL_ROOT \
    --with-openssl_install_dir=$OPENSSL_LIB 
$ make
$ make install

注意：kernel版本需要大于等于3.1.0.7, 依赖openssl-devel、zlib-devel库。
```

更多关于QAT相关编译选项可以参考QAT engine项目在github上的详细[文档](https://github.com/intel/QAT_Engine#installation-instructions)。

### 编译Tengine:


```    
下载(Tengine)[http://tengine.taobao.org/download/tengine-2.2.2.tar.gz],然后解压进入`Tengine`目录执行如下命令

$ mkdir /tengine-installed
$ wget http://tengine.taobao.org/download/tengine-2.2.2.tar.gz
$ tar zxf tengine-2.2.2.tar.gz
$ cd tengine-2.2.2

$ ./configure \
    --prefix=$NGINX_INSTALL_DIR \
    --with-http_ssl_module \
    --with-openssl-async \
    --with-cc-opt="-DNGX_SECURE_MEM -I$OPENSSL_LIB/include \
    -Wno-error=deprecated-declarations" \
    --with-ld-opt="-Wl,-rpath=$OPENSSL_LIB/lib -L$OPENSSL_LIB/lib"
$ make
$ make install
```


更多关于Nginx异步模式编译细节可以参考Intel Async Mode Tengine项目在github 上的详细[文档](https://github.com/intel/asynch_mode_nginx)。


### Tengine 配置（启用异步OpenSSL）    

异步模式的Tengine提供一个新的配置项如下：

```
Directives
Syntax:     ssl_async on | off;
Default:    ssl_async off;
Context:    http, server
Enables SSL/TLS asynchronous mode
```

例如可以在相应的配置文件中(conf/nginx.conf)添加如下配置项以启用异步模式:

---

```   
http {
    ……
    server {
        ssl_async  on;
        ……
        }
    }
}
```

### QAT 驱动的配置

Intel® QAT OpenSSL* Engine 提供了QAT驱动的示例配置文件，对于使用Intel QAT CLC加速卡对Tengine进行加速的场景，可以使用如下命令启用配置文件:
 
```
$ cp /QAT_Engine/qat/config/dh895xcc/multi_process_optimized/dh895xcc_qa_dev0.conf /etc
$ service qat_service restart
```

更多关于QAT驱动配置文件的说明请参考Intel QAT engine项目在github上的[说明](https://github.com/intel/QAT_Engine#using-the-openssl-configuration-file-to-loadinitialize-engines)。


### QAT engine 的使用和配置   

QAT engine以共享库的方式安装至OpenSSL安装目录，并使用OpenSSL engine框架进行加载和配置。在OpenSSL配置文件 $OPENSSL_LIB/ssl/openssl.cnf中添加如下配置以默认启用QAT engine并依据相应算法配置进行初始化。
注意：根据OpenSSL配置要求，engine的配置需要在文件最开头添加才能生效，建议用下面的配置直接替换掉原有的openssl.cnf内容。OpenSSL配置文件可以参考官方[说明](https://www.openssl.org/docs/manmaster/man5/config.html)或QAT engine项目中的具体[说明](https://github.com/intel/QAT_Engine#using-the-openssl-configuration-file-to-loadinitialize-engines)。

```    
# This must be in the default section
openssl_conf = openssl_def
[openssl_def]
engines = engine_section
[engine_section]
qat = qat_section
[qat_section]
engine_id = qat
dynamic_path = /openssl/.openssl/lib/engines-1.1/qat.so
default_algorithms = ALL
```

### 性能分析

详细的性能分析见Intel白皮书: Intel® Quickassist Technology and OpenSSL-1.1.0:[性能数据](https://01.org/sites/default/files/downloads/intelr-quickassist-technology/intelquickassisttechnologyopensslperformance.pdf)。

### 使用限制

Tengine支持软重启操作， 这意味着在原来worker推出前，新的worker会启动并根据配置初始化QAT engine以及QAT硬件。QAT硬件仅提供有限的进程数量支持，具体来说进程通过获取硬件的实例 (instance) 来使用硬件。典型的QAT驱动最多支持64个实 例，使用者需要保证在进行Tengine软重启的过程中有足够的QAT实例可用以避免硬件初始化错误。举例来说，如需支持Tengine的软重启操作，要保证预留一半的QAT实例。例如Tengine启用如下配置，启动了16个工作进程 (worker) worker_processes 16;

在QAT相应的配置文件中可以按照如下配置，即配个进程最多可申请到1个QAT实例，最多支持32个进程同时申请QAT实例。

``` 
[SHIM]
NumberCyInstances = 1
NumberDcInstances = 0
NumProcesses = 32
LimitDevAccess = 1
```  


更多详细使用手册请参考[Tengine](tengine.taobao.org)异步OpenSSL使用[QAT加速卸载实战](http://tengine.taobao.org/document_cn/tengine_qat_ssl_cn.html)。


