#!/usr/bin/env bash
cur=$(dirname "$(readlink -f $0)")
set -x
set -e

sh -x ${cur}/build_ping.sh
sh -x  ${cur}/build_rustscan.sh

# 以时间戳作为版本号
# 格式为 20201007163924
version=`date +"%Y%m%d%H%M%S"`
image_name=swr.cn-north-4.myhuaweicloud.com/fooofei/netshoot:aarch64-${version}

cd ${cur}/..
docker build . -t ${image_name}
docker login -u cn-north-4@B1Q1DM5XDUUGNAHACWCE -p 3e70145984642dfb2d9073bb00b6b79f4910a9e90d340a37ca3ce1c231626ef2 swr.cn-north-4.myhuaweicloud.com
docker push ${image_name}

docker images
