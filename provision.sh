#!/usr/bin/env bash

TOKEN="cdd52f.0b9b67a33a466d15"
ADDRESS="$(ip -4 addr show enp0s8 | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
MASTER_IP="10.1.0.4"
DEFAULT_USER=ubuntu
SHARED_DIR=/vagrant

apt-get update
apt-get install -y apt-transport-https ca-certificates
apt-get install -y curl \
   linux-image-extra-$(uname -r) \
   linux-image-extra-virtual \
   python-pip
pip install --upgrade pip
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  apt-key add -
apt-key adv \
   --keyserver hkp://ha.pool.sks-keyservers.net:80 \
   --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg |  apt-key add -
echo 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' |  tee /etc/apt/sources.list.d/docker.list
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' |  tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y docker-engine=1.12*
service docker start
usermod -aG docker ${DEFAULT_USER}
apt-get install kubeadm kubelet kubectl kubernetes-cni -y
sed -e "s/^.*${HOSTNAME}.*/${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts
sed -e '/^.*ubuntu-xenial.*/d' -i /etc/hosts
sed -i -e 's/AUTHZ_ARGS=.*/AUTHZ_ARGS="/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload
cd ${SHARED_DIR}

if [[ "$HOSTNAME" == "master" ]]; then # Set up Master
  rm -f dashboard-token
  rm -f kubeconfig
  pip install docker-compose
  kubeadm init --apiserver-advertise-address=${ADDRESS} --token=${TOKEN} --token-ttl=0
  mkdir -p /home/${DEFAULT_USER}/.kube /root/.kube
  cp /etc/kubernetes/admin.conf /home/${DEFAULT_USER}/.kube/config # Set up default kubeconfig
  cp /etc/kubernetes/admin.conf ${SHARED_DIR}/kubeconfig # Copy kubeconfig to host
  cp /etc/kubernetes/admin.conf /root/.kube/config
  chown -R ${DEFAULT_USER}:${DEFAULT_USER} /home/${DEFAULT_USER}/.kube
  kubectl taint nodes --all node-role.kubernetes.io/master-
  kubectl replace -f kube-proxy.yaml
  kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/standalone/heapster-controller.yaml
  kubectl apply -f admin-sa.yaml
  secret=$(kubectl get sa -n kube-system dashboard-sa -o jsonpath='{.secrets[0].name}')
  kubectl get secret $secret -n kube-system -o jsonpath='{.data.token}' | base64 --decode > dashboard-token
  kubectl apply -f studentbook/deploy
  kubectl delete po -n kube-system -l k8s-app=kube-proxy
  kubectl delete po -n kube-system -l name=weave-net
else # Set up Node
  kubeadm join --token ${TOKEN} ${MASTER_IP}:6443
  mkdir -p /home/${DEFAULT_USER}/.kube
  cp ${SHARED_DIR}/kubeconfig /home/${DEFAULT_USER}/.kube/config  # Copy kubeconfig to host
  chown -R ${DEFAULT_USER}:${DEFAULT_USER} /home/${DEFAULT_USER}/.kube
fi
