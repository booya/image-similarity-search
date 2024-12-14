#!/usr/bin/env bash

set -e

BASE="image-similarity-search"
# TAG="latest"
TAG=v$(date +%s)
IMAGE="${BASE}:${TAG}"

# [[ ${USER} -eq "root" ]] || ( echo "You must run it as root, sorry!" ; exit 1 )

docker build -t ${IMAGE} --target=final .
# docker save ${IMAGE} | k3s ctr images import -
