#!/bin/bash

REPO=$plugins_repo



# install build
ctx logger info "Installing packages"
sudo yum -y install gcc python-devel wget python-netaddr

sudo sh -c "source /opt/mgmtworker/env/bin/activate ; pip install netaddr"

# configure route, now and permanently
ctx logger info "Setting Static routes"
sudo route add -net 192.168.113.0/24 gw 10.10.25.253
sudo /bin/bash -c "echo '192.168.113.0/24 via 10.10.25.253 dev br-ovs' >> /etc/sysconfig/network"
sudo route add -net 172.25.1.0/24 gw 10.10.25.253
sudo /bin/bash -c "echo '172.25.1.0/24 via 10.10.25.253 dev br-ovs' >> /etc/sysconfig/network"

sudo systemctl restart cloudify-stage
sudo systemctl restart cloudify-restservice

#handle licence
sudo -u centos curl $licence  -o /tmp/cfy_licence
sudo -u centos cfy license upload /tmp/cfy_licence
sudo -u centos rm /tmp/cfy_licence


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
sudo mv $training_pub "/etc/cloudify/cfy-training.rsa.pub"
sudo mv $training_pem "/etc/cloudify/cfy-training.pem"
sudo chown cfyuser:cfyuser /etc/cloudify/cfy-training*
sudo chmod 600 /etc/cloudify/cfy-training*
sudo cat /etc/cloudify/cfy-training.rsa.pub >> /home/centos/.ssh/authorized_keys


# Add manager key to authorized_keys for centos user
sudo cat /etc/cloudify/.ssh/cfy-agent-kp.pub >> /home/centos/.ssh/authorized_keys

sudo -u centos cfy status >> /tmp/cfy_status.txt 2>&1 &

ctx logger info "checking for file server to be up"
#while ! wget --no-check-certificate https://localhost:53333/ > /dev/null 2>&1 ;  do  ctx logger info "Waiting file server..." ; sleep 1; done

# create secrets
ctx logger info "Creating Secrests"
sudo -u centos cfy secret create ubuntu_trusty_image -s 05bb3a46-ca32-4032-bedd-8d7ebd5c8100 >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create centos_core_image -s aee5438f-1c7c-497f-a11e-53360241cf0f >> /tmp/cfy_status.txt 2>&1 &

sudo -u centos cfy secret create small_image_flavor -s 4d798e17-3439-42e1-ad22-fb956ec22b54 >> /tmp/cfy_status.txt 2>&1 &
#cfy secret create medium_image_flavor -s 62ed898b-0871-481a-9bb4-ac5f81263b33
sudo -u centos cfy secret create medium_image_flavor -s 3 >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create large_image_flavor -s 62ed898b-0871-481a-9bb4-ac5f81263b33 >> /tmp/cfy_status.txt 2>&1 &

sudo -u centos cfy secret create keystone_username -s admin >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create keystone_password -s 'cloudify1234' >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create keystone_tenant_name -s admin >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create keystone_url -s http://10.10.25.1:5000/v2.0 >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create region -s RegionOne >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create keystone_region -s RegionOne >> /tmp/cfy_status.txt 2>&1 &

sudo -u centos cfy secret create openstack_auth_url -s http://10.10.25.1:5000/v3   >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create openstack_tenant_name -s admin >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create openstack_username -s admin  >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create openstack_password -s 'cloudify1234' >> /tmp/cfy_status.txt 2>&1 &

#sudo -u centos cfy secret create agent_key_private -s /etc/cloudify/.ssh/cfy-agent-kp > /tmp/cfy_status.txt 2>&1

# Create private_key as plain secret
sudo -u centos cfy secret create agent_key_private --secret-file /etc/cloudify/.ssh/cfy-agent-kp.cp >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create agent_key_public --secret-file /etc/cloudify/.ssh/cfy-agent-kp.pub >> /tmp/cfy_status.txt 2>&1 &

sudo -u centos cfy secret create private_subnet_name -s provider_subnet >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create private_network_name -s provider >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create public_subnet_name -s  private_subnet >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create public_network_name -s private_network >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create router_name -s router1 >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create external_network_name -s external_network >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create external_network_id -s 1ceb37e5-f8ee-4192-80c5-433ec52bbcad >> /tmp/cfy_status.txt 2>&1 &



ctx logger info "Creating k8s Secrests"
sudo -u centos cfy secret create kubernetes_master_ip -s X >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create kubernetes_certificate_authority_data -s X >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create kubernetes_master_port -s X >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create kubernetes-admin_client_key_data -s X >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secret create kubernetes-admin_client_certificate_data -s X >> /tmp/cfy_status.txt 2>&1  &

sudo -u centos cfy secrets create cfy_user -s admin >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secrets create cfy_password -s admin >> /tmp/cfy_status.txt 2>&1 &
sudo -u centos cfy secrets create cfy_tenant -s default_tenant >> /tmp/cfy_status.txt 2>&1 &



ctx logger info "Uploading Plugins Bundle"
sudo -u centos cfy plugins  bundle-upload -p "$plugins" >> /tmp/cfy_status.txt 2>&1



ctx logger info "Checking for plugin executions"
#while cfy executions list --include-system-workflows | grep  install_plugin | grep -v -e failed  -e completed > /dev/null; do  ctx logger info "Waiting for all workflows to finish..." ; sleep 1; done

ctx logger info "Uploading Openstack Network Blueprint"

sudo -u centos cfy blueprints upload -n openstack-example-network.yaml -b "openstack-example-network"  "https://storage.googleapis.com/cfylabspub/openstack-example-network-5.0.tar.gz"  >> /tmp/cfy_status.txt 2>&1

ctx logger info "Creating Openstack Network Deployment"
sudo -u centos cfy deployments create -b "openstack-example-network"  "openstack-example-network" -i "external_network_name=external_network"  >> /tmp/cfy_status.txt 2>&1



ctx logger info "Installing Openstack Network Deployment"
sudo -u centos cfy executions start install -d "openstack-example-network"  >> /tmp/cfy_status.txt 2>&1


ctx logger info "Script Ends"
