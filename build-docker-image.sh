#!/bin/bash
set -e

MSG_PREFIX="[build-docker-image] >>>"
COMMIT=${TRAVIS_COMMIT::8}
ROCKER_VERSION=1.3.0

# announcement.
echo -e "${MSG_PREFIX} starting $0"

# download rocker.
curl -L "https://github.com/grammarly/rocker/releases/download/${ROCKER_VERSION}/rocker_linux_amd64.tar.gz" \
  | tar xfz - -C "${HOME}"

# pass the auth if we are pushing to docker hub.
EXTRA=""
if [ -n "${DOCKER_USER}" ] && [ -n "${DOCKER_PASS}" ]; then
  EXTRA="--auth ${DOCKER_USER}:${DOCKER_PASS}"
fi

# build the image
"${HOME}/rocker" build --var "BRANCH=${TRAVIS_BRANCH}" --var "TAG=${TRAVIS_TAG}" \
  --var "COMMIT=${COMMIT}" --var "TRAVIS_BUILD_NUMBER=${TRAVIS_BUILD_NUMBER}" --push $EXTRA
