
#
#  If this script is called then we know for sure we're in
#  an interactive (login?) environment.  So, any code added
#  to ths fil will only ever see an interactive environment.
#

declare -A dir_to_flag
dir_to_flag["dir"]="d"
dir_to_flag["file"]="f"
ZERO="0"
DBG_LVL="${DBG_LVL:-$ZERO}"

#
# Set exported variable TRACE to 1 (on) or 0 (off).
# Pertains mostly to shell scripts who check for
# TRACE and "set -x" when TRACE=1.
#
function trace()
{
        local PUBLISH=

        PUBLISH=( "eval" "echo" "TRACE: [\$TRACE]" )
        case "$1" in
        1|on|ON)    export TRACE=1 && ${PUBLISH[@]}
        ;;
        0|off|OFF)  TRACE=0 && ${PUBLISH[@]}
        ;;
        *) [ -z "$1" ]  && ${PUBLISH[@]}
           [ ! -z "$1" ] && echo "WTF?! [ $1 ]"
        ;;
        esac
}

#
#
# Simplify creating a cscope tag database
#
function tag()
{
        local  START_DIR=
        local  CSCOPE_OPTS=
        local  CSCOPE_DBFILE=

        CSCOPE_DBFILE=cscope.out
        START_DIR="./"
        [ -n "$1" ] && [ -d "$1" ] && START_DIR="$1"
        CSCOPE_OPTS="-R -k -b -s"
        [ -f "$CSCOPE_DBFILE" ] && rm "$CSCOPE_DBFILE"
        cscope $CSCOPE_OPTS "$START_DIR"
}

function vim_color_setup()
{
        local new_color=

        [ -z "$1" ] && return 1

        new_color="$1"
        last=$(sed -n -e '/^[^#]*color /s/.*color *//p' ~/.vimrc | tail -1)
        [ "$last" == "$new_color" ] && return
        sed -i -e '/^[#]*color.*${last}/s/color.*${last}/color $new_color/' ~/.vimrc
        echo "Color will go from $last to $new_color"
}

function pd()
{
	pushd $1 >/dev/null
	dirs -v
}

function add_path()
{
        if echo $PATH | sed -e 's/:/ /g' | grep -w "$1" >/dev/null ; then
               return
        fi
        if [ ! -d "$1" ] ; then
                [ "$BASH_DBG" = "1" ] && echo "No such path exists: ($1)" >&2
                return
        fi
        PATH=$1:$PATH
}

function del_path()
{
        if [ -z "$1" ] ; then
                return
        fi
        FOO=$(echo $PATH | sed -e 's/:/ /g' | eval sed -e "'s:$1::'")
        if [ $? -eq 0 -a -n "$FOO" ] ; then
                PATH=$(echo $FOO | sed -e 's/^ //' -e 's/  */:/g')
        fi
}

#
# Find all files of type ARG2 and remove them. E.G to get rid of all
# .rej files resulting from patch call rm-fu .rej. ARG1 specifies what
# kind of things to remove such as "<file|dir>"
#
function find-fu()
{
        ([ -z "$1" ] || [ -z "$2" ]) && echo "Missing an arg or two." >&2 && return 1
        local find_key=
        local Flag=
        local regex=
        local ACTION_ARG=
        find_key="${1,,}"
        Flag="${dir_to_flag["$find_key"]}"; shift
        regex="$1"; shift
        [ "$Flag" == "d" ] && OPTS="r"
#       ACTION_ARG="-exec rm -${OPTS}f {} \;"
        ACTION_ARG=
        [ "$DEBUG_FU" == "$DBG_LVL" ] && ACTION_ARG="-print"

        [ "$DEBUG_FU" == "$DBG_LVL" ] && echo -ne "find_key: ($find_key), " \
                && echo -n  "Flag: ($Flag),""regex: ($regex); OPTS: ($OPTS)," \
                && echo     " ACTION_ARG: ($ACTION_ARG)"

        [ "$DEBUG_FU" == "$DBG_LVL" ] && echo -ne "find . -type $Flag " \
                && echo     " -name \"${regex}\" $ACTION_ARG"
        CMD='find . -type $Flag -name \"${regex}\" "$ACTION_ARG"'
        if ! eval $CMD ; then
                eval echo "== $CMD" >&2
        fi
}


