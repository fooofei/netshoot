#!/usr/bin/env bash
cur=$(dirname "$(readlink -f $0)")
set -x
set -e


group_name="$1"
version_name="$2"
source_image_name="${group_name}:${version_name}"


push_cn_north_4() {
    local dest_image_name="swr.cn-north-4.myhuaweicloud.com/fooofei/netshoot:${version_name}"
    docker tag "${source_image_name}" "${dest_image_name}"
    docker login -u cn-north-4@B1Q1DM5XDUUGNAHACWCE -p 3e70145984642dfb2d9073bb00b6b79f4910a9e90d340a37ca3ce1c231626ef2 swr.cn-north-4.myhuaweicloud.com
    docker push ${dest_image_name}
}

push_ap_southeast_3() {
    local dest_image_name="swr.ap-southeast-3.myhuaweicloud.com/fooofei/netshoot:${version_name}"
    docker tag "${source_image_name}" "${dest_image_name}"
    docker login -u ap-southeast-3@B1Q1DM5XDUUGNAHACWCE -p 3e70145984642dfb2d9073bb00b6b79f4910a9e90d340a37ca3ce1c231626ef2 swr.ap-southeast-3.myhuaweicloud.com
    docker push ${dest_image_name}
}

push_ap_southeast_3
