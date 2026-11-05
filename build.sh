#!/bin/bash

set -euax

IMAGE=${1:?Please provide the image name}
TAG=${2:?Please provide the tag}
WD=$(pwd)/${IMAGE}
DOCKERFILE=${3:-Dockerfile}
shift
shift
shift


docker build -t ${IMAGE}:${TAG} -f ${WD}/${DOCKERFILE} ${WD} $@