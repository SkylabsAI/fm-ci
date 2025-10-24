#!/bin/bash -evx

ROCQ_LOG_PREFIX="$1"
OPAM_PACKAGES="$2"

opam option depext=false
opam update -y

opam pin add -y -k rsync --recursive -n --with-version dev .

opam install -y ${OPAM_PACKAGES}
/tmp/files/opam-clean

find $(opam var prefix) \( -path "*${ROCQ_LOG_PREFIX}*/*.v" -o -path "*${ROCQ_LOG_PREFIX}*/*.ml" \) -print0 |
  xargs -0 truncate --size 0

sudo rm -rf /tmp/files
