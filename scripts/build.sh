#!/usr/bin/env bash
cur=$(dirname "$(readlink -f $0)")
set -x
set -e

bash -x  ${cur}/build_rustscan.sh

# 以时间戳作为版本号
# 格式为 20201007163924
version=`date +"%Y%m%d%H%M%S"`
group_name="fooofei/netshoot"
version_name="x86_64-${version}"
image_name="${group_name}:${version_name}"

pushd ${cur}/..
docker build . -t ${image_name}
popd

bash -x ${cur}/push_image.sh ${group_name} ${version_name}

docker images
