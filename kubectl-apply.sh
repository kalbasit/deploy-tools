#!/bin/bash
set -e

MSG_PREFIX="[kubectl-apply.sh] >>>"

# announcement
echo -e "${MSG_PREFIX} starting $0"

# sanity check
if [[ -z "${KUBECONFIG_PATH}" ]]; then
  echo "${MSG_PREFIX} KUBECONFIG_PATH is empty, must be set to the path of kubeconfig."
  exit 1
fi
if [[ ! -d "${KUBECONFIG_PATH}" ]]; then
  echo "${MSG_PREFIX} ${KUBECONFIG_PATH} does not exist."
  exit 1
fi
if [[ -z "${KUBE_MANIFEST_REPO_PATH}" ]]; then
  echo "${MSG_PREFIX} KUBE_MANIFEST_REPO_PATH is empty, must be set to the path of the kube-manifests repository path"
  exit 1
fi
if [[ ! -d "${KUBE_MANIFEST_REPO_PATH}" ]]; then
  echo "${MSG_PREFIX} ${KUBE_MANIFEST_REPO_PATH} does not exist, please clone it before calling this script"
  exit 1
fi
if [[ -z "${KUBE_MANIFEST_FILES}" ]]; then
  echo "${MSG_PREFIX} KUBE_MANIFEST_FILES must be present."
  exit 1
fi

cd "${KUBE_MANIFEST_REPO_PATH}"
for file in $(echo "${KUBE_MANIFEST_FILES}" | tr ":" "\n"); do
  if [[ ! -r ${file} ]]; then
    echo "${MSG_PREFIX} unable to write to ${file}"
    exit 1
  fi
  echo "${MSG_PREFIX} running 'kubectl apply -f ${file}'"
  kubectl --kubeconfig="${KUBECONFIG_PATH}" apply -f "${file}"
done
