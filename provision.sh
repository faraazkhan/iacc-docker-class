#!/usr/bin/env bash
DOCKER_USER=${SUDO_USER:=vagrant}
apt-get update -y
apt-get install -y --no-install-recommends \
    apt-transport-https \
    curl \
    software-properties-common \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual
curl -fsSL 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | sudo apt-key add -
add-apt-repository \
   "deb https://packages.docker.com/1.12/apt/repo/ \
   ubuntu-$(lsb_release -cs) \
   main"
apt-get update -y  && apt-get -y install docker-engine="1.12.6~cs13-0~ubuntu-xenial"
groupadd docker
systemctl enable docker
id -u $DOCKER_USER
if [[ $?==0 ]]; then
  usermod -aG docker $DOCKER_USER
fi
 . /vagrant/kubernetes.sh # Uncomment this line to create the kubernetes cluster
