#!/bin/bash
set -e

MSG_PREFIX="[deploy-systemd.sh] >>>"
SYSTEMD_SSH_PORT="${SYSTEMD_SSH_PORT:-22}"

# announcement
echo -e "${MSG_PREFIX} starting $0"

# sanity check
if [[ -z "${SYSTEMD_SSH_HOST}" ]]; then
  echo "${MSG_PREFIX} SYSTEMD_SSH_HOST is empty, must be set to the host of the systemd deployment."
  exit 1
fi
if [[ -z "${SYSTEMD_SSH_USER}" ]]; then
  echo "${MSG_PREFIX} SYSTEMD_SSH_USER is empty, must be set to the user to use for the SSH connection."
  exit 1
fi
if [[ -z "${SYSTEMD_UNIT}" ]]; then
  echo "${MSG_PREFIX} SYSTEMD_UNIT is empty."
  exit 1
fi
if [[ -z "${SYSTEMD_SSH_IDENTITY_FILE}" ]]; then
  echo "${MSG_PREFIX} SYSTEMD_SSH_IDENTITY_FILE is empty, must be set to the path of the identity file,"
  exit 1
fi
if [[ ! -f "${SYSTEMD_SSH_IDENTITY_FILE}" ]]; then
  echo "${MSG_PREFIX} ${SYSTEMD_SSH_IDENTITY_FILE} does not exist."
  exit 1
fi

# Make sure the identity file is usable
chmod 400 "${SYSTEMD_SSH_IDENTITY_FILE}"

# Build up the SSH flags
SSH_FLAGS="-oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -p ${SYSTEMD_SSH_PORT} -l ${SYSTEMD_SSH_USER} -i ${SYSTEMD_SSH_IDENTITY_FILE}"

# Pull the docker image
if [[ -n "${SYSTEMD_DOCKER_IMAGE}" ]]; then
  ssh $SSH_FLAGS "${SYSTEMD_SSH_HOST}" "docker pull ${SYSTEMD_DOCKER_IMAGE}"
fi

# Restart the unit file
if [[ -n "${SYSTEMD_USE_SUDO}" ]]; then
  COMMAND="sudo systemctl daemon-reload && sudo systemctl restart ${SYSTEMD_UNIT}"
else
  COMMAND="systemctl daemon-reload && systemctl restart ${SYSTEMD_UNIT}"
fi
echo -e "${MSG_PREFIX} running ${COMMAND} on ${SYSTEMD_SSH_HOST}"
ssh $SSH_FLAGS "${SYSTEMD_SSH_HOST}" "${COMMAND}"
