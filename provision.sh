#!/usr/bin/env bash
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
groupadd docker
usermod -aG docker vagrant
systemctl enable docker
