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
# Systemd
#   Systemd deployment is a special deployment that will exec docker pull on a
#   specified image and restart the systemd unit using the image. It's useful
#   for deployments using https://github.com/jwilder/nginx-proxy for example.
#
#   The required variables:
#     - SYSTEMD_SSH_HOST is the host where the systemd unit files is running
#     - SYSTEMD_SSH_USER is the user to use for SSH connection
#     - SYSTEMD_SSH_PORT is the port for the SSH connection, default to 22.
#     - SYSTEMD_SSH_IDENTITY_FILE is the identity file to use for the SSH
#       connection.
#     - SYSTEMD_DOCKER_IMAGE is the docker image to pull. Optional
#     - SYSTEMD_USE_SUDO if not empty sudo will be used.
#     - SYSTEMD_UNIT is the unit to restart
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
if [[ -n "${DEPLOY_KUBERNETES_BRANCH}" ]]; then
  if [[ "x${DEPLOY_KUBERNETES_BRANCH}" = "xALL" ]] || [[ "x${DEPLOY_KUBERNETES_BRANCH}" = "x${TRAVIS_BRANCH}" ]]; then
    "${BASE_DIR}/update-kube-manifest.sh"
    "${BASE_DIR}/kubectl-apply.sh"
  else
    echo "${MSG_PREFIX} Not deploying to kubernetes because the branch ${TRAVIS_BRANCH} did not match ${DEPLOY_KUBERNETES_BRANCH}"
  fi
else
  echo "${MSG_PREFIX} DEPLOY_KUBERNETES_BRANCH is not set, skipping the deployment to kubernetes"
fi

# restart systemd unit
if [[ -n "${DEPLOY_SYSTEMD_BRANCH}" ]]; then
  if [[ "x${DEPLOY_SYSTEMD_BRANCH}" = "xALL" ]] || [[ "x${DEPLOY_SYSTEMD_BRANCH}" = "x${TRAVIS_BRANCH}" ]]; then
    "${BASE_DIR}/deploy-systemd.sh"
  else
    echo "${MSG_PREFIX} Not deploying to systemd because the branch ${TRAVIS_BRANCH} did not match ${DEPLOY_SYSTEMD_BRANCH}"
  fi
else
  echo "${MSG_PREFIX} DEPLOY_SYSTEMD_BRANCH is not set, skipping the deployment to systemd"
fi
