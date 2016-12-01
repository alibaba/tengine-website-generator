#!/bin/bash

if [ -d "./source/" ]; then
    rm -rf ./source
    echo 'source removed.';
fi

if [ -f "./db.json" ]; then
    rm ./db.json
    echo 'db.json removed.';
fi

if [ -d "./publish/" ]; then
    rm -rf ./publish
    echo 'publish removed.';
fi

