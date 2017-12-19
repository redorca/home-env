
ORIGIN=$(pwd)/
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0;39;49m'

#
# Wrapping 'echo' with '/bin/echo' so invoking this
# file manually ala "sh $0" won't barf on 'echo -e'.
#
Echo()
{
        /bin/echo -e "$@"
}

#
# Shortcut to send output to stderr by default.
#
echo_err()
{
        Echo  "$@" >&2
}

#
# Shortcut to send output to stderr by default.
#
echo_dbg()
{
        [ -z "$DEBUG" ] && return

        local i=
        local tmp=

        #
        # If the first character in $@ is a ':' then treat $@ as a string.
        #
        tmp="$@"
        [ "${tmp#:}" != "$tmp" ]  && echo_err "${tmp#:}" && return

        # Else, treat all of the args as undereferenced variables.
        #
        for i in $@ ; do
                echo_err -n "    ::  $i\t\t"
                echo_err  "(${!i})"
        done
}

#
# Create a tmp file to be used by a 'find' call to
# operate on every file of *.[ch]. See filter_style()
#
setup_flip_hashmark()
{
        if [ -z "$1" ] ; then
                echo_err "Is this a file? ($1)?"
                return -1
        fi
        cat >$1 <<"EOF"
#!/bin/bash
#
# For every line that starts with some whitespace leading up to a hash (#)
# replace that set with a leading hash and a space where the original hash
# was
#
# For every instance of '*const', convert to '* const'
#
flip_hashmark()
{
        sed -i  -e '/^  *#/s/^./#/' -e '/^#  *#/s/ #/  /' \
                -e '/^\/\*/,/\*\//s/^\*/ \*/' \
                -e 's/  \*const/ \* const/g'  \
                -e 's/\([^ ]\) \*const/\1 \* const/g' $@
}

if [ -f "$1" ] ; then
        flip_hashmark "$@"
fi

EOF
        chmod +x $1
}

#
# This is called if no files are passed in via the command line.
# Create a set of files to process for styling.  First, look for
# staged files ready to commit.  If found, those # become the set
# of files returned.
#
# If no files are staged, then look for unstaged but tracked/modified
# files.
#
# If nothing is found so far then assume this is a commit --amend
# and use the set of files for the current top most commit.
#
set_files()
{
        local AGAINST=
        local Action=
        local GIT_CMD=
        local FileCount=
        local Files=

        #
        # Default to working on staged files in the index.
        #
        Action="diff --cached"
        [ "$1" = "unstaged" ] && Action="diff"
        GIT_CMD="git \$Action --name-status --diff-filter=d \$AGAINST | \
                        awk '{print \$NF}'"

        #
        # See if there are any staged files to check:
        #
        Files="$(eval $GIT_CMD)" || return 1
        [ -n "$Files" ] && echo $Files && return 0

        #
        # Finding a lack of files to process turn to the most recent
        # commit and assume a commit --amend occurred.
        #
        AGAINST="HEAD^"
        FileCount=$(git log -1 --name-only $AGAINST | wc -l)
        if [ $FileCount -gt 150 ] ; then
                echo_err -n "${RED}Too many files${RESET} to process."
                echo_err "(${BLUE}$FileCount${RESET})"
                return 1
        fi

        Files="$(eval $GIT_CMD)" || return 1
        [ -n "$Files" ] && echo $Files && return 0

        return 1
}

#
# Given a file path find the repo covering that file.
#
find_repo()
{
        local Here=
        local File=
        local Cmd=
        local Rv=

        File="$1"
        Cmd="git rev-parse --show-toplevel"
        [ "${File#/}" != "$File" ] && Here=$(pwd) && cd $(dirname "$File")
        $Cmd 2>/dev/null
        Rv=$?

        [ -n "$Here" ] && cd $Here

        return $Rv
}

#
# Apply astyle to the list of files
#
filter_style()
{
        local Files=
        local Results=

        Results=$1; shift

        Files=$@
        #
        # Look first in the local directory (ORIGIN) to see if
        # astyle is local and executable.  If not then ask 'which'
        # and if that fails then return error.  While 'which' will
        # only report executable files it could report "" (nothing).
        #
        ASTYLE=${ORIGIN}astyle
        [ ! -x "$ASTYLE" ] && ASTYLE=$(which astyle)
        [ ! -x "$ASTYLE" ] && echo_err "Unable to find the astyle program" && return 1

        ASTYLE_OPTS=astyle-nuttx
        STYLE_OPTIONS=${ORIGIN}${ASTYLE_OPTS}
        ZGLUE_OPTS_DIR=/usr/share/zglue/styles
        [ ! -f $STYLE_OPTIONS ] && STYLE_OPTIONS=$ZGLUE_OPTS_DIR/${ASTYLE_OPTS}

        [ -z "$DEBUG" ]  && QUIET='-q'
        echo_dbg ASTYLE STYLE_OPTIONS

        [ -f "$STYLE_OPTIONS" ] || echo_err "Missing [$STYLE_OPTIONS]" || return 1

        #
        # style check the files to commit, quietly unless DEBUG is set.
        #
        CMD="$ASTYLE --options=$STYLE_OPTIONS $QUIET $Files"
        echo_dbg CMD
        $CMD

        CMD="$TMPFILE $Files"
        $CMD

        # Ignore error messages so they themselves don't cause a style failure.
        git diff $Files > $Results 2>/dev/null

        # Remove incidental files generated by astyle and this script.
        #
        find . -type f -name "*.orig" -exec rm {} \;
}

