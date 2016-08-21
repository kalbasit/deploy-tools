#!/bin/bash
set -e

# deploy.sh allows you to deploy to multiple providers
#
# Docker image
#   To build a docker image, you must set the following variables:
#     - BUILD_IMAGE_BRANCH must be set to a branch name or `ALL`. `ALL`
#       is a special branch name that matches all branches.
#     - DOCKER_USER must be set if pushing to hub.docker.com
#     - DOCKER_PASS must be set if pushing to hub.docker.com
#
# Kubernetes
#   To deploy to Kubernetes you must set the following variables:
#     - DEPLOY_KUBERNETES_BRANCH must be set to a branch name or `ALL`. `ALL`
#       is a special branch name that matches all branches.
#     - KUBE_MANIFEST_REPO_PATH is the local path where to find the repository
#       containing the kube manifest. It must be a git repository and
#       credentials must allow the deployer to push to origin/master.
#     - PROJECT_NAME is the name of the project, it will be used as prefix to
#       the commit message in the manifests repository.
#     - KUBE_MANIFEST_FILES is a list of manifest paths relative to
#       KUBE_MANIFEST_REPO_PATH. The list must be separated with a column.
#     - KUBECONFIG_PATH is the path to kubeconfig to be used by kubectl.
#

BASE_DIR="$(cd "$(dirname "${0}")" && pwd)"
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
