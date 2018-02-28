#!/bin/bash

DEBUG=1
[ "$TRACE" = "1" ] && set -x

echo_dbg()
{
        [ "$DEBUG" != "1" ] && return

        echo -e "$@" >&2
}

TMPDIR=/tmp
TARFILE=$(mktemp -p "$TMPDIR" .config_XXX.tgz)
[ ! -e $TARFILE ] && echo_dbg "Unable to create a tar file name." && exit 1

sed -n -e '1,/^## ::/d' "$0" > $TARFILE
# TARGETS=( "$(tar -C "$TMPDIR" -zxvf $TARFILE)" )
# [ -f "$TARFILE" ] && echo_dbg rm "$TARFILE"

echo_dbg "Number of targets: [${#TARGETS[@]}]"
exit
## :: End of ascii shell code.
