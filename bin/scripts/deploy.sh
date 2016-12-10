#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; cd ./; pwd)
USER=$(whoami)

docker run --rm -it \
       -v $BASE_DIR/public:/tengine-website-generator/public:rw \
       -v /Users/$USER/.ssh:/root/.ssh:ro \
       -v /Users/$USER/.gitconfig:/root/.gitconfig:ro \
       tengine/website-builder bin/deploy.sh
