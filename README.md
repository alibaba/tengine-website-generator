# Tengine WebSite

## 准备环境

自动构建docker 环境。

```
./ctl build
```


## 开发模式

```
./ctl dev
```

打开浏览器 localhost:4000

随便修改内容，然后网站会有变化。


## 生成模式

目前有点屎，稍后修正下。

```
docker run --rm -it -p 4000:4000 -v /Users/suyang.sy/code/tengine/tengine-temp/public/:/tengine-website-generator/public tengine/website-builder bash

#进容器后输入
hexo g

# CTRL+D
# 把public内容都扔tengine-website即可。
```

