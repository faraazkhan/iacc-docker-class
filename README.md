# Installation

## Using Vagrant (Recommended)

### Prerequisites:

* Ensure Oracle VirtualBox is installed: https://www.virtualbox.org/wiki/Downloads
* Ensure Vagrant is installed and correctly configured: https://www.vagrantup.com/downloads.html
* Ensure Vagrant vb-guest plugin is installed: `vagrant plugin install
  vagrant-vbguest`

### Instructions

* Clone this project: `git clone
  git@github.com:faraazkhan/iacc-docker-class.git`

```
cd iacc-docker-class
vagrant up
```

### Verification

SSH into the vagrant box and verify docker engine is available

```
vagrant ssh
docker run hello-world
```

## Without Vagrant

Install a Ubuntu 16.04 VM using your preferred mechanism.

SSH into the VM (ensure you have root/sudo access).

Then run

```
curl
https://raw.githubusercontent.com/faraazkhan/iacc-docker-class/master/build.sh
| sudo bash
```

Log out of the VM, and log back in, then verify your installation with:

`docker run hello-world`
