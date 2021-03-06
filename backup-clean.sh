#!/bin/bash
set -o nounset
set -o errexit
set -o errtrace
set -o pipefail
# To debug, enable xtrace, and disable redirection of stderr to file (the exec 2>${ERROR_LOG} line)
# set -o xtrace

if [[ ${EUID} -ne 0 ]]; then
  echo "Needs root access"
  exit 1
fi

MSG=""
ERROR=0
ERROR_MSG=""
ERROR_LOG="/tmp/error_log.${$}.txt"
TYPE="Cleanup"

# Redirect all stderr to error logfile
exec 2>${ERROR_LOG}

# For PyDrive credentials
cd /root/.duplicity/
source /root/.duplicity/conf
source /usr/local/sbin/includes.sh

setup

for SRC_DIR in ${BACKDIRS}; do
  CLEAN_SRC_DIR="${SRC_DIR//\//-}"
  DEST_DIR="${REMOTE_DIR}/${CLEAN_SRC_DIR}"
  LOG_FILE="/var/log/backup/duplicity-cleanup-${CLEAN_SRC_DIR}.log"

  echo  "========================= Cleaning ${HOSTNAME}/${SRC_DIR} $(date) =========================" >> "${LOG_FILE}"
  duplicity cleanup --force ${COMMON_OPTS} ${DEST_DIR} >> "${LOG_FILE}"
  MSG="${MSG}\n- ${SRC_DIR}"
done
