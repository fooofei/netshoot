#!/usr/bin/env bash
cur=$(dirname "$(readlink -f $0)")
set -x

home=$cur/build_topic
mkdir -p $home
cd $home

# at home dir
git clone https://github.com/silenceshell/topic.git
go version

cd $topic
go mod vendor 
go build -v -mod=vendor -tags netgo -o /usr/local/bin/topic ./cmd/topic/

ls -al /usr/local/bin/topic
