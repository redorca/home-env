#!/bin/bash

DEBUG=${DEBUG:-0}
[ "$TRACE" = "1" ] && set -x
declare -a Output=
# declare -a DELIVERABLES=

echo_err()
{
        echo -e "$@" >&2
}

echo_dbg()
{
        [ "$DEBUG" != "1" ] && return

        echo -e ":: $@" >&2
}

retrieve_configs()
{
        local Hash=

        Hash="$1"
        if ! git checkout "$Hash" build/configs >/dev/null 2>&1 ; then
                echo "Could not checkout config directory." >&2
                return 1
        fi
}

#
# Wrap make to generalize an interface that automatically captures the output
#
do_make()
{
        local CommitHash=
        local Target=
        local Arch=

        if [ $# -lt 3 ] ; then
                echo "Insufficient number of args: [$#]" >&2
                return 1
        fi

        CommitHash="$1" ; shift
        Target="$1" ; shift
        Results="$1"   ; shift

#       cp "$TMPDIR/$Config" .config
#       make ${MAKE_OPTS} deliverables $Target | tee $Results | sed -e '/=/s/^.*=//'
        make ${MAKE_OPTS} $Target | tee $Results
}

#
#
#
print_array()
{
        [ "$DEBUG" = "1" ] || return 1

        for i in $(seq 0 1 $#) ; do
                echo -e "\t$1"
                shift
        done
}

#
# Arg1 : File to serve as a reference time stamp.
#
validate_files()
{
        local Rv=
        local RefTime=
        local Arch=
        local File=

        RefTime="$1" ; shift

        Rv=0

    (
        cd ../../output || return 1
        echo "========================================"
        echo "       Validate ${SET[1]} build."
set -x
        for File  in "${DELIVERABLES[@]}" ; do
                echo_err "File  == $File"
                if [ -f "$File" ] ; then
                        if [ "$RefTime" -ot "$File" ] ; then
                                continue
                        else
                                echo_err "Old file: $File"
                        fi
                else
                        echo_err "Missing file: $File"
                fi
                Rv=$(( Rv + 1 ))
        done 
set +x
        return $Rv
    )
}

if ! ROOT=$(git rev-parse --show-toplevel) ; then
        echo "This directory is not in a git repo or maybe it's within the .git dir." >&2
        echo "Please run this script from anwyhere within the fast_api repo prroper." >&2
        echo "" >&2
        exit 1
fi
if [ ! -f "$ROOT"/build/gcc/Makefile ] ; then
        echo "Can't find $ROOT/build/gcc/Makefile." >&2
        echo "Please relocate to a fast_api repo tree." >&2
        echo "" >&2
        exit 2
fi

TMPDIR=/tmp
TARFILE=$(mktemp -p "$TMPDIR" .config_XXX)
# echo "TARFILE  :: ($TARFILE)"
FOOFILE=/tmp/foo

[ ! -f $TARFILE ] && echo_dbg "Unable to create a tar file name." && exit 1

[ "$DEBUG" = "1" ] && MAKE_OPTS='Q='
sed -e '1,/^## ::/d' "$0" > ${TARFILE}.xxd
xxd -r ${TARFILE}.xxd > ${TARFILE}
# TARGETS=( $(tar -C "$TMPDIR" -zxvf $TARFILE) )
TARGETS=$(
echo_dbg "Number of targets: [${#TARGETS[@]}]"
echo_dbg "Targets are:"
print_array "${TARGETS[@]}"
CLEAR=clean
CLEAR=distclean
CONFIG=.config
# COMMIT_HASH=056ac757144fc5d008c7141a50e31e1fcc9e8233

eval rm -f "${TARFILE%_*}*"
    (
        cd $ROOT && retrieve_configs "$CommitHash"
        cd "$ROOT/build/gcc" || exit 1

        do_make "$COMMIT_HASH" distclean /tmp/foo >/dev/null 2>&1
        rm -f "$ROOT/test.zeus*.txt"
        for i in $(seq 0 1 3) ; do
                echo_dbg "TARGETS[$i] :: ${TARGETS[$i]}"
                SET=( $(echo ${TARGETS[$i]} | awk -F'.' '{print $2 " " $3}') )
                if [ "${#SET[@]}" -lt 2 ] ; then
                        echo "Not enough members to SET: [${#SET[@]}]" >&2
                        exit 5
                fi

                OUTFILE="$ROOT"/test."${SET[0]}"."${SET[1]}".txt
                echo -e -n "Test build of ${SET[1]} for ${SET[0]}\t"
                if Output=( $(do_make "${TARGETS[$i]}" "${SET[1]}" "$OUTPUT" "${SET[0]}" | sed -n -e '/=/p')) ; then
                        echo_err "${#Output[@]} :: ${Output[@]}"
                        eval "${Output[@]}"
                        echo_err "Deliverables: [ ${DELIVERABLES[@]} ]"
                        [ -f "$OUTFILE" ] && rm -f "$OUTFILE"
                        if validate_files $CONFIG "${SET[0]}" "${SET[1]}" >>$OUTFILE ; then
                                echo "Success"
                                rm $OUTFILE
                        else
                                echo "Fail" >&2
                                Rv=1
                        fi
                else
                        echo "Failed"
                fi
                do_make "${TARGETS[$i]}" "$CLEAR" "$OUTPUT" "${SET[0]}" >/dev/null 2>&1
                sleep 1
        done
    )

    cd /tmp
    rm -f "${TARGETS[$val]}"
    if ERR_OUTS=( $(ls "$ROOT"/test.zeus*.txt 2>/dev/null)  ) ; then
        echo "Fail!!" >&2
        echo -e "See files $(echo ${ERR_OUTS[@]} | sed -e 's/^/\\n\\t/' -e 's/ /\\n\\t/g')\nfor details." >&2
        exit  1
    else
        rm -f $FOOFILE
        echo "Success!!"
    fi
exit  0
## :: End of ascii shell code.
