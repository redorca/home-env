#!/bin/bash

[ "$TRACE" = "1" ] && set -x

DO_COMMIT=()
DRY_RUN=${DRY_RUN:-0}
DEBUG=${DEBUG:-0}
VAR_LIST="LOOP_SET_COUNT count"
#
# How many lines to output before issuing a page break.
# May be altered with the '-p <#>' argument.
#
page_size=10
# shellcheck disable=2034 # count appears unused.
count=$page_size
declare -A GIT_MODE_CODE

setup_mode_code()
{
        GIT_MODE_CODE["R"]="git mv"
        GIT_MODE_CODE["M"]="git add"
        GIT_MODE_CODE["A"]="git add"
        GIT_MODE_CODE["D"]="git rm"
        GIT_MODE_CODE["C"]="git add"
        GIT_MODE_CODE["?"]="echo Untracked: "
        GIT_MODE_CODE["U"]="git add"
}

Help()
{
        echo -e "$(basename "$0"):"
        Exec 'sed -n -e '\''/^# ARGS_Begin/,/^# ARGS_End/p'\' "$0" '| grep -v "^#" | grep ")"'
        echo -e ""
}

Exec()
{
        declare -a CMD=
        CMD=( "$@" )
        [ "$DRY_RUN"  = "1" ] && echo "${CMD[*]}"
        [ "$DRY_RUN" != "1" ] && eval "${CMD[@]}"

        return 0
}

debug()
{
        [ "$DEBUG" = "1" ] && return
        return 1
}

echo_dbg()
{
        debug || return
        echo -e "$*" >&2
}

dump_env()
{
        local Var=

        echo "Environment of $(basename "$0")"
        for Var in $VAR_LIST ; do
                echo -e "  $Var:\\t${!Var}"
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
        declare -a tmp=
        local Key=

        #
        # Strip off the first character '( "${tmp[0]#?}" )',
        # which represents whether the file is staged or
        # not, and use the second character to see the
        # state of any un staged files.
        #
        # shellcheck disable=2206 #Quote to prevent word splitting, or split
                                  # robustly with mapfile or read -a
        tmp=( $@ )
        Key="${tmp[0]#?}"
        echo_dbg "Raw Key: ${tmp[0]}  Key: $Key"

        #
        # This will run the command if $DEBUG != 1, else
        # it will print the command string through stderr.
        #
        Exec "${GIT_MODE_CODE[$Key]}" "${tmp[1]}"
}

page_break()
{
        local tmpe=
        local Count=
        local Page_Size=
        local Page_Marker=

        Count="${1}"; shift
        Page_Size="${1}"; shift
        Page_Marker="$1"; shift
        if [ "${!Count}" -eq 0 ] ; then
                echo -e "$Page_Marker"
                eval "${Count}"="${!Page_Size}"
                sleep 1
                return
        fi
        tmpe=${!Count}
        eval "${Count}"=$(( tmpe - 1 ))
}

var_sanity_check()
{
        local Var=

        for Var in "$@" ; do
                [ -z "${!Var}" ] && echo "$Var has no value" >&2 && return 1
        done

        return 0
}

wait_rm_tmpfile()
{
        local File=

        [ -z "$1" ] && return 1

        File="$1"
        while [ ! -f "$File" ] ; do
                sleep 1
        done
        rm "$File"

        return
}


get_files()
{
        echo "/home/zglue/bin/astyle-nuttx"
}

set_helper()
{
        [ -z "$1" ] && return 1

        cat > "$1" <<"EOF"
#!/bin/bash

exec 1>&-
exec 2>&-
exec 0<&-
exec setsid $@
EOF
        [ -f "$1" ] && chmod +x "$1"
}

PUSH="push"
# PUSH="review -D"

