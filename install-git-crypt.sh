#!/bin/bash
set -e

MSG_PREFIX="[install-git-crypt] >>>"

# sanity check
if [[ -z "${GIT_CRYPT_INSTALL_PATH}" ]]; then
  echo "${MSG_PREFIX} GIT_CRYPT_INSTALL_PATH is empty. Must be set to the path where you wish to install git-crypt"
  exit 1
fi

# announcement.
echo -e "${MSG_PREFIX} starting $0"

# install git-crypt
rm -rf "${GIT_CRYPT_INSTALL_PATH}"
git clone https://github.com/AGWA/git-crypt.git "${GIT_CRYPT_INSTALL_PATH}"
cd "${GIT_CRYPT_INSTALL_PATH}"
make
