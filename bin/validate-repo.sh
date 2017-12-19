#!/bin/bash

#
# Provide a path for debug output given a DEBUG variable set.
#
dbg()
{
        [ -z "$DEBUG" ] && return 0
        echo -e "$@" >&2
}

#
# Verify that the current branch/repo tuple is a style active tuple.
# If not then return 1 and the program will exit 0.  The tuple args
# are to be passed as a list of branch/repo pairs denoted as branch@repo.
#
# E.G.  The zdk branch for the nuttx remote repo would be represented as
#       zdk@nuttx
#
#       Therefore a list of actively styled tuples would look like
#               zdk@nuttx master@nuttx zdk@nuttx_apps master@nuttx_apps
#
verified_active()
{
        local ACTIVE_TUPLES=
        local RemoteName=
        local RemoteUrl=
        local RemoteRepo=
        local ThisTuple=

        #
        # Make sure this repo actually has a remote backing repo
        # otherwise there is nothing to actively monitor.
        #
        if [ -z "$(git remote -v)" ] ; then
                dbg "No remotes configured."
                return 1
        fi

        RemoteName=( $(git status --branch --porcelain=v1 | head -1 | \
            awk -F "." '{print $NF}'| awk  '{print $1}' | sed -e 's:/: :') )
        dbg "RemoteName is (${RemoteName[0]})"
        RemoteUrl=$(git remote get-url ${RemoteName[0]} 2>/dev/null)
        dbg "RemoteUrl is ($RemoteUrl)"
        if [ -z "$RemoteUrl" ] ; then
                dbg "There is no remote url so no remote repo exists."
                return 1
        fi
        RemoteRepo=$(basename $RemoteUrl)
        ThisTuple=${RemoteName[1]}@$RemoteRepo
        dbg "RemoteRepo is ($RemoteRepo)"
        dbg "Current working tuple is ($ThisTuple)"
        for tuple in $@ ; do
                dbg "Verify against tuple ($tuple)"
                if [ ${ThisTuple%%.git} == ${tuple%%.git} ] ; then
                        dbg "There is a match! ($tuple)"
                        return 0
                fi
        done
        return 1
}

#
# From a list of repo@remote tuples see if the currently local
# repo maps back to any in the list.  If it does then the local
# repo is a valid managed repo.
#
in_managed_repo()
{
        local RemoteTuple=

        RemoteName=$(git remote)
        [ -z "$RemoteName" ] && dbg "No remote backing for this repo." && return 1
        RemoteTuple=( $(git remote get-url origin | sed -e 's/^.*@//' | awk -F'/' '{print $1, $2}') )

        VerifyTuple=${RemoteTuple[1]%%.git}@${RemoteTuple[0]%%:*}
        for tuple in $@ ; do
                [ $tuple == $VerifyTuple ] && echo "$VerifyTuple Matched!" && return 0
        done

        return 1
}

REPO_HOST="101.132.142.37"
ACTIVELY_MANAGED_REPOS="nuttx@$REPO_HOST nuttx_apps@$REPO_HOST auto_test@$REPO_HOST"
if ! in_managed_repo $ACTIVELY_MANAGED_REPOS ; then
        echo "This working tree is not from an actively managed repo." >&2
        exit 0
fi
echo "This repo is actively managed."
