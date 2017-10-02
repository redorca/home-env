#!/usr/bin/env bash

DEBUG=
DRY_RUN=

access_chk()
{
        if [ $(id -u) -ne 0 ] ; then
                if sudo -n ls /root >/dev/null 2>&1 ; then
                        SUDO=sudo
                fi
                if [ -n "$DRY_RUN" ] ; then
                        SUDO=echo
                fi
        fi
}


arg_decode()
{
        local arglist="$@"
        [ -n "$DEBUG" ] && echo "args: $arglist"

        while [ $# -ne 0 ] ; do
                case $1 in
                -n) DRY_RUN=1;;
                -d) DEBUG=1;;
                *) echo "Unknown arg: [$1}"; exit 1;;
                esac
                shift
        done
}

arg_decode "$@"
access_chk

$SUDO apt-get update
$SUDO apt-get install apt-transport-https ca-certificates \
        curl software-properties-common
$SUDO $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
                sudo apt-key add -
if ! $SUDO apt-key fingerprint 0EBFCD88 ; then
        echo "Fundamental problem:  Failed fingerprint test."
        exit 1
fi
$SUDO add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"


$SUDO apt-get update
$SUDO apt-get install docker-ce

#
# Check the installation by running the "hello world" image
#
$SUDO docker run hello-world

