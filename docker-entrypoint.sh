#!/bin/sh
set -e

BASE_CALL="/usr/local/bin/tty2web ${TTY2WEB_OPTS}"

if [ -e /var/run/docker.sock ]; then
  if [ -z "${DGID}" ]; then
    (>&2 echo "Missing DGID env var"; exit 1)
  fi
  set +e
  addgroup -g $DGID -S runtime
  set -e
  RUNGROUP="$DGID"
fi

usermod -G $RUNGROUP $RUNUSER
su-exec $RUNUSER:$RUNGROUP ${BASE_CALL} $@

