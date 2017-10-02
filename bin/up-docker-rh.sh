#!/usr/bin/env bash

DEBUG=
DRY_RUN=
VERSION_DOCKER=

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
                -n) DRY_RUN=1;echo "Dry run activated.";;
                -d) DEBUG=1;echo "Debug activated.";;
		-v) VERSION_DOCKER=$1;echo "Version set $1";;
                *) echo "Unknown arg: [$1}"; exit 1;;
                esac
                shift
        done
}

Exec()
{
	CMD="$@"
	[ -n "$DRY_RUN" ] && echo "+ $CMD" && return 0
	if ! $CMD ; then
		exit 1
	fi
}

ubu_dkr_setup()
{
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
}

rh_dkr_setup()
{
	local DOCKER_VER=$1
	# Prep tools for install.
	Exec sudo yum install -y yum-utils device-mapper-persistent-data lvm2

	Exec sudo yum-config-manager --add-repo \
		https://download.docker.com/linux/centos/docker-ce.repo

	Exec sudo yum install docker-ce
	Exec sudo systemctl start docker
	Exec sudo docker run hello-world
	if [ -z "$DOCKER_VER" ] ; then
		Exec yum list docker-ce.x86_64  --showduplicates | sort -r
	fi
}

arg_decode "$@"
access_chk

rh_dkr_setup $VERSION_DOCKER

