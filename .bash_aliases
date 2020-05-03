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
export REPO_ARCHIVEDIR="$([ -d /var/www/html ] && find /var/www/html -type d -name dists)"
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
ip_to_display["default"]="1600x900"
ip_to_display["192.168.168"]="2048x1152"
ip_to_display["192.168.183"]="1920x1080"

function on_exit()
{
    set +x
}


trap on_exit EXIT ERR

function err_echo()
{
        echo -e $@ >&2
}

function dbg_echo()
{
        [ "$DEBUG" != "1" ] && return
        err_echo "$@"
}

function do-exit()
{
        local ErrCode=
        local ErrMsg=

        ErrCode="$1" ; shift
        ErrMsg="$@"
        echo "$ErrMsg" >&2

        exit $ErrCode
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

function display-geo()
{
        xdpyinfo | grep dimension | awk '{print $2}'
}

function what()
{
        case "$1" in
        reso*) diplay-geo ; exit ;;
        *);;
        esac
}

function set-display-resolution()
{
        funame $@
        local IPaddr=
        local TargetRes=
        local CurrentRes=
        local IP_ADDR=

        if ! which xdpyinfo >/dev/null 2>&1 ; then
                dbg_echo "xdpyinfo not found."
                return 1
        fi
        [ $# -eq 1 ] &&  TargetRes="$1"

        IP_ADDR=$(get_home_ip)
        dbg_echo "Found IP_ADDR: $IP_ADDR"

        [ -z "$TargetRes" ] && TargetRes=${ip_to_display["$IP_ADDR"]}
        [ -z "$TargetRes" ] && dbg_echo "No resolution matches that ip addr, use default." \
                           && TargetRes="${ip_to_display[default]}"

        CurrentRes=$(display-geo)

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
dbg_echo -n ":${Foo[$@]}"
dbg_echo "========================"

prune_path A::a

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

#
# Recalculate the Paths hash based on the current PATHS var.
#
function reset_hash()
{
        eval $(set_assoc_array Paths $(echo $PATH | sed -e 's/:/ /g'))
}

function add-path()
{
        funame $@
        local Dir=

        Dir="$1"

        [ ! -d "$Dir" ] && dbg_echo "No such path exists: ($Dir)" && return

        [ -n "${Paths[$Dir]}" ] && dbg_echo "Path already present: $Dir" && return
        ([ -z "$PATH" ] && err_echo "Starting with empty PATH.")
        PATH="$Dir:$PATH"
        reset_hash
        set +x
}

function del-path()
{
        funame $@
        if [ -z "$1" ] ; then
                return
        fi
        FOO=$(echo $PATH | sed -e 's/:/ /g' | eval sed -e "'s:$1::'")
        [ -z "${Paths["$1"]}" ] && dbg_echo "Path already gone." && return 0
        Paths["$1"]=""
        if [ $? -eq 0 -a -n "$FOO" ] ; then
                PATH=$(echo $FOO | sed -e 's/^ //' -e 's/  */:/g')
        fi
        reset_hash
}

#
# Test for a paths presence in $PATH
#
function has-path()
{
        echo $PATH | grep $1 >/dev/null
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
        Func) DEBUG=Func && ${PUBLISH[@]}
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
        ([ -z "$1" ] || [ -z "$2" ]) && err_echo "Missing an arg or two."  && return 1
        local find_key=
        local Flag=
        local regex=
        local ACTION_ARG=
        find_key="${1,,}"
        [ -z "$Flag" ] && err_echo "Please supply a proper key"  return 1
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
        ([ -z "$1" ] || [ -z "$2" ]) && err_echo "Missing an arg or two."  && return 1
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
function tag_by_cscope()
{
        funame $@
        local  START_DIR=
        local  CSCOPE_OPTS=
        local  CSCOPE_DBFILE=

        CSCOPE_DBFILE=cscope.out
        START_DIR="./"
        [ -n "$1" ] && [ -d "$1" ] && START_DIR="$1"
        CSCOPE_OPTS="-R -k -b -s"
        [ -f "$CSCOPE_DBFILE" ] && err_echo "Removed current cscope.out"  && rm "$CSCOPE_DBFILE"
        cscope $CSCOPE_OPTS "$START_DIR"
}

#
# Create GTAGS used by the global command.
# The tag file will live in the root dir
# that gtags runs. Global will ascend to
# look for it.
#
function tag_by_gtags()
{
        gtags .
}

#
# Ascend the directory tree looking for a .git root.
#
function find_root_gitdir()
{
        trace_on_off
        local Path="$1"
        if [ $# -eq 0 ] ; then
                err_echo "A directory path to search is required."
                trace_on_off
                exit 1
        fi
        if [ ! -d "$Path" && ! -L "$Path" ] ; then
                err_echo "That path doesn't point to a directory."
                trace_on_off
                exit 1
        fi
        while [ ! -d $Path/.git ] ; do
                if [ -d "$Path/home" ] && [ -d "$Path/boot" ] ; then
                        dbg_echo "Hit the root dir '/', no .git dir found."
                        trace_on_off
                        return 1
                fi
                Path=$(dirname $Path)
        done
        echo "$Path"
        trace_on_off
}

#
#
# Simplify creating a local cscope tag
# database that is rooted.
#
function rtag()
{
        funame $@
        local  START_DIR=
        local  CSCOPE_OPTS=
        local  CSCOPE_DBFILE=

        CSCOPE_DBFILE=cscope.out
        Path="$(find_root_gitdir $(pwd))"
        dbg_echo "==========================="
        chk_debug && ls -d $Path/../*/.git
        dbg_echo "==========================="
        if [ $(ls -d $Path/../*/.git | wc -l) -gt 1 ] ; then
                Path=$(dirname $Path)
        fi
        dbg_echo "Would run cscope from $Path"
        CSCOPE_OPTS="-R -k -b -s"
        [ -f "$CSCOPE_DBFILE" ] && err_echo "Removed current cscope.out"  && rm "$CSCOPE_DBFILE"
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
# If the TRACE var is set then turn
# on shell tracing.
#
function trace_on_off()
{
        set +x
        chk_trace && set -x
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
function vbin()
{
        funame $@
        local -a Files=

        Files="$*"
        pushd ~/bin > /dev/null
        vim $Files
        popd >/dev/null
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
                err_echo "$Msg"
                return 1
        fi
        [ -z "$(echo "$1" | tr -d [:alpha:])" ] && err_echo "$Msg" && return 1
        ZSERVER="${1: -1:1}"
        ZSERVER=$(( ZSERVER + 144 ))
        if [ "$ZSERVER" -lt 145 ] || [ "$ZSERVER" -gt 150 ] ; then
                err_echo "Trailing digit does not represent any Z server id ["$ZSERVER"]"
                err_echo "$Msg"
                return 1
        fi

        CMD="$SSH bill@192.168.168.${ZSERVER}"
        echo $CMD && $CMD
}

export EDITOR=vim
export GOPATH=$HOME/src/GOlang/newt
# SSH="ssh -v -C -L 5999:localhost:5990"
SSH="ssh -Y"

add-path /usr/share/doc/git/contrib/git-jump
add-path ~/.cabal/bin
add-path ~/usr/bin
add-path ~/.local/bin
[ ! -d "$HOME/.local/bin" ] && add-path ~/bin
[   -d "$HOME/.local/bin" ] && add-path ~/.local/bin

alias  preset-phrase="/usr/lib/gnupg2/gpg-preset-passphrase --preset"
# alias            apt="sudo apt-get -y"
alias             ve="virtualenv -p /usr/bin/python3"
alias           path="echo \$PATH | sed -e 's/^/	/' -e 's/:/	/g'"
alias             po="popd >/dev/null && dirs -v"
alias           dirs="dirs -v"
alias             jo="jobs -l"
alias           jobs="jobs -l"
alias           home="pushd ~ >/dev/null && dirs -v"
alias            bin="pushd ~/bin >/dev/null && dirs -v"
alias             vi="vim"
alias         valias="vim ~/.bash_aliases"
alias         status="git status | sed -n -e '1,/^Untracked/p'"
alias           mods="git status | grep modified:"
alias          shlvl='echo "Shell Depth:   $SHLVL"'
alias       resource="source ~/.bashrc"
alias           diff="diff --exclude=\".git\" --exclude=\"out.*\" --exclude=\"*.patch\" --exclude=\"patch.*\""
alias            cls="clear_console"
alias           grep="grep --exclude=.git --exclude=cscope.out"
alias           halt="sudo /sbin/shutdown -h -t now"
alias           sudo="sudo -H"
alias        restart="sudo systemctl restart"
alias          deact="deactivate"

#
# Activate a virtualenv
#
function pybox()
{
        local VDir=

        VDir="$1"
        [ ! -d "$VDir" ] && do-exit 1 "Not a dir: $VDir"

        source $VDir/bin/activate
}

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
                err_echo "Apparently no such binary can be found: <$Cmd>"
                return 3
        fi

        $Cmd $@
}

function Path()
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

function foo_git()
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

#
# Generate a symlink from '/.../.mnt/zgle/$Dir' to ~src directory.
#
function goo()
{
    ( [ -z "$@" ] && err_echo "Need a directory" ) && return 1

    DISKMNT=$HOME/.mnt
    HOME_SRCDIR=$HOME/src
    SRCDIR="$1"
    APPDIR="$DISKMNT/zglue/$SRCDIR"

    if [ ! -d "$SRCDIR" ] ; then
        if [ ! -d "$APPDIR" ] ; then
            err_echo "No app or local directory exist"
            return 1
        fi
    else
        [ ! -d "$APPDIR" ] && cp -a "$SRCDIR" "${APPDIR%/*}"
    fi


    [ -d "$SRCDIR" ] && rm -rf "$SRCDIR"
    ln -sf "$DISKMNT/zglue/$SRCDIR" "$HOME_SRCDIR"
}

#
# Call xdg-open but disconnect from the terminal.
#
function launch()
{
    [ ! -e "$1" ] && return 99

    xdg-open "$1" >/dev/null 2>&1

}

function expand_conf_vars()
{
        local Var=
        local File=
        local FileTempl=

        Var="$1"; shift
        File="$1"; shift
        FileTempl=$(dirname $File)/.template$(basename $File)
        [ -f "$FileTempl" -a ! -f $File ] && cp $FileTempl $File
        SED_OPTS=(  \
                "-i" "-e"  \
                "/::$Var/s,::$Var,${!Var},"  \
                "$File" \
        )
        sed ${SED_OPTS[@]}
}

function apt()
{
        local Action=
        local Cmd=

        [ $# -eq 0 ] && return 1

        Cmd="sudo /usr/bin/apt-get -y"

        case "$1" in
        search)
                Cmd=/usr/bin/apt
        ;;
        esac

        echo "$Cmd $@" >&2
        $Cmd $@
}

#
# Access available python modules info without
# interactive control. The commands assembled
# are echoed inline through a pipe to the python
# executable with output pushed to stdin.
#
# param: The topic of interest fully specified
#        by prefixing with its module name.
#           pyhelp(requests.status_codes)
#
#        or if the object is only the module,
#           pyhelp(requests)
#
function pyhelp()
{
    local Target=
    local Module=
    declare -a Phrase=()

    if [ $# -eq 0 ] ; then
        return
    fi

    #
    # Ensure module names are snake style compliant.
    Target="$(echo $1 | tr - _)"; shift
    Module=${Target%.*}
    if [ "$Module" == "${Target}" ] ; then
        Target=${Target#$Module}
    else
        Target=${Target#${Module}}
    fi

    if [ -n "$1" ] ; then
        dbg_echo "Two args were passed:"
        Target=."$1" ; shift
    fi
    dbg_echo "Target $Target , Module $Module"

    Phrase=( "echo" """ "import" "$Module" "\;" "help\(${Module}${Target}\)" """ )
#   Phrase=( "echo" """ "import" "$Module" """ ";" """ 'help' "(${Module}${Target})" """ )

    echo "${Phrase[*]}"
    ${Phrase[@]} | python
 
}


#
# Start up a virtual environment by running
# activate from bin/ in the directory passed.
#
# param: Name of the project.
#
function acton()
{
        [ $# -ne 1 ] && return 1

        local ActDir=
        local ProjPath=

        ActDir="$1" ; shift
        ProjPath="$ActDir/bin/activate"
        if [ ! -f "$ProjPath" ] ; then
                ProjPath="$HOME/src/$ProjPath"
                if [ ! -f "$ProjPath" ] ; then
                        err_echo "No activate file found" && return 2
                fi
        fi

        source "$ProjPath"
        cd ${ProjPath%/bin/activate}
}

function gclone()
{
        GITHUB_SSH="ssh://github@github.com/"
        git clone ${GITHUB_SSH}$1.git $1
}

export GPG_TTY=$(tty)

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
# chk_debug || set-display-resolution
touch ~/.vimrc_color

if [ -z "$REPO_ARCHIVEDIR" ] ; then
        export REPO_ARCHIVEDIR=/var/www/html/$USER/dists
        sudo mkdir -p /var/www/html/$USER/dists
fi
sudo chown -R $USER:$USER $REPO_ARCHIVEDIR
expand_conf_vars REPO_ARCHIVEDIR ~/.mini-dinstall.conf
expand_conf_vars USER ~/.mini-dinstall.conf
expand_conf_vars USER ~/.dput.cf 


#
# Reset to home dir unless VIRTUAL_ENV is set.
#
[ -z "$VIRTUAL_ENV" ] && VIRTUAL_ENV="$HOME"
cd "$VIRTUAL_ENV"


