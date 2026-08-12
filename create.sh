#!/bin/env sh

zig build
cp zig-out/bin/goomy Goomy.app/Contents/MacOS/goomy
