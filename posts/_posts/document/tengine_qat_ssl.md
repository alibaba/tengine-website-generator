## Introduction

This project provides an extended Tengine working with asynchronous mode OpenSSL. With Intel® QuickAssist Technology(QAT) acceleration, the asynchronous mode Tengine can provide significant performance improvement.
## Installation Instructions

### Setup building environment

Set the following environmental variables:

```   
ICP_ROOT is the directory where QAT driver source code is located
NGINX_INSTALL_DIR is the directory where nginx will be installed to
OPENSSL_LIB is the directory where the openssl has been installed to
```
For example: 

```    
$ export ICP_ROOT=/QAT/QAT1.6
$ export ICP_BUILD_OUTPUT=$ICP_ROOT/build
$ export OPENSSL_ROOT=/openssl
$ export OPENSSL_LIB=$OPENSSL_ROOT/.openssl
$ export LD_LIBRARY_PATH=$OPENSSL_ROOT/.openssl/lib
$ export OPENSSL_ENGINES=$OPENSSL_LIB/lib/engines-1.1
$ export NGINX_INSTALL_DIR=/tengine-installed/tengine-2.2.2
```

### Build OpenSSL

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

### Build QAT driver 

```    
$ mkdir /QAT/
$ cd /QAT/
$ wget https://01.org/sites/default/files/page/qatmux.l.2.6.0-60.tgz
$ tar xzvf qatmux.l.2.6.0-60.tgz
$ ./installer.sh (choose 3)
```

### Build QAT engine

```     
$ cd /
$ git clone --branch v0.5.30 https://github.com/01org/QAT_Engine.git
$ cd /QAT_Engine-0.5.30/qat_contig_mem
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

Note: The kernel version needs to be greater than or equal to 3.1.0.7, need openssl-devel zlib-devel library.
```

More details instructions about QAT can be found on QAT engine github [page](https://github.com/intel/QAT_Engine#installation-instructions).

### Build Tengine   

```
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

---

More details instructions about Async Mode Nginx can be found on Intel Async Mode Nginx github [page](https://github.com/intel/asynch_mode_nginx).

### Configuration   

Tengine configuration
Async Mode Tengine provides new directives:

---

```
Directives
Syntax:     ssl_async on | off;
Default:    ssl_async off;
Context:    http, server
Enables SSL/TLS asynchronous mode
```

---

For example, edit conf/nginx.conf

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


### QAT driver configuration

The Intel® QAT OpenSSL* Engine comes with some example conf files to use with the Intel® QAT Driver. For Tengine integrated with Intel QAT CLC production, using below commands:

```
$ cp QAT_Engine/qat/config/dh89xxcc/multi_process_optimized/dh89xxcc_qa_dev0.conf /etc
$ service qat_service restart
```

For more details about QAT driver configuration, please refer to QAT engine github [page](https://github.com/intel/QAT_Engine#using-the-openssl-configuration-file-to-loadinitialize-engines)

### QAT engine enabling and configuration

QAT engine will be installed as a shared object into OpenSSL installed path and leveraging OpenSSL engine framework to be initialized and configured. Add configuration in $OPENSSL_LIB/ssl/openssl.cnf
Note: this configuration should be added on top of the file:

```    
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

## Performance

Please refer to the White Paper: Intel® Quickassist Technology and OpenSSL-1.1.0:[Performance](https://01.org/sites/default/files/downloads/intelr-quickassist-technology/intelquickassisttechnologyopensslperformance.pdf).

### Limitations

Nginx supports reload operation, when QAT hardware is involved for crypto offload, user should enure that there are enough number of qat instances. For example, the available qat instance number should be 2x equal or more than Nginx worker process number.
For example, in Nginx configuration file (nginx.conf) worker process number is configured as

worker_processes 16;

Then the instance configuration in QAT driver configuration file should be:

```    
[SHIM]
NumberCyInstances = 1
NumberDcInstances = 0
NumProcesses = 32
LimitDevAccess = 1
```

Please refer to details [QAT develop doc](https://01.org/sites/default/files/page/330751-006_clc_pg.pdf).
