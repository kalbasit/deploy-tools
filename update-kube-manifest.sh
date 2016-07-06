#!/bin/bash
set -e

COMMIT=${TRAVIS_COMMIT::8}
MSG_PREFIX="[update-kube-manifest] >>>"

# announcement
echo -e "${MSG_PREFIX} starting $0"

# sanity check
if [[ -z "${KUBE_MANIFEST_REPO_PATH}" ]]; then
  echo "${MSG_PREFIX} KUBE_MANIFEST_REPO_PATH is empty, must be set to the path of the kube-manifests repository path"
  exit 1
fi
if [[ ! -d "${KUBE_MANIFEST_REPO_PATH}" ]]; then
  echo "${MSG_PREFIX} ${KUBE_MANIFEST_REPO_PATH} does not exist, please clone it before calling this script"
  exit 1
fi
if [[ -z "${PROJECT_NAME}" ]]; then
  echo "${MSG_PREFIX} PROJECT_NAME is empty, must be set."
  exit 1
fi
if [[ -z "${KUBE_MANIFEST_FILES}" ]]; then
  echo "${MSG_PREFIX} KUBE_MANIFEST_FILES must be present."
  exit 1
fi

cd "${KUBE_MANIFEST_REPO_PATH}"
for file in `echo $KUBE_MANIFEST_FILES | tr ":" "\n"`; do
  if [[ ! -w ${file} ]]; then
    echo "${MSG_PREFIX} unable to write to ${file}"
    exit 1
  fi
  echo -e "${MSG_PREFIX} updating the image in ${file} to ${COMMIT}"
  sed -e "s#image: \(.*\):[^:]*\$#image: \1:${COMMIT}#g" -i $file
done
echo -e "${MSG_PREFIX} commit all changes"
git config user.name "Publica CI"
git config user.email "infra@publica-project.com"
git commit -am "${PROJECT_NAME}: deploy ${COMMIT} done by Travis build #${TRAVIS_BUILD_NUMBER}"
echo -e "${MSG_PREFIX} pushing all changes to master"
git push origin master
