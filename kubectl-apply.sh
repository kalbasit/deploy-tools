#!/bin/bash
set -e

MSG_PREFIX="[kubectl-apply.sh] >>>"

# announcement
echo -e "${MSG_PREFIX} starting $0"

# sanity check
if [[ -z "${AWS_TERRAFORM_REPO_PATH}" ]]; then
  echo "${MSG_PREFIX} ${AWS_TERRAFORM_REPO_PATH} is empty, must be set to the path of the aws-terraform repository path"
  exit 1
fi
if [[ ! -d "${AWS_TERRAFORM_REPO_PATH}" ]]; then
  echo "${MSG_PREFIX} ${AWS_TERRAFORM_REPO_PATH} does not exist, please clone it before calling this script"
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
if [[ ${#KUBE_MANIFEST_FILES[@]} -eq 0 ]]; then
  echo "${MSG_PREFIX} KUBE_MANIFEST_FILES must specify at least one file"
  exit 1
fi

cd "${KUBE_MANIFEST_REPO_PATH}"
for file in ${KUBE_MANIFEST_FILES[@]}; do
  if [[ ! -r ${file} ]]; then
    echo "${MSG_PREFIX} unable to write to ${file}"
    exit 1
  fi
  echo "${MSG_PREFIX} running 'kubectl apply -f ${file}'"
  kubectl --kubeconfig="${AWS_TERRAFORM_REPO_PATH}/${KUBE_CONFIG}" apply -f "${file}"
done
