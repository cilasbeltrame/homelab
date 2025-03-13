#!/usr/bin/env bash

set -e

APP_NAME=$1
LATEST_MINOR_TAG=$2

ssh docker-host

CURRENT_VERSION=$(docker ps | grep "$APP_NAME" | awk '{print $2}' | cut -d : -f2)

if [[ "$CURRENT_VERSION" == "$LATEST_MINOR_TAG" ]]; then
  echo "No new version to deploy"
  exit 0
else
  docker_deploy
fi

docker_deploy() {
  echo "Deploying new version: $LATEST_MINOR_TAG"
  docker stop "$APP_NAME" && docker rm "$APP_NAME"
  docker rmi docker.all-hands.dev/all-hands-ai/openhands:"$CURRENT_VERSION"
  docker run -d \
    -e SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:"$LATEST_MINOR_TAG"-nikolaik \
    -e LOG_ALL_EVENTS=true \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ~/.openhands-state:/.openhands-state \
    -p 3000:3000 \
    --add-host host.docker.internal:host-gateway \
    --name "$APP_NAME" \
    docker.all-hands.dev/all-hands-ai/openhands:"$LATEST_MINOR_TAG"
}