#
# Find all files of type ARG2 and remove them. E.G to get rid of all
# .rej files resulting from patch call rm-fu .rej. ARG1 specifies what
# kind of things to remove such as "<file|dir>"
#
function rm-fu()
{
        ([ -z "$1" ] || [ -z "$2" ]) && echo "Missing an arg or two." >&2 && return 1
        local find_key=
        local Flag=
        local regex=
        local ACTION_ARG=
        find_key="${1,,}"
        Flag="${dir_to_flag["$find_key"]}"; shift
        regex="$1"; shift
        [ "$Flag" == "d" ] && OPTS="r"
        ACTION_ARG="-exec rm -${OPTS}f {} \;"
        [ "$DEBUG_FU" == "$DBG_LVL" ] && ACTION_ARG="-print"

        [ "$DEBUG_FU" == "$DBG_LVL" ] && echo -ne "find_key: ($find_key), " \
                && echo -n  "Flag: ($Flag),""regex: ($regex); OPTS: ($OPTS)," \
                && echo     " ACTION_ARG: ($ACTION_ARG)"

        [ "$DEBUG_FU" == "$DBG_LVL" ] && echo -ne "find . -type $Flag " \
                && echo     " -name \"${regex}\" $ACTION_ARG"
        CMD='find . -type $Flag -name \"${regex}\" "$ACTION_ARG"'
        if ! eval $CMD ; then
                eval echo "== $CMD" >&2
        fi
}

#
# ssh into one of the z servers: 1 - 6.
#
zee()
{
        local ZSERVER=
        local Msg=

        Msg="Please pass only a single digit between 1 and 6."
        if [ -z "$1" ] || [ "${#1}" -gt 1 ] || [ -z "$(echo $1 | tr -d [:alpha:])" ] ; then
                echo "$Msg" >&2
                return 1
        fi
        [ -z "$(echo "$1" | tr -d [:alpha:])" ] && echo "$Msg" >&2 && return 1
        ZSERVER="${1: -1:1}"
        ZSERVER=$(( ZSERVER + 144 ))
        if [ "$ZSERVER" -lt 145 ] || [ "$ZSERVER" -gt 150 ] ; then
                echo "Trailing digit does not represent any Z server id ["$ZSERVER"]" >&2
                echo "$Msg" >&2
                return 1
        fi

        CMD="$SSH bill@192.168.168.${ZSERVER}"
        echo $CMD && $CMD
}

export EDITOR=vim
export GOPATH=$HOME/src/GOlang/newt
# SSH="ssh -v -C -L 5999:localhost:5990"
SSH="ssh -Y"

add_path /usr/share/doc/git/contrib/git-jump
add_path ~/.cabal/bin
add_path ~/bin

# alias z1="$SSH -o ServerAliveInterval=30 -p 12110 bill@192.168.168.145"
# alias z2="$SSH -o ServerAliveInterval=30 -p 12110 bill@192.168.168.146"
# alias z3="$SSH -o ServerAliveInterval=30 -p 12110 bill@192.168.168.147"
# alias z4="$SSH -o ServerAliveInterval=30 -p 12110 bill@192.168.168.148"
# alias z5="$SSH -o ServerAliveInterval=30 -p 12110 bill@192.168.168.149"
# alias z6="$SSH -o ServerAliveInterval=30 -p 12110 bill@192.168.168.150"
# alias       z1="$SSH bill@192.168.168.145"
# alias       z2="$SSH bill@192.168.168.146"
# alias       z3="$SSH bill@192.168.168.147"
# alias       z4="$SSH bill@192.168.168.148"
# alias       z5="$SSH bill@192.168.168.149"
# alias       z6="$SSH bill@192.168.168.150"
alias       po="popd >/dev/null && dirs -v"
alias     dirs="dirs -v"
alias        j="jobs -l"
alias     jobs="jobs -l"
alias     home="pushd ~ >/dev/null && dirs -v"
alias      bin="pushd ~/bin >/dev/null && dirs -v"
alias       vi=vim
alias   valias="vim ~/.bash_aliases"
alias  vignore="vim ~/.config/git/ignore"
alias     path="echo \$PATH"
alias    asize="arm-none-eabi-size"
alias     relf="arm-none-eabi-readelf"
alias   status="git status | sed -n -e '1,/^Untracked/p'"
alias     mods="git status | grep modified:"
alias    shlvl='echo "Shell Depth:   $SHLVL"'
alias resource="source ~/.bashrc"
alias   launch="xdg-open"
alias     diff="diff --exclude=\".git\" --exclude=\"out.*\" --exclude=\"*.patch\" --exclude=\"patch.*\""
alias      cls="clear_console"
alias     grep="grep --exclude=.git --exclude=cscope.out"
alias     halt="sudo /sbin/shutdown -h -t now"

if which apt-get >/dev/null 2>&1 ; then
        echo "Set prompt for Debian sys-arch"
        PS1='${debian_chroot:+($debian_chroot)}\[\033[03;36m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n:: '
else
        # disable gnome-ssh-askpass
        unset SSH_ASKPASS
        #
        #  Aliases found in my Ubuntu bash environment by default.
        #
        alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
        alias egrep='egrep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias ls='ls --color=auto'
        echo "Set prompt for Redhat sys-arch"
        PS1='\[\033[03;36m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n:: '
fi
LS_COLOR_DATA_FILE=~/Documents/colors.modal.ls
[ -f $LS_COLOR_DATA_FILE ] && eval $(dircolors -b $LS_COLOR_DATA_FILE)

#
# To satisfy .vimrc's need for a file to source until I know
# more .vimrc coding and can check for its existence first.
#
touch ~/.vimrc_color

