#!/bin/bash

#
# Make sure this is a file:
#
if [ ! -f "$1" ] ; then
        exit 1
fi

#
# Abort if the execute bit is not set.
#
if ! stat -c %A "$1" | grep x >/dev/null ; then
        exit 2
fi

strip_x()
{
        if ! file $1 2>&1 | grep -i script >/dev/null ; then
                echo "chmod -x $1"
                chmod -x $1
                return 0
        fi

        return 1
}

if ! file $1 2>&1 | grep text >/dev/null ; then
        exit 3
fi
case "${1##*.}" in
        pl|bat|py|sh);;
        *) strip_x $1;;
esac

