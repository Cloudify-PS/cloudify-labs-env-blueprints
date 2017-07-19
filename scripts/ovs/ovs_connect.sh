#!/bin/bash


bridge=$(ctx ${direction} instance runtime_properties bridge)
interface_counter=$(ctx ${direction} instance runtime_properties gre_interface_counter)
remote_ip=$(ctx ${rdirection} instance runtime_properties host_ip)


interface_counter=$((interface_counter+1))

ctx ${direction} instance runtime_properties gre_interface_counter ${interface_counter}

interface=gre${interface_counter}

sudo ovs-vsctl add-port ${bridge} ${interface}  --set interface ${interface} type=gre options:${remote_ip}
