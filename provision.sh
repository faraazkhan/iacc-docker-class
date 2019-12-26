#!/usr/bin/env bash

TOKEN="cdd52f.0b9b67a33a466d15"
ADDRESS="$(ip -4 addr show enp0s8 | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
MASTER_IP="10.1.0.4"
DEFAULT_USER=ubuntu
SHARED_DIR=/vagrant
MASTER_HOSTNAME=master

apt-get update
apt-get install -y apt-transport-https ca-certificates
apt-get install -y curl software-properties-common \
   linux-image-extra-$(uname -r) \
   linux-image-extra-virtual \
   python-pip

#Install and Configure Docker Engine
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
apt-get update && apt-get install -y \
  containerd.io=1.2.10-3 \
  docker-ce=5:19.03.4~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:19.03.4~3-0~ubuntu-$(lsb_release -cs)

mkdir -p /etc/docker

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

systemctl daemon-reload
systemctl restart docker
usermod -aG docker ${DEFAULT_USER}

#Install K8s Packages
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
apt-get install kubeadm kubelet kubectl kubernetes-cni -y

sed -e "s/^.*${HOSTNAME}.*/${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts
sed -e '/^.*ubuntu-bionic.*/d' -i /etc/hosts
sed -i -e 's/AUTHZ_ARGS=.*/AUTHZ_ARGS="/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload
cd ${SHARED_DIR}
kubeadm reset #https://github.com/kubernetes/kubeadm/issues/262
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash # install helm, yes curl bash ;p

# Load Kernel Modules and enable IP Forwarding
# See: https://github.com/kubernetes/kubeadm/issues/1062
# These shouldn't be required (as kubeadm does this), but seem to be flaky, so being safe
modprobe overlay
modprobe br_netfilter
echo '1' > /proc/sys/net/ipv4/ip_forward
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
swapoff -a

if [[ "$HOSTNAME" == "$MASTER_HOSTNAME" ]]; then # Set up Master
  rm -f dashboard-token
  rm -f kubeconfig
  kubeadm init --pod-network-cidr=192.168.128.0/20 --apiserver-advertise-address=${ADDRESS} --token=${TOKEN} --token-ttl=0
  mkdir -p /home/${DEFAULT_USER}/.kube /root/.kube
  cp /etc/kubernetes/admin.conf /home/${DEFAULT_USER}/.kube/config # Set up default kubeconfig
  cp /etc/kubernetes/admin.conf ${SHARED_DIR}/kubeconfig # Copy kubeconfig to host
  cp /etc/kubernetes/admin.conf /root/.kube/config
  chown -R ${DEFAULT_USER}:${DEFAULT_USER} /home/${DEFAULT_USER}/.kube
  kubectl taint nodes --all node-role.kubernetes.io/master-
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/960b3243b9a7faccdfe7b3c09097105e68030ea7/Documentation/kube-flannel.yml
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
  kubectl apply -f admin-sa.yaml
  # This is insecure, but this isn't meant to be used in prod anyway
  helm init --history-max 200
else # Set up Node
  kubeadm join --discovery-token-unsafe-skip-ca-verification --token ${TOKEN} ${MASTER_IP}:6443
  mkdir -p /home/${DEFAULT_USER}/.kube
  cp ${SHARED_DIR}/kubeconfig /home/${DEFAULT_USER}/.kube/config  # Copy kubeconfig to host
  chown -R ${DEFAULT_USER}:${DEFAULT_USER} /home/${DEFAULT_USER}/.kube
fi
