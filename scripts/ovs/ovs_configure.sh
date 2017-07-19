#!/bin/bash

use_external_resource=$(ctx node properties use_external_resource)

name=$(ctx node properties resource_id )

netmask=$(ctx node properties netmask )

ipaddr=$(ctx node properties ipaddr )


if [ "$use_external_resource" = "False" ]; then


ctx logger info "Configuring Bridge $name "

cat <<EOF > /tmp/ifcfg-${name}
DEVICE=${name}
DEVICETYPE=ovs
TYPE=OVSBridge
BOOTPROTO=static
IPADDR=${ipaddr}
NETMASK=${netmask}
ONBOOT=yes
EOF

ctx logger info "Creating ifcfg "

sudo cp /tmp/ifcfg-${name}/etc/sysconfig/network-scripts/

ctx logger info "Bringing up bridge"

sudo ifup ${name}



else

ctx logger info "Using exsisting resource_id: $name - $use_external_resource  skipping ovs configuration"

fi

ctx instance runtime_properties gre_interface_counter 0

ctx logger info "Setting gre_interface_counter runtime to 0 "
