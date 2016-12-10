#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; cd ./; pwd)

mkdir -p $BASE_DIR/public

docker run --rm -it -v $BASE_DIR/public:/tengine-website-generator/public tengine/website-builder bin/release.sh

cp -r $BASE_DIR/posts/book $BASE_DIR/public
