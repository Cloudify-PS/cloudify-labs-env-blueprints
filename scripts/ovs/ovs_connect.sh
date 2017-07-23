#!/bin/bash


bridge=$(ctx ${direction} node properties resource_id)
interface_counter=$(ctx ${direction} instance runtime_properties gre_interface_counter)
remote_ip=$(ctx ${rdirection} instance host_ip)


interface_counter=$((interface_counter+1))

ctx ${direction} instance runtime_properties gre_interface_counter ${interface_counter}

interface=gre${interface_counter}

ctx logger info "Connecting  bridge:${bridge} interface:${interface} to:${remote_ip}"

sudo ovs-vsctl add-port ${bridge} ${interface}  -- set interface ${interface} type=gre options:remote_ip=${remote_ip}

sudo bash -c echo "'ovs-vsctl add-port ${bridge} ${interface}  -- set interface ${interface} type=gre options:remote_ip=${remote_ip}' >> /etc/rc.local"
