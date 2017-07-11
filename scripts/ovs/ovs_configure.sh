#!/bin/bash


cat <<EOF > /tmp/ifcfg-${name}
DEVICE=${name}
DEVICETYPE=ovs
TYPE=OVSBridge
BOOTPROTO=static
IPADDR=${ipaddr}
NETMASK=${netmask}
GATEWAY=${gateway}
DNS1=${dnssrv}
ONBOOT=yes
EOF

sudo cp  /tmp/ifcfg-${name}/etc/sysconfig/network-scripts/
