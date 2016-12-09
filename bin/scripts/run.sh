#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; cd ../../; pwd)
docker run --rm -it -p 4000:4000 tengine/website-builder bin/dev.sh