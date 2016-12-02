#!/usr/bin/env node

var cheerio = require('cheerio');
var fs = require('fs');
var path = require('path');

var paths = [
    path.join(process.env.PWD, 'public/changelog.html'),
    path.join(process.env.PWD, 'public/changelog_cn.html')
];

function update(filePath) {
    var $ = cheerio.load(fs.readFileSync(filePath, 'utf-8'));
    var result = [];
    $('#main .article-entry > h4 > a').each(function (k, item) {
        var target = $(item);
        var title = target.attr('title');
        if (title) {
            var version = title.match(/^Tengine\-(.*)\s\[.*/);
            if (version) {
                version = version[1];
                var final = version.replace(/\./g, '_');
                result.push(final);
                target.attr('href', '#' + version.replace(/\./g, '_'));
            }
        }
    });
    console.log('修复页面', path.basename(filePath), '#' + result.join('\t#'), '\n');
    fs.writeFileSync(filePath, $.html(), 'utf-8');
}

paths.map(function (v) {
    update(v);
});
