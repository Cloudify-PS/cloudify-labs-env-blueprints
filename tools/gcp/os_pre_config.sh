#!/bin/bash

sudo sed -i "/enabled=1/c\enabled=0" /etc/yum.repos.d/google-cloud.repo

sudo yum install -y yum-utils
sudo yum-config-manager --disable epel

sudo yum install -y  vim git tmux

sudo sed -i -e 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

sudo mkdir /root/.ssh
sudo chmod 700 /root/.ssh

cat << EOB | sudo tee /etc/dhcp/dhclient.d/google_hostname.sh
#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

google_hostname_config() {
  google_set_hostname
  hostname="oib.cloudify.labs"
  echo \$hostname > /etc/hostname
  hostname \$hostname
}
google_hostname_restore() {
  :
}
EOB

git clone https://github.com/Cloudify-PS/cloudify-labs-env-blueprints.git

sudo reboot
