#!/bin/bash

if [ ! -d "./node_modules/" ]; then
    for ARGV in "$1"
        do
            case $ARGV in
                '--use-cnpm-mirror')
                    npm install --production --registry=https://registry.npm.taobao.org
                ;;
                *)
                    npm install --production
                ;;
            esac
    done
else
    echo 'npm install finished.';
fi