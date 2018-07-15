# declare -A -g Paths

ulimit -c unlimited

export DEBUG="$DEBUG"
export DEBUG=1
RESET="\033[0;39;49m"
BLACK="\033[1;30m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
LTBLUE="\033[0;36m"
UNKNOWN="\033[0;37m"

ITALIC=3
BOLD=1
UNDERL=4
STRIKE=9
HIDE=8
INVERT=7
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
unset TRACE
unset DEBUG

declare -A ip_to_display
ip_to_display["default"]="1920x1080"
ip_to_display["192.168.168"]="2048x1152"
ip_to_display["192.168.183"]="1680x1050"

function dbg_echo()
{
        [ "$DEBUG" != "1" ] && return
        echo -e "$@" >&2
}

function funame()
{
        dbg_echo "==> ${FUNCNAME[1]} ($@)"
}

function get_home_ip()
{
        funame $@
        local IP=
        local foo=
        local faa=
        local Count=
        declare -a Candidates

        Candidates=( $(ls $(find /sys/devices/pci0000\:00/ -type d -name net)) )

        Count=$(( ${#Candidates[@]} - 1 ))
        for i in $(seq 0 1 $Count) ; do
                if [ -n "$(ip -4 -o link show "${Candidates[$i]}" up)" ] ; then
                        foo=( $(ip -4 -o addr show ${Candidates[$i]}) )
                        faa=( $(echo ${foo[3]} | sed -e 's:\.: :g') )
                        IP="${faa[0]}.${faa[1]}.${faa[2]}"
                        dbg_echo "=== IP found is $IP"
                        echo "$IP"
                        break
                fi
        done
}

function display_geo()
{
        xdpyinfo | grep dimension | awk '{print $2}'
}

function what()
{
        case "$1" in
        reso*) diplay_geo ; exit ;;
        *);;
        esac
}

function set_display_resolution()
{
        funame $@
        local IPaddr=
        local TargetRes=
        local CurrentRes=
        local IP_ADDR=

        [ $# -eq 1 ] &&  TargetRes="$1"

        IP_ADDR=$(get_home_ip)
        dbg_echo "Found IP_ADDR: $IP_ADDR"
        TargetRes=${ip_to_display["$IP_ADDR"]}
        [ -z "$TargetRes" ] && dbg_echo "No resolution matches that ip addr, use default." \
                           && TargetRes="${ip_to_display[default]}"

        CurrentRes=$(display_geo)

#         Geometry=( $(echo $CurrentRes | awk -F'x' '{print $1 "  " $2}') )
#         if [ "${Geometry[0]}" -gt 1440 ] && [ "${Geometry[1]}" -gt 900 ] ; then
#                 Geometry[0]=1680
#                 Geometry[1]=1050
#         elif [ "${Geometry[0]}" -gt 1600 ] && [ "${Geometry[1]}" -gt 900 ] ; then
#                 Geometry[0]=2048
#                 Geometry[1]=1152
#         fi

        [ -z "$TargetRes" ] && echo "No target resolution set, keep the current one." && return 1
        dbg_echo " TargetRes : ($TargetRes), CurrentRes : ($CurrentRes)"
        [ "$TargetRes" = "$CurrentRes" ] && return 0
        echo "Reset display to $TargetRes." && xrandr -s $TargetRes
}

function set_assoc_array()
{
        funame $@
        local Name=
        local foo=

        Name=$1 ; shift
        echo -n "declare -g -A "
        for foo in $@ ; do
                echo -n "$Name[$foo]=1  "
        done
}

function prune_path()
{
        funame $@
        declare -a Foo
        local Limit=
        local Path=
        declare -g -A Paths

        Foo=( $(echo $PATH | sed -e 's/:/  /g') )
#       echo -n "${Foo[0]}"

        Limit=$(( ${#Foo[@]} -1 ))
        for i in $(seq 1 1 $Limit); do
                dbg_echo "\${Paths[${Foo[$i]}]}   ${Paths[${Foo[$i]}]}"
                [ -z "${Paths[${Foo[$i]}]}" ] && continue
                [ -n "${Paths[${Foo[$i]}]}" ] && dbg_echo "Already in Paths: ($Path)" && continue
#               echo -n ":${Foo[$i]}"
        done
        echo ""
}

eval $(set_assoc_array Paths $(echo $PATH | sed -e 's/:/ /g'))
prune_path A::a

function add_path()
{
        funame $@
        local Dir=

#       set -x

        Dir="$1"

        [ ! -d "$Dir" ] && dbg_echo "No such path exists: ($Dir)" && return
#       [  -d "$Dir" ] && echo "[  -d $Dir ]"
#       dbg_echo "::({Paths[$Dir]}) (${Paths[$Dir]})"

        [ -n "${Paths[$Dir]}" ] && dbg_echo "Won't add path. Already present: $Dir" && return
        ([ -z "$PATH" ] && echo "Starting with empty PATH." >&2)
        PATH="$Dir:$PATH"
        set +x
}

#
# Set a BOARD env var used by zmake to determine which configs dir to use.
#
function board()
{
        funame $@
        local Dir=

        Dir="$1"
        [ -d "$(git rev-parse --show-toplevel)/configs/$1" ] || return 1

        [ -n "$Dir" ] && export BOARD="$Dir"
        echo "BOARD: [$BOARD]"
}

function del_path()
{
        funame $@
        if [ -z "$1" ] ; then
                return
        fi
        FOO=$(echo $PATH | sed -e 's/:/ /g' | eval sed -e "'s:$1::'")
        if [ $? -eq 0 -a -n "$FOO" ] ; then
                PATH=$(echo $FOO | sed -e 's/^ //' -e 's/  */:/g')
        fi
}

#
# Export DEBUG = 1 (on) or disable (0)
#
function dbg()
{
        local PUBLISH=

        PUBLISH=( "eval" "echo" "DEBUG: [ \$DEBUG ]" )
        case "$1" in
        [1-9]*|on)    export DEBUG=1 && ${PUBLISH[@]}
        ;;
        0|off)  DEBUG= && ${PUBLISH[@]}
        ;;
        *) [ -z "$1" ]  && ${PUBLISH[@]}
           [ ! -z "$1" ] && echo "WTF?! [ $1 ]"
        ;;
        esac
}

#
# Find all files of type ARG2 and remove them. E.G to get rid of all
# .rej files resulting from patch call rm-fu .rej. ARG1 specifies what
# kind of things to remove such as "<file|dir>"
#
function find-fu()
{
        funame $@
        ([ -z "$1" ] || [ -z "$2" ]) && echo "Missing an arg or two." >&2 && return 1
        local find_key=
        local Flag=
        local regex=
        local ACTION_ARG=
        find_key="${1,,}"
        [ -z "$Flag" ] && echo "Please supply a proper key" >&2 return 1
        [ "$TRACE" = "2" ] && set -x
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
                eval dbg_echo "== $CMD"
        fi
        set +x
}

function pd()
{
	pushd $1 >/dev/null
	dirs -v
}

#
# Find all files of type ARG2 and remove them. E.G to get rid of all
# .rej files resulting from patch call rm-fu .rej. ARG1 specifies what
# kind of things to remove such as "<file|dir>"
#
function rm-fu()
{
        funame $@
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
                eval dbg_echo "== $CMD"
        fi
}

#
# Run "set" and grab the output for whatever shell function
# is specified.
#
function show()
{
        funame $@
        local Func=

        case "$1" in
        -l) set | grep "^[a-zA-Z_-]*[ 	]*()"
           ;;
        *) Func="$1"
           ;;
        esac

        set | eval sed  -n -e '/^$1/,/^}/p'
}

