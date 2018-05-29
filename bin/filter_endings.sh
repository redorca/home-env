#!/bin/bash

declare -A IGNORE_ENDS
IGNORE_ENDS[".txt"]=1
IGNORE_ENDS[".grep"]=1
IGNORE_ENDS[".unk"]=1
IGNORE_ENDS[".src"]=1
IGNORE_ENDS[".a"]=1

IGNORING_ENDS=".hex .txt .grep .unk .src .a"
IGNORE_ENDS=( $(echo $IGNORING_ENDS | sed -e 's/\./[/g' ) )
echo "IGNORE # ${#IGNORE_ENDS[@]}"

filter_out_endings()
{
        local EFF=
        local EGG=

        eval $(declare -p $1 | eval sed -e 's/$1/EFF/')
        eval $(declare -p $2 | eval sed -e 's/$2/EGG/')

        for ifi in "${EGG[@]}" ; do
                xx=$(echo $ifi | sed -e 's/^.*\(\.[^.]*\)/\1/')
                [ "${xx:0:1}" = "." ] && [ -z "${EFF[$xx]}" ] && echo "$ifi" && continue
                [ "${xx:0:1}" != "." ] && echo "$ifi" && continue
                echo "Ignoring : $ifi" >&2
        done
}

FOO=( "$@" )
echo_dbg "Initial File Count: ${#FOO[@]}"
SRCS=( $(filter_out_endings IGNORE_ENDS FOO) )
echo_dbg "Filtered File Count: ${#SRCS[@]}"

