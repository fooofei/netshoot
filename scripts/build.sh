#!/usr/bin/env bash
cur=$(dirname "$(readlink -f $0)")
set -x

sh -x ${cur}/build_ping.sh
sh -x  ${cur}/build_rustscan.sh

# 以时间戳作为版本号
# 格式为 20201007163924
version=`date +"%Y%m%d%H%M%S"`
image_name=swr.cn-north-4.myhuaweicloud.com/fooofei/netshoot:x86_64-${version}

docker build . -t ${image_name}
docker login -u cn-north-4@UG4AO1SLW2CV8H64T8TB -p 198de0d5a1bcfc8799f168144961137440c23e2e5abc80e48117cee9401e5760 swr.cn-north-4.myhuaweicloud.com
docker push ${image_name}

docker images
