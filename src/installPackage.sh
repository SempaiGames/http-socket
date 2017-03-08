#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
haxelib remove http-socket
haxelib install http-socket.zip
