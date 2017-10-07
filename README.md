# Installation

## Using Vagrant (Recommended)

### Prerequisites:

* Ensure Oracle VirtualBox is installed: https://www.virtualbox.org/wiki/Downloads
* Ensure Vagrant is installed and correctly configured: https://www.vagrantup.com/downloads.html
* Ensure Vagrant vb-guest plugin is installed: `vagrant plugin install
  vagrant-vbguest`
* Ensure latest kubectl is installed on your host: https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl

### Instructions

Video:

[![asciicast](https://asciinema.org/a/o3TGQ8U09nv5NnwhWp5WkLGxc.png)](https://asciinema.org/a/4wL2mMh22qSWsHPsDdBZAopkC)

Text:

```
git clone git@github.com:faraazkhan/iacc-docker-class.git
cd iacc-docker-class
vagrant up
```

### Verification

SSH into each vagrant box and verify docker engine is available

```
vagrant ssh master
docker run hello-world
exit
```

```
vagrant ssh node0
docker run hello-world
exit
```

### Update / Recreate

_***The instructions below will delete anything deployed to the K8S
cluster and also any data you have on the virual machines__***

_If you have run a previous version of this repo and would like to
upgrade (including getting latest from the repo), or just want to
recreate your vms from scratch simply run:

```
cd iacc-docker-class
./update.sh
```

### Accessing Kubernetes

The set up in this repo allows Kubernetes to be accessed from three
locations:

* Your Host OS
* The Master Node
* The Worker Node

The kubernetes configuration is automatically copied to all three
location to facilitate this. The master node and the worker node also
have kubectl installed.

You can access the cluster via kubectl from those nodes as follows:

```
vagrant ssh master
kubectl get no
```

```
vagrant ssh node0
kubectl get no
```

To access the cluster from the Host OS, you must install kubectl. See
official instructions for your OS here: https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl

Once kubectl is installed, you can access the cluster from your Host OS
as follows:

```
cd iacc-docker-class
export KUBECONFIG=kubeconfig
kubectl get no
```

### Demo Application

This repo includes a simple Ruby on Rails application with appropriate
Dockerfile, docker-compose.yaml (for local runs) and kubernetes
manifests.

To run the application locally using docker-compose, simply run:

```
docker-compose up -d # This starts the application and its dependencies
in the background
```

The deploy the application to your Kubernetes cluster (with all
dependencies), simply run:

```
kubectl apply -f deploy/
```

To access the application, start kubectl proxy like this:
in your browser:

```
kubectl proxy &
```
and visit the URL below:

http://localhost:8001/api/v1/namespaces/default/services/studentbook:http/proxy/

### Kubernetes Dashboard

The kubernetes dashboard is always deployed automatically in this set
up. You can access the cluster using kubectl proxy. An admin service
account is created for you, giving you full access to the cluster via
the dashboard. The token for the admin sa will be available in a file
called: `dashboard-token`. To access the dashboard start kubectl proxy,
if it isn't already running, like this:

```
kubectl proxy &
```

Then visit this URL in your browser:

http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

When prompted to log in, select the `Token` option and enter the token
in the `dashboard-token` file.

## Without Vagrant

Install two Ubuntu 16.04 VMs using your preferred mechanism.

Then follow instructions below for each VM.

Video:

[![asciicast](https://asciinema.org/a/HySLvDdZ6HvHw3scRuaCAZFTj.png)](https://asciinema.org/a/HySLvDdZ6HvHw3scRuaCAZFTj)

SSH into the VM (ensure you have root/sudo access).

Then download the provision script as follows:

```
curl https://raw.githubusercontent.com/faraazkhan/iacc-docker-class/master/provision.sh > provision.sh
```

Then modify the environment variables on top of the script

```
TOKEN # The Kubeadm token, does not need to be modified
ADDRESS # Dynamically populated, no need to modify
MASTER_IP # Set this to the IP of your master node
DEFAULT_USER # The default user for your virtual machine (example:
ubuntu, vagrant)
SHARED_DIR # The directory set up as shared dir between your VM and host
MASTER_HOSTNAME # The hostname of your master node
```

Once you have made the appropriate modifications, you can run the script
as follows:

```
sudo bash provision.sh
```

Log out of the VM, and log back in, then verify your installation with:

`docker run hello-world`