#
#
# Simplify creating a cscope tag database
#
function tag()
{
        funame $@
        local  START_DIR=
        local  CSCOPE_OPTS=
        local  CSCOPE_DBFILE=

        CSCOPE_DBFILE=cscope.out
        START_DIR="./"
        [ -n "$1" ] && [ -d "$1" ] && START_DIR="$1"
        CSCOPE_OPTS="-R -k -b -s"
        [ -f "$CSCOPE_DBFILE" ] && echo "Removed current cscope.out" >&2 && rm "$CSCOPE_DBFILE"
        cscope $CSCOPE_OPTS "$START_DIR"
}

#
#
# Simplify creating a cscope tag database
#
function rtag()
{
        funame $@
        local  START_DIR=
        local  CSCOPE_OPTS=
        local  CSCOPE_DBFILE=

        CSCOPE_DBFILE=cscope.out
        Path=$(pwd)
        while [ ! -d $Path/.git ] ; do
                if [ -d "$Path/home" ] && [ -d "$Path/boot" ] ; then
                        dbg_echo "Hit the root dir, not .git dir found."
                        return 1
                fi
                Path=$(dirname $Path)
        done
        dbg_echo "==========================="
        chk_debug && ls -d $Path/../*/.git
        dbg_echo "==========================="
        if [ $(ls -d $Path/../*/.git | wc -l) -gt 1 ] ; then
                Path=$(dirname $Path)
        fi
        dbg_echo "Would run cscope from $Path"
        CSCOPE_OPTS="-R -k -b -s"
        [ -f "$CSCOPE_DBFILE" ] && echo "Removed current cscope.out" >&2 && rm "$CSCOPE_DBFILE"
        cscope $CSCOPE_OPTS "$Path"
}

