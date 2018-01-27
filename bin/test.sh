#!/bin/bash

ERR_FILE="/home/zglue/bin/errno.sh"

DESTFILE=$(mktemp -p /tmp .err_src_XXXX)
sed -n -e '2,/^## ===/p' "$ERR_FILE" > "$DESTFILE"
source "$DESTFILE"

rm "$DESTFILE"

setup_error_codes
list_err_map
help_$(basename ${ERR_FILE%.sh})



