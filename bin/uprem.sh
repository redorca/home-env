#!/bin/bash -x

URL_GERRIT=ssh://bill@101.132.142.37:30149/nuttx
URL_GITHUB=ssh://git@github.com/zglue-bill/nuttx-local

#
# arg1 is either github or gerrit.
#
set_remote()
{
        local name=

        name="$1"
        Url="URL_${name^^}"
        git remote add $name ${!Url}
}

for host in gerrit github ; do
        URL=$(git remote get-url --push $host)
        Host=URL_${host^^}
        # echo "URL is ${URL%.git}, Host is ${!Host}"
        if [ "${URL%.git}" != "${!Host}" ] ; then
                echo "setup repo for $host"
                set_remote $host
        fi
done

