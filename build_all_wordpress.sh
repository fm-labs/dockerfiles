#!/bin/bash

set -euax

IMAGE=wordpress
WD=$(pwd)/${IMAGE}
DOCKERFILE=${WD}/Dockerfile
PHP_VERSIONS=(8.4 8.3 8.2 8.1 7.4)
for PHP_VERSION in "${PHP_VERSIONS[@]}"; do
  ./build.sh $IMAGE ${PHP_VERSION}-apache Dockerfile-apache --build-arg PHP_VERSION=${PHP_VERSION}
done