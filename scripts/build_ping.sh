#!/usr/bin/env bash

set -x

cur=$(dirname "$(readlink -f $0)")

home=$cur/build_ping
mkdir -p $home
cd $home
git clone https://github.com/fooofei/go_pieces.git
build_dir=$home/go_pieces/tool/xping
cd $build_dir
go build -v
pwd
ls -alh

# copy files
mkdir -p $cur/../bin
mv $build_dir/tcping/tcping $cur/../bin
mv $build_dir/httping/httping $cur/../bin
