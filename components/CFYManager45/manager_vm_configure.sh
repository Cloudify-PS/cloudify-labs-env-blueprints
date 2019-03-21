#!/bin/bash

REPO=$plugins_repo




# install build
ctx logger info "Installing packages"
sudo yum -y install gcc python-devel wget

# configure route, now and permanently
#ctx logger info "Setting Static routes"
#sudo route add -net 192.168.113.0/24 gw 10.10.25.253
#sudo /bin/bash -c "echo '192.168.113.0/24 via 10.10.25.253 dev br-ovs' >> /etc/sysconfig/network"
#sudo route add -net 172.25.1.0/24 gw 10.10.25.253
#sudo /bin/bash -c "echo '172.25.1.0/24 via 10.10.25.253 dev br-ovs' >> /etc/sysconfig/network"

sudo systemctl restart cloudify-stage
sudo systemctl restart cloudify-restservice


# generate Key
ctx logger info "Generating Keys"
sudo mkdir -p /etc/cloudify/.ssh/
sudo ssh-keygen -f /etc/cloudify/.ssh/cfy-agent-kp -N ""
sudo cp /etc/cloudify/.ssh/cfy-agent-kp /etc/cloudify/.ssh/cfy-agent-kp.cp
sudo chmod 644 /etc/cloudify/.ssh/cfy-agent-kp.cp
sudo chown cfyuser:cfyuser -R /etc/cloudify/.ssh
public_key=$(sudo cat /etc/cloudify/.ssh/cfy-agent-kp.pub)

# add training key
training_pem=$(ctx download-resource "certs/training_vm/training.pem")
training_pub=$(ctx download-resource "certs/training_vm/training.rsa.pub")
sudo cp $training_pub "/etc/cloudify/cfy-training.rsa.pub"
sudo cp $training_pem "/etc/cloudify/cfy-training.pem"
sudo chown cfyuser:cfyuser /etc/cloudify/cfy-training*
sudo chmod 600 /etc/cloudify/cfy-training*
sudo cat /etc/cloudify/cfy-training.rsa.pub >> /home/centos/.ssh/authorized_keys


# Add manager key to authorized_keys for centos user
sudo cat /etc/cloudify/.ssh/cfy-agent-kp.pub >> /home/centos/.ssh/authorized_keys

sudo -u centos cfy status >> /tmp/cfy_status.txt 2>&1 &


# create secrets
ctx logger info "Creating Secrests"


# Create private_key as plain secret
sudo -u centos cfy secret create agent_key_private --secret-file $training_pem >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create agent_key_public --secret-file $training_pub >> /tmp/cfy_status.txt 2>&1 &


ctx logger info "Creating k8s Secrests"


sudo -u centos cfy secrets create k8s_master_ip -s  "${k8s_master_ip}" >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secrets create k8s_node_ip   -s  "${k8s_node_ip}"  >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secrets create k8s_load_ip   -s  "${k8s_load_ip}"  >> /tmp/cfy_status.txt 2>&1 &

ctx logger info "Creating Deplyment Proxy Secrests"
sudo -u centos cfy secrets create cfy_user -s admin >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secrets create cfy_password -s admin >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secrets create cfy_tenant -s default_tenant >> /tmp/cfy_status.txt 2>&1 &


sudo -u centos cfy plugins  bundle-upload >> /tmp/cfy_status.txt 2>&1


ctx logger info "Script Ends"
