#!/bin/sh
set -e

BASE_CALL="/usr/bin/gotty -a ${GOTTY_BIND} -p ${GOTTY_PORT} ${GOTTY_OPTS}"

if [ -e /var/run/docker.sock ]; then
  if [ -z "${DGID}" ]; then
    (>&2 echo "Missing DGID env var"; exit 1)
  fi
  addgroup -g $DGID -S runtime
  RUNGROUP="runtime"
else
  RUNGROUP="gotty"
fi

usermod -G $RUNGROUP gotty
su-exec gotty:$RUNGROUP ${BASE_CALL} $@
