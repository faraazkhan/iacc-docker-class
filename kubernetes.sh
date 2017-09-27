#!/usr/bin/env bash

TOKEN="cdd52f.0b9b67a33a466d15"
MASTER_IP="10.1.0.4"
KUBE_API_PORT="6443"

apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm

function init_cluster() {
  cat > /tmp/master.yaml <<EOF
---
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
api:
  advertiseAddress: ${MASTER_IP}
  bindPort: ${KUBE_API_PORT}
token: ${TOKEN}
token-ttl: 0
networking:
  podSubnet: 10.244.0.0/16
EOF
  kubeadm init --config /tmp/master.yaml
  mkdir -p ~/.kube
  cp /etc/kubernetes/admin.conf /root/.kube/config # set up config for current script
  id -u vagrant
  if [[ "$?" == "0" ]]; then # Assume you are in a vagrant box
    mkdir -p /home/vagrant/.kube
    cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config # Set up default kubeconfig
    cp /etc/kubernetes/admin.conf /vagrant/kubeconfig # Copy kubeconfig to host
    chown -R vagrant:vagrant /home/vagrant/.kube
  fi
}

if [[ "$HOSTNAME" == "master" ]]; then
  init_cluster
  kubectl taint nodes --all node-role.kubernetes.io/master-
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/standalone/heapster-controller.yaml
  kubectl apply -f admin-sa.yaml
else
  kubeadm join --token ${TOKEN} ${MASTER_IP}:${KUBE_API_PORT}
  id -u vagrant
  if [[ "$?" == "0" ]]; then
    mkdir -p /home/vagrant/.kube
    cp /vagrant/kubeconfig /home/vagrant/.kube/config  # Copy kubeconfig to host
    chown -R vagrant:vagrant /home/vagrant/.kube
  fi
fi
