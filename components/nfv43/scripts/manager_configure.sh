#!/bin/bash

# Install the webserve
####
env -i cfy blueprints upload -n openstack-vm-blueprint-ws.yaml -b "private-webserver-bp" https://github.com/Cloudify-PS/private-webserver-blueprint/archive/master.zip >> /tmp/cfy_status.txt 2>&1
env -i cfy deployments create -b "private-webserver-bp" private-webserver >> /tmp/cfy_status.txt 2>&1
env -i cfy executions start install -d "private-webserver"  >> /tmp/cfy_status.txt 2>&1 &

# Upload blueprints
###
env -i cfy blueprints upload -n fortigate-vnf.yaml     -b "fortigate-vnf-bp"                     https://github.com/Cloudify-PS/nfv-scenario-blueprint/archive/master.zip >> /tmp/cfy_status.txt 2>&1
env -i cfy blueprints upload -n openstack-vm-lan.yaml  -b "openstack-vnf-infra"  https://github.com/Cloudify-PS/nfv-scenario-blueprint/archive/master.zip >> /tmp/cfy_status.txt 2>&1
env -i cfy blueprints upload -n fortigate-vnf-portforward-bp.yaml -b "fortigate-portforward-bp" https://github.com/Cloudify-PS/nfv-scenario-blueprint/archive/master.zip >> /tmp/cfy_status.txt 2>&1

# Create Deployments for Stage1
######
env -i cfy deployments create -b "openstack-vnf-infra" sample-openstack-vnf-infra -i 'vnf_name=sample;image_url=https://s3-eu-west-1.amazonaws.com/cloudify-labs/images/FG562-DZ.img;vnf_config_port=22' >> /tmp/cfy_status.txt 2>&1

# Create deployments for Stage2&3
#####
env -i cfy deployments create -b "fortigate-vnf-bp" fortigate-vnf >> /tmp/cfy_status.txt 2>&1
env -i cfy deployments create -b "fortigate-portforward-bp" fortigate-portforward >> /tmp/cfy_status.txt 2>&1
