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
curl -Lo $HOME/kubernetes.tar.gz https://github.com/kubernetes/kubernetes/releases/download/v${KUBE_VERSION}/kubernetes.tar.gz
tar -C $HOME -xf $HOME/kubernetes.tar.gz
rm -f $HOME/kubernetes.tar.gz
mv $HOME/kubernetes "${KUBE_INSTALL_PATH}"
