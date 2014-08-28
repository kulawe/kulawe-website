#! /bin/bash

rm -rf ./public
hugo --theme="kulawe-blue"
cp -r ./cgi-bin ./public
cp ./robots.txt ./public
cp ./.htaccess ./public


