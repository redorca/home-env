#!/bin/bash

# shellcheck disable=2034
# YLWBLU='\033[1;33;44m'
# shellcheck disable=2034
# YLWltBLU='\033[1;33;46m'
# shellcheck disable=2034
YLWGRN='\033[0;33;42m'
# shellcheck disable=2034
YELLOW="\033[0;33m"
# shellcheck disable=2034
GREEN="\033[0;32m"
BLUE="\033[0;34m"
## # shellcheck disable=2034
LTBLUE="\033[0;36m"
## # shellcheck disable=2034
PURPLE="\033[0;35m"
## # shellcheck disable=2034
RESET='\033[0;39;49m'
# DEBUG=${DEBUG:-0}
declare -A git_review
declare -A git_change

Func()
{
        is_active DEBUG  && echo "${#FUNCNAME[@]} : ${FUNCNAME[1]}()" >&2
}

am_I_lost()
{
        if  xtest="$(git rev-parse --is-inside-git-dir 2>/dev/null)" 2>/dev/null && [ "$xtest" = "true" ] ; then
                #
                # Take our path and strip off everything from .git on down.
                Here="$(pwd)"
                cd "${Here%.git/*}" || exit 2
        elif xtest="$(git rev-parse --is-inside-work-tree 2>/dev/null)" 2>/dev/null && [ "$xtest" = "false" ] ; then
                echo "==== A::a"
                exit
        else
                echo "I have no idea where I am." >&2
                exit 1
        fi
}

is_active()
{
        local Action=

        Action="$1"
        [ "${!Action}" = "1" ] && return 0
        return 1
}

trace()
{
        is_active TRACE
        return
        [ "$TRACE" = "1" ] && return 0
        return  1
}

debug()
{
        is_active DEBUG
        return
        [ "$DEBUG" = "1" ] && return 0
        return 1
}

get_branch_tuple()
{
        Func
        git branch -vv | sed  -e '/^[^*]/d'  \
                              -e 's/^.*\[//' \
                              -e 's/.*\[//'  \
                              -e 's/\].*//'  \
                              -e 's/:.*//'   \
                        | awk -F'/' '{print $1 " " $2}'
}

GERRIT_HOST_IP="${GERRIT_HOST_IP:-"101.132.142.37"}"
GERRIT_HOST_PORT="${GERRIT_HOST_PORT:-"30149"}"
GERRIT_USER="${GERRIT_USER:-"bill"}"
# shellcheck disable=2207
Repo=( $(git remote -v | grep fetch | awk -F'/' '{print $NF}') )
Repo_Branch=( $(get_branch_tuple) )
GERRIT_REPO="${Repo[0]}"
GERRIT_REPO_BRANCH="${GERRIT_REPO_BRANCH:-${Repo_Branch[1]}}"
LOCAL_REMOTE_NAME="${LOCAL_REMOTE_NAME:-${Repo_Branch[0]}}"
GERRIT_XFER_PROTO="${GERRT_XFER_PROTO:-"ssh"}"

setup_gitreview()
{
        Func
	git_review["section"]="gitreview"
	git_review["host"]="$GERRIT_HOST_IP"
	git_review["port"]="$GERRIT_HOST_PORT"
	git_review["username"]="$GERRIT_USER"
	git_review["project"]="$GERRIT_REPO"
	git_review["branch"]="$GERRIT_REPO_BRANCH"
	git_review["remote"]="$LOCAL_REMOTE_NAME"
	git_review["scheme"]="$GERRIT_XFER_PROTO"
}

echo_e()
{
        echo -e "$@${RESET}"
}

setup_gitchange()
{
        Func
        git_change["section"]="git-change"
        git_change["gerrit-ssh-host"]="${GERRIT_HOST_IP}:${GERRIT_HOST_PORT}"

        is_active DEBUG  && echo "[${git_change[*]}]"
        is_active DEBUG  && echo "[${!git_change[@]}]"
}

