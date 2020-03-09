#!/usr/bin/env bash

set -x

cur=$(dirname "$(readlink -f $0)")

home=$cur/build_ping
mkdir -p $home
cd $home
git clone https://github.com/fooofei/go_pieces.git
build_dir=$home/go_pieces/tool/xping

mkdir -p $cur/../bin

cd $build_dir/tcping
go build -v
ls -alh
mv $build_dir/tcping/tcping $cur/../bin

cd $build_dir/httping
go build -v
ls -alh
mv $build_dir/httping/httping $cur/../bin
