#!/usr/bin/env bash
DOCKER_USER=${SUDO_USER:=vagrant}
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
groupadd docker
systemctl enable docker
id -u $DOCKER_USER
if [[ $?==0 ]]; then
  usermod -aG docker $DOCKER_USER
fi
