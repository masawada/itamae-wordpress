itamae-wordpress
================

# Vagrant
## requirements
* Vagrant
* VirtualBox

## Install Vagrant
[download](https://www.vagrantup.com/downloads.html) and install the package.

## Install VirtualBox
```
$ brew cask install virtualbox
```

## initialize
It you've not installed `vagrant-vbguest` or `vagrant-itamae`, install them.
```
$ vagrant plugin install vagrant-vbguest
$ vagrant plugin install vagrant-itamae
```

## start server
```
$ vagrant up
```

## reload
```
$ vagrant reload
```

## stop server
```
$ vagrant halt
```

## destroy server
```
$ vagrant destroy
```

# Deploy to VPS
## Requirements
* Debian or Ubuntu
* Non configured

```
$ bundle exec install --path vendor/bundle
$ bundle exec itamae ssh -h hostname -j nodes/node.json recipes/init_server.rb
$ bundle exec itamae ssh -h hostname -j nodes/node.json recipes/wordpress.rb
```
