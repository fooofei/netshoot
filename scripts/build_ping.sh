#!/usr/bin/env bash
cur=$(dirname "$(readlink -f $0)")
set -x

home=$cur/build_ping
mkdir -p $home
pushd $home

# at home dir
git clone https://github.com/fooofei/go_pieces.git
pkg_base_dir=$home/go_pieces/tool/xping
go version

pushd $pkg_base_dir
go build -v -tags netgo -o $cur/bin/tcping ./tcping/
go build -v -tags netgo -o $cur/bin/httping ./httping/
popd

popd
