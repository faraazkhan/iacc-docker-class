# Installation

## Using Vagrant (Recommended)

### Prerequisites:

* Ensure Oracle VirtualBox is installed: https://www.virtualbox.org/wiki/Downloads
* Ensure Vagrant is installed and correctly configured: https://www.vagrantup.com/downloads.html
* Ensure Vagrant vb-guest plugin is installed: `vagrant plugin install
  vagrant-vbguest`

### Instructions

Video:

[![asciicast](https://asciinema.org/a/o3TGQ8U09nv5NnwhWp5WkLGxc.png)](https://asciinema.org/a/o3TGQ8U09nv5NnwhWp5WkLGxc)

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

Install two Ubuntu 16.04 VMs using your preferred mechanism.

Then follow instructions below for each VM.

Video:

[![asciicast](https://asciinema.org/a/HySLvDdZ6HvHw3scRuaCAZFTj.png)](https://asciinema.org/a/HySLvDdZ6HvHw3scRuaCAZFTj)

SSH into the VM (ensure you have root/sudo access).

Then run

```
curl https://raw.githubusercontent.com/faraazkhan/iacc-docker-class/master/provision.sh | sudo bash
```

Log out of the VM, and log back in, then verify your installation with:

`docker run hello-world`
