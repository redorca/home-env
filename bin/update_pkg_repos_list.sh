#!/bin/bash

#
# Add new ppas to the list of package repositories
# to check when installing new packages.
#
update_pkg_repos_list()
{
	local tmp
	local i
	local LOGFILE=${LOGFILE:-/tmp/log.ppa.txt}
        local PPAs="
        ppa:team-gcc-arm-embedded/ppa
        ppa:neovim-ppa/stable
        "
        if [ -z "$PPAs" ] ; then
                return
        fi
        echo "Updating list of Ubuntu package repositories."
        for i in $PPAs ; do
                tmp=${i##ppa:}
                if grep -r ${tmp%%/ppa} /etc/apt >/dev/null 2>&1 ; then
                        echo "$i is already registered."
                        continue
                fi
                echo "Adding  :: $i"
                if ! sudo add-apt-repository -y $i >>$LOGFILE 2>&1 ; then
                        echo "Failure adding repository $i"
                        continue
                fi
        done
}

update_pkg_repos_list
