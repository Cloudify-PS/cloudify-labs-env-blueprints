#!/bin/bash

use_external_resource=$(ctx node properties use_external_resource)

if [ "$use_external_resource" != "True" ]; then

#sudo yum -y install https://repos.fedorapeople.org/repos/openstack/EOL/openstack-kilo/rdo-release-kilo-2.noarch.rpm
#
# Use okata openstack repo to install openvswitch
sudo yum -y install https://repos.fedorapeople.org/repos/openstack/openstack-ocata/rdo-release-ocata-3.noarch.rpm

sudo yum -y install openvswitch


else

ctx logger info "Using exsisting resource_id: $name, skipping installation"


fi
