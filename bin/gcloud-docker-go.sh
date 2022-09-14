#!/bin/bash

#
# Once gcloud.sh runs and reboots run this script to build and launch a container.
#
cd ~/dusty/markbot/robot/docker/dev
sudo ./build_dev.sh
./run_dev_container.sh
# [ ./join_dev_container.sh ] || ./run_dev_container.sh
# ./publish_dev.sh

#
# Perform in container.
#

### source $HOME/dusty/markbot/bin/bashrc
### export PS1=${GIT_PROMPT}
