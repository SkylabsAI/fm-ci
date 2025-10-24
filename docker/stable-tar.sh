#!/bin/bash

DIR_NAME="$1"
OUT_FILE="${DIR_NAME}.tar"

TAR=$(which gtar || which tar)
$TAR --sort=name --owner=root:0 --group=root:0 --mtime='UTC 2000-01-01' \
  --exclude-vcs -cf "${OUT_FILE}" "${DIR_NAME}"
