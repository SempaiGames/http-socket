#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
haxelib remove http-socket
haxelib local http-socket.zip
