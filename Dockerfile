FROM node:6.9
MAINTAINER soulteary <suyang.sy@alibaba-inc.com>

RUN echo "185.31.17.249     github.com"                                 >> /etc/hosts && \
    echo "Asia/Shanghai" > /etc/timezone

RUN sed -i s/archive.ubuntu.com/mirrors.aliyun.com/ /etc/apt/sources.list

RUN apt-get update && apt-get install -y git

COPY ./ /tengine-website-generator

WORKDIR /tengine-website-generator

RUN ./bin/install.sh --use-cnpm-mirror

RUN npm install -global hexo hexo-cli --registry=https://registry.npm.taobao.org --silent

EXPOSE 4000:4000

CMD /bin/bash