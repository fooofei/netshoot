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
bash -x build.sh
mv cmd/tcp/tcp-linux-amd64 /usr/local/bin/tcping
mv cmd/http/http-linux-amd64 /usr/local/bin/httping

ls -al /usr/local/bin/tcping
ls -al /usr/local/bin/httping
