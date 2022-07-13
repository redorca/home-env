#!/bin/bash

cd $HOME
sudo apt-get -y install apt-transport-https ca-certificates gnupg curl docker

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

sudo apt-get update && sudo apt-get -y install google-cloud-cli

## RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring  /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-cli -y

sudo apt-get -y install "
    google-cloud-cli
    google-cloud-cli-anthos-auth
    google-cloud-cli-app-engine-go
    google-cloud-cli-app-engine-grpc
    google-cloud-cli-app-engine-java
    google-cloud-cli-app-engine-python
    google-cloud-cli-app-engine-python-extras
    google-cloud-cli-bigtable-emulator
    google-cloud-cli-cbt
    google-cloud-cli-cloud-build-local
    google-cloud-cli-cloud-run-proxy
    google-cloud-cli-config-connector
    google-cloud-cli-datalab
    google-cloud-cli-datastore-emulator
    google-cloud-cli-firestore-emulator
    google-cloud-cli-gke-gcloud-auth-plugin
    google-cloud-cli-kpt
    google-cloud-cli-kubectl-oidc
    google-cloud-cli-local-extract
    google-cloud-cli-minikube
    google-cloud-cli-nomos
    google-cloud-cli-pubsub-emulator
    google-cloud-cli-skaffold
    google-cloud-cli-spanner-emulator
    google-cloud-cli-terraform-validator
    google-cloud-cli-tests
    kubectl"

gcloud init

gcloud auth login
gcloud auth configure-docker

curl -fsSL https://tailscale.com/install.sh | sh


mkdir ~/dusty
cd dusty
git clone ssh://git@github.com/dustyrobotics/markbot


curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo apt install docker-compose
## sudo groupadd docker
## sudo usermod -a -G docker $USER

reboot
## > cd ~/dusty/markbot/robot/docker/dev
## > ./build_dev.sh
## > ./run_dev_container.sh
## > ./join_dev_container.sh
## > ./publish_dev.sh
## source $HOME/dusty/markbot/bin/bashrc
## export PS1=${GIT_PROMPT}
## 
## # then re-load your bashrc:
## 
## > source ~/.bashrc
## 
## https://code.visualstudio.com/docs/?dv=linux64_deb
## # inside your development container:
## > sudo apt install ~/Downloads/code*
## 
## ############################################################
## # inside your development container:
## > cd ~/dusty/markbot/robot/
## > mkdir build
## > cd build
## > cmake ..
## > make -j4    # get coffee
## > make -j14  # on a more powerful Lenovo laptop
## 
## # Or use the convenient bash scripts available in the bin path:
## 
## > m        # invokes "make -j6 all"
## > mr        # invokes "make -j6 dusty_robot", which builds only the robot
