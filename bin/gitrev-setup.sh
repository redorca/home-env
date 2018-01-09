#!/bin/bash

DEBUG=1
declare -A git_review

am_I_lost()
{
        if  xtest="$(git rev-parse --is-inside-git-dir 2>/dev/null)" 2>/dev/null && [ "$xtest" = "true" ] ; then
                #
                # Take our path and strip off everything from .git on down.
                Here="$(pwd)"
                cd "${Here%.git/*}"
        elif xtest="$(git rev-parse --is-inside-work-tree 2>/dev/null)" 2>/dev/null && [ "$xtest" = "false" ] ; then
                echo "==== A::a"
                exit
        else
                echo "I have no idea where I am." >&2
                exit 1
        fi
}

GERRIT_HOST_IP="${GERRIT_HOST_IP:-"101.132.142.37"}"
GERRIT_HOST_PORT="${GERRIT_HOST_PORT:-"30149"}"
GERRIT_USER="${GERRIT_USER:-"bill"}"
# GERRIT_REPO="${GERRIT_REPO:-"nuttx"}"

Repo=( $(git remote -v | grep fetch | awk -F'/' '{print $4}') )
GERRIT_REPO="${Repo[0]}"
GERRIT_REPO_BRANCH="${GERRIT_REPO_BRANCH:-"zdk"}"
LOCAL_REMOTE_NAME="${LOCAL_REMOTE_NAME:-"origin"}"
GERRIT_XFER_PROTO="${GERRT_XFER_PROTO:-"ssh"}"


git_review["section"]="gitreview"
git_review["host"]="$GERRIT_HOST_IP"
git_review["port"]="$GERRIT_HOST_PORT"
git_review["username"]="$GERRIT_USER"
git_review["project"]="$GERRIT_REPO"
git_review["branch"]="$GERRIT_REPO_BRANCH"
git_review["remote"]="$LOCAL_REMOTE_NAME"
git_review["scheme"]="$GERRIT_XFER_PROTO"


#
# Set a config section for git to setup git-review
#
Section="${git_review["section"]}"
for Key in "${!git_review[@]}" ; do
        Cmd="git config --local "$Section"."$Key" ${git_review["$Key"]}"
        [ "$DEBUG" = "1" ] && echo "Cmd: $Cmd"
        [ "$DEBUG" != "1" ] && $Cmd
done
        
exit
# 
# git config --local gitconfig.host 101.132.142.37
# git config --local gitconfig.username bill
# git config --local gitconfig.port 30149
# git config --local gitconfig.project nuttx
# git config --local gitconfig.branch zdk
# git config --local gitconfig.remote origin
# git config --local gitconfig.scheme ssh
#
