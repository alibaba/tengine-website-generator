#!/bin/bash

rm -rf public

./node_modules/.bin/hexo generate
./node_modules/.bin/hexo generate

rm -rf public/page/
rm -rf public/taocode_ad*
rm -rf public/tengine_ad*
rm -f public/js/app.js

node ./bin/updateChangelogHash.js