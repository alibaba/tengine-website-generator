# Tengine WebSite

## 准备环境

为了考虑多数人不熟悉js，使用docker自动构建需要操作的环境。

Mac OSx，需要使用 https://download.docker.com/mac/stable/Docker.dmg 或老的docker tools来准备本地环境。 

Ubuntu／Centos就比较简单了，随便安一个能起docker的内核和软件包就好了。


```
# 准备源码
git clone git@github.com:soulteary/tengine-website-generator.git
# 构建镜像
./ctl build-image
```


## 开发模式

```
# 方便一边修改文档&脚本，一边预览网站结果
./ctl dev
```

打开浏览器 localhost:4000

随便修改内容，然后网站会有变化。


## 生成模式

```
./ctl release

#进容器后输入
hexo g

# CTRL+D
# 把public内容都扔tengine-website即可。
```

## 部署网站

```
./ctl deploy
```


