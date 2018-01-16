#!/bin/bash

#
# This script will run make from the configs/nrf52832_dk directory against every
# example directory contiaining the file defconfig.
#
# Standard practice is to peform a distclean, <example app>, > out.<example>, and to cycle
# through each of the possible examples.
#

BOARD=nrf52832_dk
ARG_LIST="BOARD TARGET_DIRS NO_ERRORS Q V VERBOSE RELOCATE"
RED='\033[1;31m'
RESET='\033[0;39;49m'


find_repo_root()
{
        if ! git rev-parse >/dev/null 2>&1 ; then
                echo "Not running within a git repo.  Please relocate." >&2
                exit 1
        fi
        git rev-parse --show-toplevel
}

#
# Setup targets that are not actual apps but
# are still directives to make.
#
declare -A pseudo_targets
pseudo_targets["cscope"]=1
pseudo_targets["help"]=1
pseudo_targets["config"]=1
pseudo_targets["clean"]=1
pseudo_targets["distclean"]=1
pseudo_targets["clean_scope"]=1
pseudo_targets["clean_out"]=1

RELOCATE="$(find_repo_root)/configs/$BOARD"
[ ! -d "$RELOCATE" ] && echo "Can't find ($RELOCATE)" >&2 && exit 1

declare -A make_targets
fa=( $(cd $RELOCATE && make list_apps) )
for i in "${fa[@]}" ; do
        make_targets["$i"]=1
done

#
# Trap all exits.
#
on_exit()
{
        RV=$?
        [ $RV -ne 0 ] && echo_e "${RED}=============== Error exit: ${RESET}"
        exit $RV
}

#
# Wrap echo with echo_e() and use /bin/echo instead.  This allows invoking
# this script using sh as in "sh $(basename $0)"
#
echo_e()
{
        local Bin=

        Bin="/bin/echo -e"
        $Bin "$@"
}

#
# Filter out everything but the while loop and the two boundary markers.
# Then filter out anything that does not have a ')' in it.  Voila, instant
# help message!
#
help_msg()
{
        sed -n -e '/^### HELP.*start/,/^### HELP.*end/p' "$0" | sed -n -e '/)/p'
}

#
# Output var and contents
#
print_vars()
{
        for var in $ARG_LIST ; do
                echo_e "$var\t(${!var})"
        done
}

### HELP message start
while [ $# -ne 0 ] ; do
        case "$1" in
        -b) BOARD="$2"; shift              # Specify the directory to build from
                ;;
        -e) NO_ERRORS="NO_ERRORS=1"        # Disable -Werror (warnings are errors)
                ;;
        -h) help_msg && exit 0
                ;;
        -p) print_vars && exit 0
                ;;
        -Q) Q="";                          # Expose the raw commands that make issues.
                ;;
        -t) TARGET_DIRS="$TARGET_DIRS ${2%/}"; shift   # Specify build target. May specify multiple times.
                ;;
        -v) VERBOSE="${VERBOSE}V"          # Print info beyond success/failure. May specify multiple times.
                ;;
        -V) V=2                            # More info on make processing
                ;;
        *) tmpvar=${pseudo_targets["$1"]}
           [ -n "$tmpvar" ] && TARGET_DIRS="$TARGET_DIRS ${1%/}" && FF=1;  # Specify build target. May specify multiple times.
           tmpvar=${make_targets["$1"]}
           [ -n "$tmpvar" ] && TARGET_DIRS="$TARGET_DIRS ${1%/}" && FF=1;  # Specify build target. May specify multiple times.
           [ -z "$FF" ] && ARGS_UNXP="$ARGS_UNXP \"$1\"" #
                ;;
        esac
        shift
        unset FF
done
if [ -n "$ARGS_UNXP" ] ; then
        echo -n "Unexpected args were encountered. Stop.  " >&2
        echo "$ARGS_UNXP"
        echo "Perhaps you need to prefix this with '-t'. See help (-h)" >&2
        exit 1
fi
### HELP message end

set_app_list()
{
        local Dir=

        [ ! -d "$1" ] && echo "No directory specified: ($1)" >&2 && return 1
        Dir="$1"
        echo_e $(ls */defconfig | sed -e 's/\/.*//')
}


V=${V:-0}
Q=${Q:-@}
trap on_exit EXIT

(
    cd $RELOCATE >/dev/null || exit 1
    declare -a OUT_FILE=

    DEFAULT_APPS=$(ls */defconfig | sed -e 's/\/.*//')
    TARGET_DIRS=${TARGET_DIRS:-$DEFAULT_APPS}
    [ "${VERBOSE:0:1}" = "V" ] && print_vars

    for build in $TARGET_DIRS ; do
            CMD="make distclean"
            ftmp="${pseudo_targets[$build]}"
            if [ -z "$ftmp" ] ; then
                   echo_e -n "Make distclean ...\r"
                   $CMD > out.distclean 2>&1
            fi
            [ -z "$ftmp" ] &&  OUT_FILE=( ">" out.$build "2>&1"  ) && _N="-n"

            CMD="make V=\"$V\"  $NO_ERRORS $build"

            echo_e "$_N"  "Building for $build: ... "
            eval $CMD ${OUT_FILE[*]}
            if [ $? -ne 0 ] ; then
                    echo_e "Failed."
                    continue
            fi
            echo "Succeeded."
    done
)


