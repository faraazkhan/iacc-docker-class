# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.provision "shell", path: "provision.sh"
  config.vm.define "master", primary: true  do |master|
    master.vm.box = "bento/ubuntu-16.04"
    master.vm.network "private_network", ip: "10.1.0.4"
  end
  config.vm.define "node0" do |node0|
    node0.vm.box = "bento/ubuntu-16.04"
    node0.vm.network "private_network", ip: "10.1.0.254"
  end
end
