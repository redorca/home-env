#!/bin/bash -x


KEY0="^### COLORS Begin"
KEY1="^### COLORS End"
SCRIPT=~/bin/zmake
FOO=$(cat ~/bin/colors | sed -n -e '/^[^#].*[A-Z]=/p' | sed \
        -e 's/\\/\\\\/g' \
        -e 's/"/\\"/g' \
)

#       -e 's/\[/\\[/g' \
#       -e 's/;/\\;/g' \
#       -e 's/$/\;/g' \
#FOO='a b c;
#d e f;'
# echo "::FOO ($FOO)"

#  \
# -e 's/\\/\\\\/g' \
# -e 's/$/xxx;/g' \
# )"

eval sed -e \'/$KEY0/a$FOO\' $SCRIPT > /tmp/foo

