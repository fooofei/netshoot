#!/usr/bin/env bash
cur=$(dirname "$(readlink -f $0)")
set -x

home=$cur/build_ping
mkdir -p $home
cd $home

# at home dir
git clone https://github.com/fooofei/go_pieces.git
pkg_base_dir=$home/go_pieces/tools/xping
go version

cd $pkg_base_dir
go mod vendor
go build -v -mod=vendor -tags netgo -o /usr/local/bin/tcping ./tcping/
go build -v -mod=vendor -tags netgo -o /usr/local/bin/httping ./httping/

ls -al /usr/local/bin/tcping
ls -al /usr/local/bin/httping
