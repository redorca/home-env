#!/bin/bash

TMPDIR=/tmp
TARFILE=$(mktemp -p "$TMPDIR" .config_xXX.tgz)

sed -n -e '/^## ::/,$/p' "$0" > $TARFILE
TARGETS=( "$(tar -C "$TMPDIR" -zxvf $TARFILE)" )

echo_dbg "Number of targets: [${#TARGETS[@]}]"
exit
## :: End of ascii shell code.