#
# Check status of $TRACE and return TRUE if its
# value is 1 else return false.
#
function chk_debug()
{
        [ "$DEBUG" = "1" ] && return 0
        return 1
}

#
# Check status of $TRACE and return TRUE if its
# value is 1 else return false.
#
function chk_trace()
{
        [ "$TRACE" = "1" ] && return 0
        return 1
}

#
# Set exported variable TRACE to 1 (on) or 0 (off).
# Pertains mostly to shell scripts who check for
# TRACE and "set -x" when TRACE=1.
#
function trace()
{
        local PUBLISH=

        PUBLISH=( "eval" "echo" "TRACE: [\$TRACE]" )
        case "${1,,}" in
        [1-9]*|on)    export TRACE=1 && ${PUBLISH[@]}
        ;;
        off|0)  TRACE= && ${PUBLISH[@]}
        ;;
        *) [ -z "$1" ]  && ${PUBLISH[@]}
           [ ! -z "$1" ] && echo "WTF?! [ $1 ]"
        ;;
        esac
}

#
# Edit a file in ~/bin from anywhere on the system.
#
function vimbin()
{
        funame $@
        local -a Files=

        Files="$*"
        pushd ~/bin > /dev/null && vim $Files && popd >/dev/null
}

function vim_color_setup()
{
        funame $@
        local new_color=

        [ -z "$1" ] && return 1

        new_color="$1"
        last=$(sed -n -e '/^[^#]*color /s/.*color *//p' ~/.vimrc | tail -1)
        [ "$last" == "$new_color" ] && return
        sed -i -e '/^[#]*color.*${last}/s/color.*${last}/color $new_color/' ~/.vimrc
        echo "Color will go from $last to $new_color"
}

#
# ssh into one of the z servers: 1 - 6.
#
function zee()
{
        funame $@
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
alias          po="popd >/dev/null && dirs -v"
alias        dirs="dirs -v"
alias           j="jobs -l"
alias        jobs="jobs -l"
alias        home="pushd ~ >/dev/null && dirs -v"
alias         bin="pushd ~/bin >/dev/null && dirs -v"
alias          vi=vim
alias      valias="vim ~/.bash_aliases"
alias     vignore="vim ~/.config/git/ignore"
alias     vimtodo="vim ~/bin/TODO.now"
# alias    vimbin="vim ~/bin/\$1"
alias   bincommit="bash -c 'cd ~/bin && git-x.sh -c'"
alias     binpush="bash -c 'cd ~/bin && git-x.sh -p'"
# alias        path="echo \$PATH"
alias       asize="arm-none-eabi-size"
alias        relf="arm-none-eabi-readelf"
alias      status="git status | sed -n -e '1,/^Untracked/p'"
alias        mods="git status | grep modified:"
alias       shlvl='echo "Shell Depth:   $SHLVL"'
alias    resource="source ~/.bashrc"
alias      launch="xdg-open"
alias        diff="diff --exclude=\".git\" --exclude=\"out.*\" --exclude=\"*.patch\" --exclude=\"patch.*\""
alias         cls="clear_console"
alias        grep="grep --exclude=.git --exclude=cscope.out"
alias        halt="sudo /sbin/shutdown -h -t now"
alias        sudo="sudo -H"


#
# Map a standard tool to an arm directed tool name.
#
function arm()
{
        local Prefix=
        local Cmd=

        Prefix="arm-none-eabi-"
        Cmd=${Prefix}${1} ; shift
        if ! type $Cmd >/dev/null ; then
                echo "Apparently no such binary can be found: <$Cmd>" >&2
                return 3
        fi

        $Cmd $@
}

function path()
{
        funame $@
        case "$1" in
        -l) eval $(echo "$PATH" 2>/dev/null | sed -e 's/^/echo "/' -e 's/:/"; echo "/g' -e 's/$/"/')
        ;;
        *) echo "$PATH"
        ;;
        esac
}

function set_attrib()
{
        local Color=
        local ATTR=

        ( [ -z "$1" ] || [ -z "$2" ] ) && return
        Color="${1^^}" ; shift
        ATTR="${1^^}" ; shift
        echo -e "${!Color}" | eval sed -e \'s:\\[.:\\[${!ATTR}:\'
}

