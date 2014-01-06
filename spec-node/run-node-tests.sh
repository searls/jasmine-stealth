#!/bin/bash

npm install
rm -rf node_modules/grunt-jasmine-bundle/node_modules/jasmine-stealth
ln -s "$(pwd)/.." node_modules/grunt-jasmine-bundle/node_modules/jasmine-stealth
cp ../spec/*.coffee spec
grunt spec:unit
rm spec/*.coffee
