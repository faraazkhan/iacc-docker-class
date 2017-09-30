# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.provision "shell", path: "provision.sh"
  config.vm.box = "ubuntu/xenial64"
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 2
  end
  config.vm.define "master", primary: true  do |master|
    master.vm.network "private_network", ip: "10.1.0.4"
    master.vm.hostname = "master"
  end
  config.vm.define "node0" do |node0|
    node0.vm.network "private_network", ip: "10.1.0.254"
    node0.vm.hostname = "node0"
  end
end
