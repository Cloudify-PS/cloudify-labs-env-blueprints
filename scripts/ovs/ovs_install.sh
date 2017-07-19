#!/bin/bash

use_external_resource=$(ctx node properties use_external_resource)

if [ "$use_external_resource" = "False" ]; then

sudo yum -y install https://repos.fedorapeople.org/repos/openstack/EOL/openstack-kilo/rdo-release-kilo-2.noarch.rpm

sudo yum -y install openvswitch


else

ctx logger info "Using exsisting resource_id: $name, skipping installation"


fi
