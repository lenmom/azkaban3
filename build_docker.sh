#!/usr/bin/env bash

RELEASE_VERSION=$(git describe --tags $(git rev-list --tags --max-count=1))
echo RELEASE_VERSION=${RELEASE_VERSION}

echo "# build azkaban-web-server image..."
PKG_FILE=$(ls build/distributions | grep azkaban-web-server)
PKG_NAME=${PKG_FILE%.tar.gz}
echo "# PKG_FILE=${PKG_FILE}"
echo "# PKG_NAME=${PKG_NAME}"
cp build/distributions/${PKG_FILE} docker/azkaban-webserver/dist/
docker build --rm=false --build-arg PKG_FILE=${PKG_FILE} --build-arg PKG_NAME=${PKG_NAME} -t poporisil/azkaban3-webserver:${RELEASE_VERSION} docker/azkaban-webserver

echo "# build azkaban-exec-server image..."
PKG_FILE=$(ls build/distributions | grep azkaban-exec-server)
PKG_NAME=${PKG_FILE%.tar.gz}
echo "# PKG_FILE=${PKG_FILE}"
echo "# PKG_NAME=${PKG_NAME}"
cp build/distributions/${PKG_FILE} docker/azkaban-execserver/dist/
docker build --rm=false --build-arg PKG_FILE=${PKG_FILE} --build-arg PKG_NAME=${PKG_NAME} -t poporisil/azkaban3-execserver:${RELEASE_VERSION} docker/azkaban-execserver
