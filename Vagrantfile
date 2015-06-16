# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider :virtualbox do |vb|
    vb.name = "noraneko"
  end
  config.vm.hostname = "noraneko"

  config.vm.box = "debian-8.0.0-amd64"
  config.vm.box_url = "https://github.com/holms/vagrant-jessie-box/releases/download/Jessie-v0.1/Debian-jessie-amd64-netboot.box"
  config.vm.network :private_network, ip: "192.168.33.10"

  config.vm.provision :itamae do |conf|
    conf.sudo = true
    conf.recipes = [
      './recipes/init_server.rb',
      './recipes/wordpress.rb'
    ]
    conf.json = "./nodes/node.json"
  end
end