# ARGS_Begin
while [ $# -ne 0 ] ; do
        case $1 in
        -A) NEW_TIME_STAMP=$(date +"%a %b %d %T %Y %z")
            echo "NEW_TIME_STAMP:  ($NEW_TIME_STAMP)"
            DO_COMMIT=( "git" "commit" "--amend" "--date=${NEW_TIME_STAMP}" "--no-verify" )
            myname="$(git config --get user.name)"
            author=$(git log -1 --pretty=short | awk '/^Author:/ {print $2 " " $3}' )
            if [ "$myname" != "$author" ] ; then
                echo "Updating Author."
                DO_COMMIT=( "${DO_COMMIT[@]}" "--reset-author" )
                sleep 2
            fi
           ;;
        -a) NEW_TIME_STAMP=$(date +"%a %b %d %T %Y %z")
            echo "NEW_TIME_STAMP:  ($NEW_TIME_STAMP)"
            DO_COMMIT=( "git" "commit" "--amend" "--date=${NEW_TIME_STAMP}" )
            myname="$(git config --get user.name)"
            author=$(git log -1 --pretty=short | awk '/^Author:/ {print $2 " " $3}' )
            if [ "$myname" != "$author" ] ; then
                echo "Updating Author."
                DO_COMMIT=( "${DO_COMMIT[@]}" "--reset-author" )
                sleep 2
            fi
           ;;
        -c) DO_COMMIT=( "git" "commit" )
           ;;
        -d) DEBUG=1; echo "DEBUG = $DEBUG"
           ;;
        -e) dump_env; exit 0
           ;;
        -h) Help; exit 0
           ;;
        -n) DRY_RUN=1; echo "DRY_RUN = $DRY_RUN"
           ;;
        -P) page_size=$2; echo "page size: $page_size"
           ;;
        -p|--push) DO_COMMIT=( "eval" "git" "commit" "&&" "git" "$PUSH" )
           ;;
        -r) PUSH="review -D"
            DO_COMMIT=( "eval" "git" "commit" "&&" "git" "$PUSH" )
           ;;
        -u) UNTRACK=1
           ;;
        *) echo "Unknown argument: $1"; Help; exit 0
           ;;
        esac
        shift
done
# ARGS_End"


add_patch()
{
        [ ! -d .git ] && echo "No local .git/" >&2 && return 1

        local time_stamp=
        local PATCH_FILE=
        local branch=
        declare -A Info=
#
# Quoted this as per shellcheck.  Verify this still works!! XXX
#
        eval "Info=( $(git log -1 --format="[\"Hash\"]=\"%h\"       \
                                           [\"Author\"]=\"%an\"    \
                                           [\"Committer\"]=\"%cn\" \
                                           [\"Subject\"]=\"%f\"") )"
        branch="$(git branch | awk '{print $2}')"
        branch="$(git branch | awk '{print $2}' | tr -d [:space:])"
        time_stamp=$(date +"%Y-%a-%b-%e@%H.%M%P")
        # shellcheck disable=2116 # Useless echo? Instead of 'cmd $(echo foo)', just use 'cmd foo'.
        #                           In this case the $(echo ...) is extremely useful.  The echo
        #                           strips off all the white space preceding and following the
        #                           content that is needed.
        #
        # shellcheck disable=2086 # Double quote to prevent globbing and word splitting.
        #                           In fact globbing and splitting is what is necessary here
        #                           to ensure all of that extraneous white space is stripped.
        #
        PATCH_FILE=patches/patch.$(echo $branch | sed -e 's/\//_/g').${Info["Hash"]}.${time_stamp}

        [ ! -d patches ] && mkdir -p patches
        git diff > "$PATCH_FILE"
        git diff --cached >> "$PATCH_FILE"
}

if ! var_sanity_check page_size ; then
        echo "page_size has a bad value: ($page_size)" >&2
        exit 1
fi

FILTER="^[A-Z_][A-Z]"
setup_mode_code
if [ -n "$UNTRACK" ] && [ "$UNTRACK" -eq 1 ] ; then
        GIT_MODE_CODE["Q"]="git add"
        echo_dbg "Resetting the FILTER ..."
#       FILTER="^[A-Z_?][A-Z?]"
        SED_FILTER_UNTRACKED="-e 's/\?/Q/g'"
fi

(
        Dir="$(git rev-parse --show-toplevel)" || exit 1
        echo_dbg "cd to $Dir"
        cd "$Dir" || exit 1
        if [ "${DO_COMMIT[2]}" = "--amend" ] ; then
                add_patch
        fi
        # shellcheck disable=2162 # read without -r will mangle backslashes.
        git status --porcelain | sed -e 's/^ /_/' ${SED_FILTER_UNTRACKED} \
                | grep "$FILTER" \
                | awk '{print $1 "  " $NF}' \
                | while read line ; do
                        if ! RESULTS="$(stage_line "$line") $RESULTS" ; then
                                echo "Did not stage: [$line]"
                        fi
                        page_break count page_size "\\t======================================="
                done
        echo "== ${DO_COMMIT[@]}"
        "${DO_COMMIT[@]}"
        [  "${#DO_COMMIT[@]}" -eq 0 ] && git status
)

