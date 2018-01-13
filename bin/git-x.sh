#!/bin/bash -k

DO_COMMIT=
DO_AMMEND=
DRY_RUN=0
DEBUG=0
VAR_LIST="LOOP_SET_COUNT count"
page_size=10
count=$page_size
declare -A GIT_MODE_CODE

setup_mode_code()
{
        GIT_MODE_CODE["R"]="git mv"
        GIT_MODE_CODE["M"]="git add"
        GIT_MODE_CODE["A"]="git add"
        GIT_MODE_CODE["D"]="git rm"
        GIT_MODE_CODE["C"]="git add"
        GIT_MODE_CODE["U"]="$EDIT_WITH"
}

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
        local Key=

        #
        # Strip off the first character '( "${tmp[0]#?}" )',
        # which represents whether the file is staged or
        # not, and use the second character to see the
        # state of any un staged files.
        #
        tmp=( $1 )
        Key="${tmp[0]#?}"
        echo_dbg "Raw Key: ${tmp[0]}  Key: $Key"

        #
        # This will run the command if $DEBUG != 1, else
        # it will print the command string through stderr.
        #
        Exec ${GIT_MODE_CODE[$Key]} "${tmp[1]}"
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

wait_rm_tmpfile()
{
        local File=

        [ -z "$1" ] && return 1

        File="$1"
        while [ ! -f "$File" ] ; do
                sleep 1
        done
        rm $File
return
}


get_files()
{
        echo "/home/zglue/bin/astyle-nuttx"
}

set_helper()
{
        [ -z "$1" ] && return 1

        cat > $1 <<"EOF"
#!/bin/bash

exec 1>&-
exec 2>&-
exec 0<&-
exec setsid $@
EOF
        [ -f "$1" ] && chmod +x "$1"
}

TMPFILE=$(mktemp -p /tmp .helper-XXXX)

# ARGS_Begin
while [ $# -ne 0 ] ; do
        case $1 in
        -a) DO_AMMEND="--amend"
            DO_COMMIT="git commit";;
        -c) DO_COMMIT="git commit";;
        -d) DEBUG=1; echo "DEBUG = $DEBUG";;
        -e) dump_env; exit 0;;
        -h) Help; exit 0;;
        -n) DRY_RUN=1; echo "DRY_RUN = $DRY_RUN";;
        -p) page_size=$2; echo "page size: $page_size";;
        -u) UNTRACKED=1;;
        -v) EDIT_WITH="$TMPFILE nvim-qt";
            set_helper $TMPFILE
            echo_dbg ${GIT_MODE_CODE["U"]} $(get_files)
            EDIT_WITH="${GIT_MODE_CODE["U"]} $(get_files)&"
           ;;
        *) echo "Unknown argument: $1"; Help; exit 0;;
        esac
        shift
done
# ARGS_End"

if ! var_sanity_check page_size ; then
        echo "page_size has a bad value: ($page_size)" >&2
        exit 1
fi

setup_mode_code

(
Dir="$(git rev-parse --show-toplevel)" || exit 1
echo_dbg "cd to $Dir"
cd "$Dir" || exit 1
git status --porcelain=v1 \
        | sed -e 's/^ /_/' \
        | grep "^[A-Z_][A-Z]" \
        | awk '{print $1 "  " $NF}' \
        | while read line ; do
                if ! RESULTS="$(stage_line "$line") $RESULTS" ; then
                        echo "Did not stage: [$line]"
                fi
                page_break count page_size "\t=================="
        done

        $DO_COMMIT $DO_AMMEND
)
echo_dbg "Back @ $(pwd)"

