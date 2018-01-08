#!/bin/bash

DO_COMMIT="no"
DRY_RUN=0
DEBUG=0
VAR_LIST="LOOP_SET_COUNT count"
page_size=10
count=$page_size
declare -A GIT_MODE_CODE
GIT_MODE_CODE["R"]="mv"
GIT_MODE_CODE["M"]="add"
GIT_MODE_CODE["A"]="add"
GIT_MODE_CODE["D"]="rm"
GIT_MODE_CODE["C"]="add"
GIT_MODE_CODE["U"]="jump"

Help()
{
        echo -e "$(basename $0):"
        Exec "sed -n -e '/^# ARGS_Begin/,/^# ARGS_End/p' "$0" | grep ')'"
        echo -e ""
}

Exec()
{
        declare -a CMD=

        CMD=( "$@" )
        [ "$DRY_RUN"  = "1" ] && echo "${CMD[*]}"
        [ "$DRY_RUN" != "1" ] && eval "${CMD[*]}"

        return 0
}

echo_dbg()
{
        [ "$DEBUG" != "1" ] && return
        echo -e "$*" >&2
}

dump_env()
{
        local Var=

        echo "Environment of $(basename $0)"
        for Var in $VAR_LIST ; do
                echo -e "  $Var:\t${!Var}"
        done
        echo ""
}

#
# Convert the contents in the args into git action. The
# first argument may be a flag to indicate whether the
# function should validate the initial directory mentioned
# in the path part of the $Line's contents.
# 
stage_line()
{
        local tmp=

        tmp=( $1 )
        Key="${tmp[0]#?}"
        echo_dbg "Raw Key: ${tmp[0]}  Key: $Key"
        Exec git ${GIT_MODE_CODE[$Key]} "${tmp[1]}"
}

page_break()
{
        local tmp=
        local Count=
        local Page_Size=
        local Page_Marker=

        Count="$1"; shift
        Page_Size="$1"; shift
        Page_Marker="$1"; shift
        if [ "${!Count}" -eq 0 ] ; then
                echo -e "$Page_Marker"
                eval ${Count}=$page_size
                sleep 1
                return
        fi
        tmp=${!Count}
        eval "${Count}"=$(( tmp - 1 ))
}

var_sanity_check()
{
        local Var=

        for Var in "$@" ; do
                [ -z "${!Var}" ] && echo "$Var has no value" >&2 && return 1
        done

        return 0
}

# ARGS_Begin"
while [ $# -ne 0 ] ; do
        case $1 in
        -c) DO_COMMIT="yes";;
        -d) DEBUG=1; echo "DEBUG = $DEBUG";;
        -e) dump_env; exit 0;;
        -h) Help; exit 0;;
        -n) DRY_RUN=1; echo "DRY_RUN = $DRY_RUN";;
        -p) page_size=$2; echo "page size: $page_size";;
        *) echo "Unknown argument: $1"; Help; exit 0;;
        esac
        shift
done
# ARGS_End"

if ! var_sanity_check page_size ; then
        echo "page_size has a bad value: ($page_size)" >&2
        exit 1
fi

# cat /tmp/status.out | while read line ; do
# git status | sed -e '/^Untracked/,/^nothing/d' |
# git status | sed -e '/^Untracked/,$d' -e '1,/^Changes.*not.*staged/d' | \
# git status --porcelain=v1 | grep -v "^..[A-Z]\." | awk '{print $2 "  " $NF}' |
echo ""
(
Dir="$(git rev-parse --show-toplevel)" || exit 1
echo_dbg "cd to $Dir"
cd "$Dir" || exit 1
git status --porcelain=v1 \
        | sed -e 's/^ /_/' \
        | grep "^[A-Z_][A-Z]" \
        | awk '{print $1 "  " $NF}' \
        | while read line ; do
                if ! stage_line "$line" ; then
                        echo "Did not stage: [$line]"
                fi
                page_break count page_size "\t=================="
        done

        if [ "${DO_COMMIT,,}" = "yes" ] ; then
                git commit
        fi
)
echo_dbg "Back @ $(pwd)"

