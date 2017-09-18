# Installation

## Using Vagrant (Recommended)

### Prerequisites:

* Ensure Oracle VirtualBox is installed: https://www.virtualbox.org/wiki/Downloads
* Ensure Vagrant is installed and correctly configured: https://www.vagrantup.com/downloads.html
* Ensure Vagrant vb-guest plugin is installed: `vagrant plugin install
  vagrant-vbguest`

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

# Update / Recreate

_***The instructions below will delete anything deployed to the K8S
cluster and also any data you have on the virual machines__***

_If you have run a previous version of this repo and would like to
upgrade (including getting latest from the repo), or just want to
recreate your vms from scratch simply run:

```
cd iacc-docker-class
./update.sh
```
