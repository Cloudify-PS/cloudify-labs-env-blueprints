#!/bin/bash

UPDATE_CERT_MD_SCRIPT=$(ctx download-resource "components/CFYManager4x/scripts/update_cert_metadata.py")
PUBLIC_IP=$public_ip
PRIVATE_IP=$private_ip

sudo chmod +x $UPDATE_CERT_MD_SCRIPT
sudo cp /etc/cloudify/ssl/certificate_metadata /etc/cloudify/ssl/certificate_metadata.old
sudo sh -c "cat /etc/cloudify/ssl/certificate_metadata.old | $UPDATE_CERT_MD_SCRIPT external $PUBLIC_IP  > /etc/cloudify/ssl/certificate_metadata"

sudo /opt/manager/env/bin/python /opt/cloudify/manager-ip-setter/update-provider-context.py --networks /etc/cloudify/ssl/certificate_metadata $PRIVATE_IP

sudo rm /opt/cloudify/manager-ip-setter/touched

sudo /opt/cloudify/manager-ip-setter/manager-ip-setter.sh

sudo systemctl restart nginx
sudo systemctl restart cloudify-rabbitmq
