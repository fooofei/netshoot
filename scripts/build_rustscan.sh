#!/usr/bin/env bash
cur=$(dirname "$(readlink -f $0)")
set -x

home=$cur/build_rustscan
mkdir -p $home
cd $home

git clone https://github.com/fooofei/rustscan-build.git rustscan
bash ${home}/rustscan/build.sh
