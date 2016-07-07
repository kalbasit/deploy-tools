#!/bin/bash
set -e

MSG_PREFIX="[install-kubectl] >>>"

# sanity check
if [[ -z "${KUBE_VERSION}" ]]; then
  echo "${MSG_PREFIX} KUBE_VERSION is empty, must be set to the desired kubernetes version. Ex: 1.2.5"
  exit 1
fi
if [[ -z "${KUBE_INSTALL_PATH}" ]]; then
  echo "${MSG_PREFIX} KUBE_INSTALL_PATH is empty, must be set to the desired install path"
  exit 1
fi

# announcement.
echo -e "${MSG_PREFIX} starting $0"

# install kubectl
rm -rf "${KUBE_INSTALL_PATH}"
mkdir -p "${KUBE_INSTALL_PATH}/platforms"
curl -Ls $HOME/kubernetes.tar.gz https://github.com/kubernetes/kubernetes/releases/download/v${KUBE_VERSION}/kubernetes.tar.gz | tar -C $HOME -xz
mv $HOME/kubernetes/platforms/linux "${KUBE_INSTALL_PATH}"/platforms/linux

# cleanup
rm -rf $HOME/kubernetes
