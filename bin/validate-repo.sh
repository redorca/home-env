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

ACTIVELY_MANAGED="zdk@nuttx zdk@nuttx_apps master@nuttx master@nuttx_apps"
if ! verified_active $ACTIVELY_MANAGED ; then
        dbg "This branch  is acively managed."
        exit 1
fi
dbg "This branch  is acively managed."
exit 0

