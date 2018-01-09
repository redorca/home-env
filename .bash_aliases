
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
alias       z1="$SSH bill@192.168.168.145"
alias       z2="$SSH bill@192.168.168.146"
alias       z3="$SSH bill@192.168.168.147"
alias       z4="$SSH bill@192.168.168.148"
alias       z5="$SSH bill@192.168.168.149"
alias       z6="$SSH bill@192.168.168.150"
alias       po="popd >/dev/null && dirs -v"
alias     dirs="dirs -v"
alias        j="jobs -l"
alias     jobs="jobs -l"
alias     home="pushd ~ >/dev/null && dirs -v"
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

PS1='${debian_chroot:+($debian_chroot)}\[\033[03;36m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n:: '
LS_COLOR_DATA_FILE=~/Documents/colors.modal.ls
[ -f $LS_COLOR_DATA_FILE ] && eval $(dircolors -b $LS_COLOR_DATA_FILE)


