FROM node:6.9
MAINTAINER soulteary <suyang.sy@alibaba-inc.com>

RUN echo "185.31.17.249     github.com"                                 >> /etc/hosts && \
    echo "Asia/Shanghai" > /etc/timezone

RUN sed -i s/archive.ubuntu.com/mirrors.aliyun.com/ /etc/apt/sources.list

RUN apt-get update && apt-get install -y git

COPY ./bin /tengine-website-generator/bin
COPY ./posts /tengine-website-generator/posts
COPY ./scaffolds /tengine-website-generator/scaffolds
COPY ./themes /tengine-website-generator/themes
COPY ./_config.yml /tengine-website-generator/_config.yml
COPY ./ctl.sh /tengine-website-generator/ctl.sh
COPY ./package.json /tengine-website-generator/package.json

WORKDIR /tengine-website-generator

RUN ./bin/install.sh --use-cnpm-mirror

EXPOSE 4000:4000

CMD /bin/bash