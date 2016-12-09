#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; cd ..; pwd)

docker run --rm -it -p 4000:4000 -v $BASE_DIR/public:/tengine-website-generator/public:ro -v $BASE_DIR/posts:/tengine-website-generator/posts:r tengine/website-builder bin/dev.sh