#!/bin/bash

#
# A script to run periodically (cron) to automatically
# check-in whatever changes exist in the home-env work
# tree. The changes are committed to a fresh branch that
# is labeled with a timestamp and contains a log message
# summarizing the changes (primarily mention of functions).
#

cd /home/zglue/bin

time_stamp=$(date +"%H.%M%P/%a/%b/%e/%Y")
Branch=$(git branch | grep "^\*" | awk '{print $2}')
Branch=$(echo $Branch | awk -F'_' '{print $1}')_$(echo $time_stamp)
Log_Msg="$( git diff HEAD | sed -n -e '/^[^@]*()/p' -e '/^diff/p')"
# echo "Branch: $Branch"
# echo "LOG: $Log_Msg"

# fa=( $(git status --porcelain=v1 | grep "^\?" | awk '{print $2}') )
fa=( $(git status --porcelain=v1 | awk '{print $2}') )
if ! Root="$(git rev-parse --show-toplevel)" ; then
        echo "Not in a valid repo or tree." >&2
        exit 1
fi
if [ "${#fa[@]}" -eq 0 ] ; then
        echo "Nothing to do."
        exit
fi
for file in "${fa[@]}" ; do
        git add $Root/$file
done

WAIT=30
while ! git checkout -b $Branch >/dev/null 2>&1 ; do
        echo "Not yet: sleep $WAIT -"
        sleep $WAIT
done
git commit -m "$Log_Msg"
git push --set-upstream origin $Branch


