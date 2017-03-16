#!/usr/bin/env bash

RELEASE_VERSION=$(git describe --tags $(git rev-list --tags --max-count=1))
echo RELEASE_VERSION=${RELEASE_VERSION}

echo "# build azkaban-web-server image"
cp build/distributions/azkaban-web-server-*.tar.gz docker/azkaban-webserver/dist/azkaban-web-server-${RELEASE_VERSION}.tar.gz
docker build --rm=false --build-arg AZK_VERSION=${RELEASE_VERSION} -t poporisil/azkaban3-webserver:${RELEASE_VERSION} docker/azkaban-webserver
echo "# build azkaban-exec-server image"
cp build/distributions/azkaban-exec-server-*.tar.gz docker/azkaban-execserver/dist/azkaban-exec-server-${RELEASE_VERSION}.tar.g
docker build --rm=false --build-arg AZK_VERSION=${RELEASE_VERSION} -t poporisil/azkaban3-execserver:${RELEASE_VERSION} docker/azkaban-execserver
