#!/bin/bash

VAR_LIST="LOOP_SET_COUNT count"
LOOP_SET_COUNT=10
count=$LOOP_SET_COUNT


help()
{
        echo -e " $(basename $0)"
        echo -e "\t-d:\tSet runstate to DEBUG"
        echo -e "\t-n:\tEcho the commands instead of doing them"
        echo -e "\t-h:\tPrint this message"
        echo -e ""
}

Exec()
{
        local CMD=

        CMD="$@"
        echo "$CMD"
        [ -z "$DRY_RUN" ] && $CMD

        return 0
}

dump_env()
{
        echo "Environment of $(basename $0)"
        for var in $VAR_LIST ; do
                echo -e "  $var:\t${!var}"
        done
        echo ""
}

#
# Convert the contents in the args into git action. The
# first argument may be a flag to indicate whether the
# function should validate the initial directory mentioned
# in the path part of the $Line's contents.
# 
translate_line()
{
        local Flag=$1; shift
        local Line="$@"
        tmp=( $(echo $Line | awk '{print $1 " " $2}') )
        if [ "$Flag" == "Dir" ] ; then
                base=${tmp[1]}
                part=${base%%/*}
                if [ ! -d "$part" ] ; then
                        echo ":: $part"
                        return 1
                fi
        fi
        if [ "${tmp[0]}" == "modified:" -o "${tmp[0]}" == "new file:" ] ; then
                Exec git add ${tmp[1]}
        elif [ "${tmp[0]}" == "deleted:" ] ; then
                Exec git rm ${tmp[1]}
        else
                continue
        fi
}

while [ $# -ne 0 ] ; do
        case $1 in
        -n) DRY_RUN=1; echo "DRY_RUN = $DRY_RUN";;
        -d) DEBUG=1; echo "DEBUG = $DEBUG";;
        -h) help; exit 0;;
        -e) dump_env; exit 0;;
        *) echo "Unknown argument: $1"; help; exit 0;;
        esac
        shift
done

# cat /tmp/status.out | while read line ; do
git status | sed -e '/^Untracked/,/^nothing/d' |
    while read line ; do
        if ! translate_line Dir $line ; then
                echo "Did not translate [$line]"
                continue
        fi
        if [ "$count" -eq 0 ] ; then
                echo ""
                count=$LOOP_SET_COUNT
                sleep 1
                continue
        fi
        count=$(( count - 1 ))
    done
# -e '/^Untracked/,/^nothing/s/^[ 	]\([^     ]*\.[CH]\)/\tnew file:\t\1/p' >/tmp/ffaa ; exit 0
