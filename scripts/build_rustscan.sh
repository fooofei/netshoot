#!/usr/bin/env bash
cur=$(dirname "$(readlink -f $0)")
set -x

home=$cur/build_rustscan
mkdir -p $home
cd $home

git clone https://github.com/RustScan/RustScan.git
cd RustScan
docker build . -t rustscan/rustscan:latest

# not have arm64 version, have to build myself
# docker pull rustscan/rustscan:latest
