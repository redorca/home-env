#!/bin/bash

sed -i -re 's/([a-z]{2}\.)?archive.ubuntu.com|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list

apt-get update && sudo apt-get dist-upgrade

do-release-upgrade

