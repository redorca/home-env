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

    (
        echo "Making ${Target} for ${Arch} architecture"
        cp "$TMPDIR/$Config" .config
        make ${MAKE_OPTS} $Target
    ) > test.${Arch}-${Target}.txt 2>&1
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
#
#
validate_output()
{
        local Arch=
        local Target=

ZEUS_OUTPUT=
SIM_OUTPUT=
        case $Arch in
        esac

    (
        cd ../../
        tar -zcf output.test.${Arch}.${Target}
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

MAKE_OPTS=
[ "$DEBUG" = "1" ] && MAKE_OPTS='Q='
sed -e '1,/^## ::/d' "$0" > ${TARFILE}.xxd
xxd -r ${TARFILE}.xxd > ${TARFILE}
TARGETS=( $(tar -C "$TMPDIR" -zxvf $TARFILE) )
echo_dbg "Number of targets: [${#TARGETS[@]}]"
echo_dbg "Targets are:"
print_array "${TARGETS[@]}"
CLEAR=clean
CLEAR=distclean

eval rm -f "${TARFILE%_*}*"
    (
        cd $ROOT/build/gcc
        do_make config.zeus1.sim distclean zeus1
        for i in $(seq 0 1 3) ; do
                echo_dbg "TARGETS[$i] :: ${TARGETS[$i]}"
                SET=( $(echo ${TARGETS[$i]} | awk -F'.' '{print $2 " " $3}') )
                if [ "${#SET[@]}" -lt 2 ] ; then
                        echo "Not enough members to SET: [${#SET[@]}]" >&2
                        exit 5
                fi
                if do_make "${TARGETS[$i]}" "${SET[1]}" "${SET[0]}" ; then
                        validate_output "${SET[0]}" "${SET[1]}"
                fi
                do_make "${TARGETS[$i]}" "$CLEAR" "${SET[0]}"
                sleep 1
        done
        cd /tmp
        for val in $(seq 0 1 3) ; do
                rm -f "${TARGETS[$val]}"
        done
    )

exit
## :: End of ascii shell code.
