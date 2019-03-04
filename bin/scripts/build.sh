#!/bin/bash
rm -rf node_modules
./bin/install.sh --use-cnpm-mirror
# rm error code
sed -i '46,51d' node_modules/hexo/lib/plugins/generator/post.js
docker build -t tengine/website-builder .
