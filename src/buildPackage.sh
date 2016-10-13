#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
rm -f http-socket.zip
zip -r http-socket.zip httpSocket haxelib.json include.xml