#
# Filter for files in the zglue NRF domain. Primarily files
# containing /nrf* in their repo path.
#
filter_files_for()
{
        local file=
        local dir=

        for file in "$@" ; do
                dir=$(basename $file)
                if [ "${dir#/nrf*}" != "$dir" ] ; then
                        echo -n "$file "
                fi
        done
}

#
# Strip out excess white space at end of lines
#
filter_out_whitespace()
{
        local file=
        local Results=

        Results="$1"; shift
        for file in "$@" ; do
                if [ ${file%%.c} == $file -a ${file%%.h} == $file ] ; then
                        echo_dbg ":Skipping $file"
                        continue
                fi
                sed -i -e 's/[ 	]\+$//' $file
        done
}

#
# Look for any code bracketed by "#if 0...#endif" and flag it.
# and remove it in case the --add flag was passed.
#
filter_if_0()
{
        local Results=
        local Files=

        Results=$1; shift
        Files=$@

        for i in $Files ; do
                if grep "^[ 	]*#if[ 	]*0" $i >/dev/null  2>&1 ; then
                        sed -i -e '/^[ 	]*#if[ 	]*0/iXXX Remove this if 0!!' $i
                fi
        done
}

#
# Filter for files in the zglue NRF domain. Primarily files
# containing /nrf* in their repo path.
#
filter_for_nrf52()
{
        local file=
        local dir=
        local Filter=

        for file in "$@" ; do
                dir=$(dirname $file)/
                for Filter in $FILTERS_NRF ; do
                       #echo "Filter: $Filter:  ${dir%${FILTER_DIR}*}"
                        if [ "${dir%${Filter}*}" != "$dir" ] ; then
                                echo "$file "
                                break
                        fi
                done
        done
}

#
# Look for externs lurking in header files.
#
filter_for_externs()
{
        local Files=
        local Results=

        Results=$1; shift
        Files=$@
        for i in $Files ; do
                [ -n "${i%%*.h}" ] && continue
                grep "^extern.*;" $i >/dev/null 2>&1 && sed -i \
                        -e '/^extern.*;/iXXX Remove this extern!' $i
        done
}

#
# Run all filters on the files finishing with the astyle formatting last.
#
filter_files()
{
        local RepoRoot=
        local Files=
        local TMPFILE=
        local RESULTS=
        local ZGLUE_OPTS_DIR=
        local STYLE=
        local CMD=
        local ASTYLE=
        local ASTYLE_OPTS=
        local RV=

        RV=1
        RESULTS=${ORIGIN}style.errs

        #
        # Make sure this script is running from the repo root.
        #
        [ "$(basename $0)" = "pre-commit" ] && [ ! -d "$1"/.git ] && return 1

        RepoRoot=$1; shift
        [ ! -f "$1" ] && echo_err "No files to style." && exit 1
        Files=$@

        #
        # Adjust the results to account for minor variations from astyle
        # Create temp script to post process files styled by astyle
        #
        TMPFILE=$(mktemp -p /tmp .cleanup_astyle.XXX)
        setup_flip_hashmark $TMPFILE

        [ -n "$RepoRoot" ] && cd $RepoRoot
        for Func in $FILTER_FUNCTIONS ; do
                echo_dbg ":Filter  $Func"
                $Func $RESULTS $Files
                RV=$(( RV + $? ))
        done
#       filter_whitespace $RESULTS $Files
#       filter_if_0 $RESULTS $Files
#       filter_externs $RESULTS $Files

        #
        # Run filter_style last as it will gather all of the diffs into one file.
        #
        filter_style $RESULTS $Files
        grep "^XXX" $RESULTS && unset GIT_ADD
        cd $ORIGIN

        rm $TMPFILE
        #
        # Set return value based on size of output file.
        #
        [ ! -s $RESULTS ] && RV=0 && echo "Remove $RESULTS" && rm $RESULTS

        return $RV
}

#
# From a list of repo@remote tuples see if the currently local
# repo maps back to any in the list.  If it does then the local
# repo is a valid managed repo.
#
in_managed_repo()
{
        local RemoteTuple=
        local VerifyTuple=
        local RemoteName=

        RemoteName=$(git remote)
        [ -z "$RemoteName" ] && echo_dbg "No remote for this repo." && return 1
        RemoteTuple=( $(git remote get-url origin | awk -F'/' '{print $3, $4}') )
        VerifyTuple=${RemoteTuple[1]%%.git}@${RemoteTuple[0]%%:*}
        for tuple in $@ ; do
                if [ $tuple == $VerifyTuple ] ; then
                        echo_dbg "$VerifyTuple Matched!"
                        return 0
                fi
        done

        return 1
}

#
# Return the file list containing only *.[ch] files
#
filter_for_srcfiles()
{
        local file=
        local tmp=

        for file in "$@" ; do
                tmp=${file%%*.[ch]}
                [ -n "$tmp" ] && continue

                tmp="$(echo $file | sed -n -e '/^\//p')"
                [ -n "$tmp" ] && file=${REPOROOT}$file
                echo -n "$file "
                echo_dbg file
        done
}

#
# Use the output of git status to create a set of files to process.
#
git_committed()
{
        local IFS=
        local Filter1=
        local Filter2=

        [ "$1" = "unstaged" ] && IFS=" " && echo_dbg ":Setting IFS to a space"
        Filter1="'/^${IFS}[AMC]/p'"
        Filter2="'/^${IFS}[R]/p'"
        git status -uno --porcelain=v1 | eval sed -n -e $Filter1 -e $Filter2 | \
                awk '{print $NF}'
}