print_gitrev_config()
{
        echo -e "===== Config ========="
	echo -e "section:\\t${git_review["section"]}"
	echo -e "host:\\t\\t${git_review["host"]}"
	echo -e "port:\\t\\t${git_review["port"]}"
	echo -e "username:\\t${git_review["username"]}"
	echo -e "project:\\t${git_review["project"]}YELLOW"
	echo -e "branch:\\t\\t${git_review["branch"]}"
	echo -e "remote:\\t\\t${git_review["remote"]}"
	echo -e "scheme:\\t\\t${git_review["scheme"]}"
        echo -e "=====        ========="
}

print_section_defaults()
{
        local Key=

        Func
        echo ""
        for Key in "${!git_review[@]}" ; do
                echo_e "Key: ${GREEN}$Key,\\t${BLUE}${git_review[$Key]}"
        done
        [ -n "${git_change[*]}" ] && \
                echo -e "\t============================================="
        for Key in "${!git_change[@]}" ; do
                echo_e "Key: ${GREEN}$Key,\\t${BLUE}${git_change[$Key]}"
        done
        echo ""
}

print_section_config()
{
        Func
        git config --local --get-regexp "${git_review["section"]}.*" | sed -e 's/^/\t/'
        echo ""
        git config --local --get-regexp "${git_change["section"]}.*" | sed -e 's/^/\t/'
}

print_array()
{
        declare -a Array=
        local Last=
        local Count=

        Func
        Name="$1"; shift
        Count=0
        Array=( "$@" )
        Last="${#Array[@]}"
        echo "==="
        echo "Array: ($Name)"
        while [ "$Count" -ne "$Last" ] ; do
                echo "Array[$Count]: ${Array[$Count]}"
                Count=$(( Count + 1 ))
        done
        echo "==="
}

#
# Sift through all local branches reported and find which one
# is the current branch.  Output that name and return.
#
current_branch()
{
        Func
        # shellcheck disable=2162
        git branch | while read one two; do
                [ -z "$two" ] && continue
                [ "$one" = "*" ] && echo "$two" && break
        done
}

help()
{
        # shellcheck disable=2086
        sed -n -e '/^#Help/,/^#Help/p' $0 | grep -v ^#Help | grep -v ";;"
}

reset_configs()
{
        Func
        is_active DEBUG  || git config --local --remove-section ${git_review["section"]}
        is_active DEBUG  || git config --local --remove-section ${git_change["section"]}

        return 0
}

trace && set -x

while [ $# -ne 0 ] ; do
        case "$1" in
#Help Start
        --env) PRINT_ENV="yes" # Print the internal default environment to use.
        ;;
        -e | --edit) git config --local --edit ; exit 0
        ;;
        -h | --help) help && exit 0
        ;;
        -l | --list) PRINT_CURRENT_CONFIG=yes     # Print current settings for the repo.
        ;;
        -r) # Remove the gitreview config info/section.
            RESET_CONFIGS=reset_configs
        ;;
        *)  echo "I have no idea what that argument ($1) means.";
            exit 1
        ;;
#Help End
        esac
        shift
done

setup_gitreview
setup_gitchange

[ -n "$RESET_CONFIGS" ] && $RESET_CONFIGS && exit
[ "$PRINT_CURRENT_CONFIG" = "yes" ] && print_section_config && exit
[ "$PRINT_ENV" = "yes" ] && print_section_defaults && exit


is_active DEBUG  &&  \
        msg="${YLWBLU}DEBUG mode: no changes will be made." \
        && echo_e "$msg" >&2
#
# Set a config section for git to setup git-review
#
Section="${git_review["section"]}"
for Key in "${!git_review[@]}" ; do
        Cmd="git config --local $Section.$Key ${git_review["$Key"]}"
        is_active DEBUG  && echo "  $Cmd" && continue
        $Cmd
done
Section="${git_change["section"]}"
for Key in "${!git_change[@]}" ; do
        Cmd="git config --local $Section.$Key ${git_change["$Key"]}"
        is_active DEBUG  && echo "  $Cmd" && continue
        $Cmd
done

