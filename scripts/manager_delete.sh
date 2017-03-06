#!/bin/bash

 nova delete cloudify-manager-server

 neutron port-delete cloudify-manager-por

 openstack security group delete cloudify-sg-manager

 openstack security group delete cloudify-sg-agents

 neutron router-interface-delete cloudify-management-router cloudify-management-network-subnet


neutron router-delete cloudify-management-router

openstack network delete cloudify-management-network

openstack keypair delete agent-key

openstack keypair delete manager-key


