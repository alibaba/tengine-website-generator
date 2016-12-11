#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; cd ./; pwd)

docker run --rm -it -p 4000:4000 -v $BASE_DIR/posts:/tengine-website-generator/posts:ro tengine/website-builder bin/dev.sh