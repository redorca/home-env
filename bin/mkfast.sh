#!/bin/bash

DEBUG=0
[ "$TRACE" = "1" ] && set -x

echo_dbg()
{
        [ "$DEBUG" != "1" ] && return

        echo -e "$@" >&2
}

#
# Wrap make to generalize an interface that automatically captures the output
#
do_make()
{
        local Config=
        local Target=
        local Arch=

        if [ $# -lt 3 ] ; then
                echo "Insufficient number of args: [$#]" >&2
                return 1
        fi

        Config="$1" ; shift
        Target="$1" ; shift
        Arch="$1"   ; shift

        echo "Making ${Target} for ${Arch} architecture"
        cp "$TMPDIR/$Config" .config
        make ${MAKE_OPTS} $Target
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
        local Tmp=
        local RefTime=
        local Arch=
        local Target=
        declare -a Output=

        RefTime="$1" ; shift
        Arch="$1"    ; shift
        Target="$1"  ; shift

        Tmp=fast_api_include_${Arch}.h

        Output=( "fast_api_include.h" "$Tmp" )
        if [ "$Target" = "zeus" ] ; then
                Output=( "${Output[@]}" "fast_api.lib" "map/fast_api.list" "map/System_Fast.map" )
        elif [ "$Target" = "sim" ] ; then
                Output=( "${Output[@]}" "sim/fast_api_sim.o" )
        fi
        Rv=0

    (
        cd ../../output || return 1
        echo "========================================"
        echo "       Validate ${SET[1]} build."

        for file  in "${Output[@]}" ; do
                echo_dbg "  == $file"
                if [ ! -f "$file" ] ; then
                        echo "Missing file: $file"
                        Rv=$(( Rv + 1 ))
                        continue
                fi

                if [ "$RefTime" -nt "$file" ] ; then
                        echo "Old file: $file"
                        Rv=$(( Rv + 1 ))
                        continue
                fi
        done 

        [ -f fast_api_include.h ] &&  \
        if ! diff fast_api_include.h "$Tmp" >/dev/null ; then
                echo "fast_api_include.h does not match $Tmp"
                Rv=1
        fi
        return $Rv
    )
}

if ! ROOT=$(git rev-parse --show-toplevel) ; then
        echo "This directory is not in a git repo or maybe within the .git dir." >&2
        echo "Please run this script from anwyhere within the fast_api repo." >&2
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

[ ! -f $TARFILE ] && echo_dbg "Unable to create a tar file name." && exit 1

MAKE_OPTS='Q='
# [ "$DEBUG" = "1" ] && MAKE_OPTS='Q='
sed -e '1,/^## ::/d' "$0" > ${TARFILE}.xxd
xxd -r ${TARFILE}.xxd > ${TARFILE}
TARGETS=( $(tar -C "$TMPDIR" -zxvf $TARFILE) )
echo_dbg "Number of targets: [${#TARGETS[@]}]"
echo_dbg "Targets are:"
print_array "${TARGETS[@]}"
CLEAR=clean
CLEAR=distclean
CONFIG=.config

eval rm -f "${TARFILE%_*}*"
    (
        cd "$ROOT/build/gcc" || exit 1

        do_make config.zeus1.sim distclean zeus1 >/dev/null 2>&1
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
                if do_make "${TARGETS[$i]}" "${SET[1]}" "${SET[0]}" > $OUTFILE 2>&1 ; then
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
                do_make "${TARGETS[$i]}" "$CLEAR" "${SET[0]}" >/dev/null 2>&1
                sleep 1
        done
    )

    cd /tmp
    rm -f "${TARGETS[$val]}"
    if ERR_OUTS="$(ls "$ROOT"/test.zeus*.txt 2>/dev/null)" ; then
        echo "Fail!!" >&2
        echo -e "See files $(echo $ERR_OUTS | sed -e 's/^/\\n\\t/' -e 's/ /\\n\\t/')\nfor details." >&2
        exit  1
    else
        echo "Success!!"
    fi
exit  0
## :: End of ascii shell code.
