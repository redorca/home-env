#!/bin/bash

err_codes_to_text=(
EPERM
ENOENT
ESRCH
EINTR
EIO
ENXIO
E2BIG
ENOEXEC
EBADF
ECHILD
EAGAIN
ENOMEM
EACCES
EFAULT
ENOTBLK
EBUSY
EEXIST
EXDEV
ENODEV
ENOTDIR
EISDIR
EINVAL
ENFILE
EMFILE
ENOTTY
ETXTBSY
EFBIG
ENOSPC
ESPIPE
EROFS
EMLINK
EPIPE
EDOM
ERANGE
)

declare -A errno

setup_error_codes()
{
        for i in $(seq 0 33) ; do
                name="${err_codes_to_text[$i]}"
                errno["$name"]=$i
        done
}

print_error_codes()
{
	for key in "${!errno[@]}" ; do
	        echo -e -n "$key\t"
	        [ "${#errno[$key]}" -lt 7 ] && echo -e -n "\t:: "
	        echo "${errno[$key]}"
	done
}

print_name_to_code()
{
        local err="$1"

        [ -z "$err" ] && echo "No error specified." >&2 && return 1
        echo "${errno[$err]}"
}

print_code_to_name()
{
        local err="$1"

        [ -z "$err" ] && echo "No error specified." >&2 && return 1
        echo "${err_codes_to_text[$err]}"
}

list_err_map()
{
        for i in $(seq 0 33) ; do
                key=${err_codes_to_text[$i]}
                val=$i
                echo -e -n "  $key\t"
                [ "${#key}" -lt 6 ] && echo -n -e "\t"
                echo "$val"
        done
}

help_errno()
{
        sed -n -e '/^### Begin/,/^### End/p' $0 | grep ')'
}
## === End of error functions ###

[ -z "$1" ] && help && exit 1
setup_error_codes

### Begin help
while [ $# -gt 0 ] ; do
        case $1 in
        -h) help_$(basename ${0%.sh}) && exit 0
        ;;
        -l) list_err_map && exit
        ;;
        *)
        ;;
        esac
done
### End help

# print_code_to_name $1
print_name_to_code ${1^^}

