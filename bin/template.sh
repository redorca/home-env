#!/bin/bash

TRACE=${TRACE:-0}
DEBUG=${DEBUG:-0}
SIGNALS=${SIGNALS:-}

#
# Make sure the 'echo' command will process control sequences.
#
Bin=echo
[ -z "$(echo -e "\t")" ] && Bin="/bin/echo -e"

#
# Trap all '$SIGNALS'.
#
on_exit()
{
        RV=$?

        [ $RV -ne 0 ] && echo_e "${RED}=============== Error exit [$RV]: ${RESET}"
        exit $RV
}

#
# Print the name of the function and how deeply nested.
#
Func()
{
        is_active DEBUG  && echo "${#FUNCNAME[@]} : ${FUNCNAME[1]}()" >&2
}

#
# Filter out everything but the while loop and the two boundary markers.
# Then filter out anything that does not have a ')' in it.  Voila, instant
# help message!
#
help_all()
{

        sed -n -e '/^### HELP.*start/,/^### HELP.*end/p' "$0" |
               sed -e '/^### HELP/,/case/d' -e '/esac/,/^### HELP/d' -e '/;;/d'
}

#
# test to see if the variable is "1". Used to key actions off of env vars.
# e.g. if DEBUG=1 then 'is_active DEBUG && foo' will call foo.
#
is_active()
{
        local Action=

        Action="$1"
        [ "${!Action}" = "1" ] && return 0
        return 1
}

#
# Returns true if TRACE=1.  I.E. "trace && set -x" will set the '-x'
# shell option forcing the script to run in tracing mode.
#
trace()
{
        is_active TRACE
        return
        [ "$TRACE" = "1" ] && return 0
        return  1
}

#
# Provide an in-line check for debug status to conditionally enable calls.
# e.g. debug && echo "This is a test" will only fire if DEBUG=1 otherwise
#      it is a no-op.
#
#
debug()
{
        [ "$DEBUG" = "1" ] && return 0
        return 1
}

#
# Wrap 'echo' to cleanly redirect all output to stderr.
#
echo_err()
{
        local Bin=

        CMD="$Bin $@"
        $CMD >&2
}

#
# Shortcut to send output to stderr by default.
#
echo_dbg()
{
        debug || return
        echo_err "$@"
}

### HELP message start
process_args()
{
        while [ $# -ne 0 ] ; do
                case "$1" in
                -h) help_all
                    ;;
                *) [ "${1:0:1}" = "-" ] && echo_err "[ "$1" ] :: Not yet implemented"
                   [ "${1:0:1}" != "-" ] && echo_err "Not sure what to do with ["$1"]"
                   exit
                    ;;
                esac
                shift
        done
}
### HELP message end

trace && set -x
[ -n "$SIGNALS" ] && trap on_exit "$SIGNALS"
process_args "$@"


