#!/usr/bin/env bash

RELEASE_VERSION=$(git describe --tags $(git rev-list --tags --max-count=1))
echo RELEASE_VERSION=${RELEASE_VERSION}

echo "# push azkaban-web-server image..."
docker push poporisil/azkaban3-webserver:${RELEASE_VERSION}
docker tag poporisil/azkaban3-webserver:${RELEASE_VERSION} poporisil/azkaban3-webserver:latest
docker push poporisil/azkaban3-webserver:latest

echo "# push azkaban-exec-server image..."
docker push poporisil/azkaban3-execserver:${RELEASE_VERSION}
docker tag poporisil/azkaban3-execserver:${RELEASE_VERSION} poporisil/azkaban3-execserver:latest
docker push poporisil/azkaban3-execserver:latest