#
# Take a color arg passed in and set the appropriate attribute.
#
function invert()
{
        set_attrib "${1^^}" INVERT
}

#
# Take a color arg passed in and set the appropriate attribute.
#
function uline()
{
        set_attrib "${1^^}" UNDERL
}

#
# Take a color arg passed in and set the appropriate attribute.
#
function strike()
{
        set_attrib "${1^^}" STRIKE
}

#
# Take a color arg passed in and set the appropriate attribute.
#
function bold()
{
        set_attrib "${1^^}" BOLD
}

#
# Take a color arg passed in and set the appropriate attribute.
#
function italic()
{
        set_attrib "${1^^}" ITALIC
}

#
# Take a color arg passed in and set the appropriate attribute.
#
function hide()
{
        set_attrib "${1^^}" HIDE
}

#
# Wrap grep to redirect stderr to /dev/null
#
function Grep()
{
        /bin/grep "$@" 2>/dev/null
}

function foo()
{
        local CLRA=
        local CLRB=
        local RST=

        (chk_trace || chk_debug) || return 0
        echo -n " "
        RST="$RESET"
        chk_trace || CLRA="$(italic RED)" && CLR_A="$(italic BLUE)"
        chk_debug || CLRB="$(italic RED)" && CLR_B="$(italic BLUE)"
        chk_trace && echo -n -e "$(italic BLUE)trace[${CLRA}${TRACE}${CLR_A}] "
        chk_debug && echo -n -e "$(italic BLUE)debug[${CLRB}${DEBUG}${CLR_B}]"
        echo -n "::"
}

#
# Returns TRUE if run from within a working tree.
#
function gitchk()
{
        git rev-parse 2>/dev/null
}

foo_git()
{
        funame $@
        pushd ./ >/dev/null
        DIRPATH=$(pwd)
        while [ $DIRPATH != "/" ] ; do
                [ -d "$DIRPATH/.git" ] && return 0
                DIRPATH=$(dirname $DIRPATH)
                echo "DIRPATH:  ($DIRPATH)"
                sleep 1
        done
        popd >/dev/null
}

function branch()
{
        local Length=
        local TMP=
        local Kolor=

        Kolor=PURPLE
        Length="$1" ; shift
        [ "${#Length}" -eq 0 ] &&  Length=0
        [ -n "$(echo $Length | sed -e 's:[0-9]::g')" ] && Length=0

        ! gitchk && echo -n -e "$(invert BLACK)===${RESET}" && return

        TMP="$(git branch | sed -e '/^ /d' -e 's/^.*  *//')" 2>/dev/null
        if [ "$Length" -gt 0 ] && [ "${#TMP}" -gt "$Length" ] ; then
                TMP=$(echo "${TMP: -$Length}")
        fi
        echo -e "$(invert $Kolor)${TMP#*/}${RESET}"
}

function repo()
{
        local Remote=
        local Repo=
        local Kolor=

        Kolor=PURPLE
        Remote=()
        Repo=XXXX
        ! gitchk && echo -n -e "$(hide BLACK)$Repo${RESET}" && return

        Remote=( $(git status -sb | head -1 | sed -e 's/^.*\.\.\.//' -e 's/ //g' | awk -F'/' '{print $1 "  " $2}') ) 2>/dev/null
        [ "${#Remote[@]}" -eq 2 ] && Repo="${Remote[0]}"
        echo -n -e "$(bold $Kolor)$Repo${RESET}"
}

function restart_time()
{
        local Time=ntp
        local Time_Canonical="--user restart indicator-datetime"

        dbg_echo "Restarting system time service."
        if ! sudo systemctl restart $Time >/dev/null 2>&1; then
                dbg_echo "Unable to restart ntpd so try indicator-datetime."
                if ! systemctl $Time_Canonical >/dev/null 2>&1 ; then
                        echo "Unable to restart any time services." >&2
                        return 1
                fi
        fi

        return 0
}


if which apt-get >/dev/null 2>&1 ; then
        echo "Set prompt for Debian sys-arch"
        PS1='${debian_chroot:+($debian_chroot)}$(branch 15)@$(repo)::$(foo)\[\033[03;36m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n:: '
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
# To satisfy .vimrcs need for a file to source until I know
# more .vimrc coding and can check for its existence first.
#
prune_path A::b
PATH=$(echo ${!Paths[@]} | sed -e 's/ /:/g')

#
# Set display resolution according to ip addr /24
#
chk_debug || set_display_resolution
restart_time
touch ~/.vimrc_color
