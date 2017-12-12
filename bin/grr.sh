##/usr/bin/env bash
#!/binbash -x


find_commits()
{
        return 1
        local Author="$(git config user.name)"
        local flag=
        local HREV=
        local Num=

        Num=0
        HREV=HEAD
        flag=1
        while [ $flag -ne 0 ] ; do
                git log -1 $HREV
                HREV="$HREV"^
                Num=$(( Num + 1 ))
        done
}

mkpatches()
{
        local Limit=
        local Count=
        local HEAD=
        local PatchFile=


        Limit="$1"; shift
        PatchFile=$1; shift
        Count=1
        HEAD="HEAD~$Limit"
        echo "git log -p $HEAD..HEAD > $PatchFile.all.txt"
        git log -p $HEAD..HEAD > $PatchFile.all.txt
return 0
        while [ $Limit -ne 0 ] ; do
                git log -p "$HEAD"^.."$HEAD" > $PatchFile.$Count.txt
                HEAD="$HEAD"^
                Limit=$(( Limit - 1 ))
                Count=$(( Count + 1 ))
        done

}

reset_hard()
{
        local Depth=
        local Commit=

        Depth=$1
        Commit=$(git log -1 HEAD~$Depth | grep commit | awk '{print $2}')
        echo "Commit is ($Commit)"
        git reset --hard $Commit
}

restore()
{
        local Count=
        local PatchFile=
        local Depth=

        Depth=$1; shift
        PatchFile=$1; shift
        Count=1

        patch -i $PatchFile.all.txt -p1
return 0
        while [ $Depth -gt 0 ] ; do
                PatchFile="$PatchFile.'$Count'.txt"
                CMD="patch -i eval $PatchFile -p1"
                echo "$CMD"
                Depth=$(( Depth - 1 ))
                Count=$(( Count + 1 ))
        done
}

stage_changes()
{
        local PatchFile=
        local CommitMsgFile=

        PatchFile=$1 ; shift
        CommitMsgFile=$1 ; shift


}

stage()
{
        local Files=

        Files=$(git diff --name-status --diff-filter=d | awk '{print $2}')
        git add $Files
}


find_log_depth()
{
        local Email=
        local HEAD=
        local Count=
        local Var=

        HEAD=HEAD
        [ $# -ne 2 ] && echo "Need 2 args: Email and Depth count. $#" >&2 && return 1
        [ -n "$1" ] && Email=$1; shift
        Var=$1 ; shift

        Count=0
        while [ "$Email" == "$(git log -1 $HEAD | grep Author: | awk '{print $4}')" ] ; do
                HEAD="$HEAD"^
                echo "HEAD is ($HEAD)" >&2
                Count=$(( Count + 1 ))
        done

        eval $Var=$Count
        echo "eval $Var=$Count" >&2
}

go()
{
        [ -z "$Email" ] && Email="<$(git config user.email)>"
        echo "Search key:  ($Email)"
        find_log_depth $Email Num

        mkpatches $Num  Patches
        reset_hard $Num
        restore $Num Patches
}

verbose()
{
        cat <<EOF
        Num   : $Num
        Email : $Email
        HEAD  : $HEAD
EOF
}

help()
{
        cat <<"EOF"
        -a) go ; exit $?
          ;;
        -D) Email="<zhiqiang@zglue.com>"
          ;;
        -E) [ -z "$2" ] && echo "No email supplied." >&2 && exit 1
            Email="$2"; shift
          ;;
        -h) help && exit 0
          ;;
        -m) [ $Num -gt 0 ] && mkpatches $Num Patch && exit 0
          ;;
        -N) find_log_depth $Email Num && echo "Num is $Num"
          ;;
        -n) Num=$2; shift
           [ -z "$Num" ] && echo "Bad number" >&2 && exit 1
          ;;
        -p) [ $Num -gt 0 ] && restore $Num && exit 0
            echo "Depth of commits is 0: Please make sure Depth is provided." >&2
            exit 1
          ;;
        -r) [ $Num -gt 0 ] && reset_hard $Num && exit 0
            echo "Depth of commits is 0: Please make sure Depth is provided." >&2
            exit 1
          ;;
        -v) verbose && exit 0
          ;;
EOF
}

HEAD=HEAD
Num=0

while [ $# -ne 0 ] ; do
        case $1 in
        -a) go ; exit $?
          ;;
        -D) Email="<zhiqiang@zglue.com>"
          ;;
        -E) [ -z "$2" ] && echo "No email supplied." >&2 && exit 1
            Email="$2"; shift
          ;;
        -h) help && exit 0
          ;;
        -m) [ $Num -gt 0 ] && mkpatches $Num Patch && exit 0
          ;;
        -N) find_log_depth $Email Num && echo "Num is $Num"
          ;;
        -n) Num=$2; shift
           [ -z "$Num" ] && echo "Bad number" >&2 && exit 1
          ;;
        -p) [ $Num -gt 0 ] && restore $Num && exit 0
            echo "Depth of commits is 0: Please make sure Depth is provided." >&2
            exit 1
          ;;
        -r) [ $Num -gt 0 ] && reset_hard $Num && exit 0
            echo "Depth of commits is 0: Please make sure Depth is provided." >&2
            exit 1
          ;;
        -v) verbose && exit 0
          ;;
        *)
          ;;
        esac
        SHIFT=1
        shift
done
[ -z "$SHIFT" ] && echo "Done" >&2 && exit
# Num=4
# mkpatches $Num Patch
# reset_hard $Num
# while [ $Num -ne 0 ] ; do
#         restore $Num Patch
#         Num=$(( Num - 1 ))
# done

