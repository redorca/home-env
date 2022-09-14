#!/bin/bash

#
# Orient ourselves to a known location everytime.
#
cd $HOME
PREP_PACKAGES="apt-transport-https ca-certificates gnupg curl docker"
dusty_dir=${HOME}/"Dusty"

system_prep()
{
        sudo apt-get -y install $PREP_PACKAGES
}

gcloud_create()
{
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

    sudo apt-get update && sudo apt-get -y install google-cloud-cli

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
}

tailscale_init()
{
        curl -fsSL https://tailscale.com/install.sh | sh
}

dusty_init()
{
        mkdir $dusty_dir
        cd $dusty_dir
        git clone ssh://git@github.com/dustyrobotics/markbot
}

setup_docker()
{
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        sudo apt install docker-compose
        sudo groupadd docker
        sudo usermod -a -G docker $USER
}

container()
{
        cd ${dusty_dir}/markbot/robot/docker/dev
        sudo ./build_dev
        sudo ./run_dev_container
}

prep_chk()
{
        for pkg in $PREP_PACKAGES ; do
                if ! dpkg -l $pkg >/dev/null 2>&1 ; then
                        MISSING="$MISSING $pkg"
                fi
        done
        if [ -n "$MISSING" ] ; then
                echo "Missing packages $MISSING" >&2
                return -10
        fi
        return 0
}

docker_chk()
{
        if ! grep docker /etc/group 2>/dev/null ; then
                return -1
        fi
        return 0
}

dusty_chk()
{
        if ! [ -d "$dusty_dir" ] ; then
                return 1
        fi
        return 0
}

contained()
{
        if [ ! -f /.dockerenv ] ; then
                return 1
        fi
        return 0
}

container
exit
#
# Don't run inside a container
#
if  contained ; then
        exit 0
fi

if ! gcloud auth configure-docker ; then
        gcloud_init
fi

if ! tailscale >/dev/null 2>&1 ; then
        tailscale_init
fi

if ! dusty_chk ; then
        dusty_init
fi

if ! prep_chk ; then
        system_prep
fi

if ! docker_chk ; then
        setup_docker
        reboot
fi

container

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
