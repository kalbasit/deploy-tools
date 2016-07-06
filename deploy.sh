#!/bin/bash
set -e

BASE_DIR="`cd $(dirname $0) && pwd`"
MSG_PREFIX="[deploy] >>>"

# announcement
echo -e "${MSG_PREFIX} starting $0"

# build the image
if [[ -z "${BUILD_IMAGE_BRANCH}" ]]; then
  echo "${MSG_PREFIX} BUILD_IMAGE_BRANCH must be set if you wish to build the docker image and deploy."
  exit 1
fi
if [[ "x${BUILD_IMAGE_BRANCH}" = "xALL" ]] || [[ "x${BUILD_IMAGE_BRANCH}" = "x${TRAVIS_BRANCH}" ]]; then
  "${BASE_DIR}/build-docker-image.sh"
else
  echo "${MSG_PREFIX} Not building the image because the branch ${TRAVIS_BRANCH} did not match ${BUILD_IMAGE_BRANCH}"
  exit 1
fi

# deploy to kubernetes
if [[ -z "${DEPLOY_KUBERNETES_BRANCH}" ]]; then
  echo "${MSG_PREFIX} DEPLOY_KUBERNETES_BRANCH is not set, skipping the deployment to kubernetes"
  exit 0
fi
if [[ "x${DEPLOY_KUBERNETES_BRANCH}" = "xALL" ]] || [[ "x${DEPLOY_KUBERNETES_BRANCH}" = "x${TRAVIS_BRANCH}" ]]; then
  "${BASE_DIR}/update-kube-manifest.sh"
  "${BASE_DIR}/kubectl-apply.sh"
else
  echo "${MSG_PREFIX} Not deploying to kubernetes because the branch ${TRAVIS_BRANCH} did not match ${DEPLOY_KUBERNETES_BRANCH}"
  exit 0
fi
