#!/bin/bash -evx

opam option depext=false
opam update -y
opam repo add archive git+https://github.com/ocaml/opam-repository-archive

make -C fmdeps/auto ast-prepare -sj${NJOBS}
make -C fmdeps/auto-docs ast-prepare -sj${NJOBS}
opam pin add -y -k rsync --recursive -n --with-version dev .

opam install -y $(opam pin | grep -E '/fmdeps/(auto|BRiCk|vscoq|coq-lsp)' |
  grep -E -v 'rocq-bluerock-cpp-(demo|stdlib)' |
  awk '{print $1}')
/tmp/files/opam-clean

find $(opam var prefix) \( -path '*bluerock*/*.v' -o -path '*bluerock*/*.ml' \) -print0 |
  xargs -0 truncate --size 0

sudo rm -rf /tmp/files
