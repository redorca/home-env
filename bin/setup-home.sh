#!/bin/bash

#
# Setup a sym link from ~/ to wherever the home-env/.git clone lives.
# This will allow the repo to cover /home/<xxx> without having to
# start with an empty directory.
#

REPO_ID=home-env

pushd ~/ >/dev/null
GIT_DIR=$(find ~/ -type d -name .git | grep $REPO_ID)
if [ "$(echo $GIT_DIR | wc -l)"  -ne 1 ] ; then
	echo "Too many dirs named $REPO_ID found." >&2
	exit 1
fi
echo "Found git at $GIT_DIR"
if [ -L ".git" ] ; then
	echo "A symlink already exists in the home dir." >&2
fi
echo ln -sf $GIT_DIR
popd >/dev/null
