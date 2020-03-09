#!/usr/bin/env bash
echo "$DOCKER_PASSWORD" | docker login -u fooofei --password-stdin
docker push fooofei/netshoot-x86_64:latest
