#!/bin/bash

source keystonerc_admin

curl https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1802.qcow2 -o CentOS-7-x86_64-GenericCloud-1802.qcow2

openstack image create --disk-format qcow2 --file CentOS-7-x86_64-GenericCloud-1802.qcow2 CentOS-7-x86_64-GenericCloud-1802

openstack keypair create test-key > test-key.pem

openstack network create test

openstack subnet create test-s \
  --network test \
  --subnet-range 192.168.200.0/24 \
  --dhcp --gateway 192.168.200.1 \
  --allocation-pool start=192.168.200.100,end=192.168.200.200 \
  --dns-nameserver 8.8.8.8

openstack router add subnet router test-s

openstack security group create allow-all

openstack security group rule create \
  --remote-ip 0.0.0.0/0 \
  --proto tcp \
  --dst-port 1:65535 \
  allow-all
  
openstack security group rule create \
  --remote-ip 0.0.0.0/0 \
  --proto udp \
  --dst-port 1:65535 \
  allow-all

openstack security group rule create \
  --proto icmp \
  allow-all

openstack server create \
  --flavor m1.small  \
  --image CentOS-7-x86_64-GenericCloud-1802 \
  --key-name test-key \
  --security-group allow-all \
  --nic net-id=test \
  server-test
