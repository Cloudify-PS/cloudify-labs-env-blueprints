#!/bin/bash

sudo yum install -y yum-utils
sudo yum-config-manager --disable epel

sudo yum install -y  vim git tmux

sudo sed -i -e 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

sudo mkdir /root/.ssh
sudo chmod 700 /root/.ssh

git clone https://github.com/Cloudify-PS/cloudify-labs-env-blueprints.git

sudo reboot