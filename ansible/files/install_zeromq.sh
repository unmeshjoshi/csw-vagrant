#!/bin/bash
set -e
set -x

cd /tmp/zeromq-2.1.11
./configure --without-libsodium
make
make install
