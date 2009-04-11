#!/bin/bash

set -e

echo Looking for gnulib-tool
gnulib-tool --libtool --import memchr memcpy strndup strerror error getopt long-options stdint crc
autoreconf
