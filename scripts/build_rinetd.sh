#!/usr/bin/env bash
cur=$(dirname "$(readlink -f $0)")
set -x

home=$cur/build_rinetd
mkdir -p $home
cd $home

# at home dir
git clone https://github.com/fooofei/rinetd.git
go version

cd ${home}/rinetd
go mod vendor 
go build -v -mod=vendor -tags netgo -o /usr/local/bin/rinetd .

ls -al /usr/local/bin/rinetd
