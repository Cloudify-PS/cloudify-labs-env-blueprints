#!/usr/bin/env bash

NAME=$(ctx deployment id)


SCRIPT_PATH=$(ctx download-resource "scripts/update_name.py")
KEY=$(ctx download-resource "config/oib_cloudify_lab.pem")
HTML_PATH=$(ctx download-resource "config/index.html")


sudo cp ${KEY} /home/cloudify/.ssh/cloudify-manager-kp.pem
sudo chmod 600 /home/cloudify/.ssh/cloudify-manager-kp.pem

sudo scp -i /home/cloudify/.ssh/cloudify-manager-kp.pem ${HTML_PATH} centos@172.25.1.18:/home/centos/index.html
sudo ssh -i /home/cloudify/.ssh/cloudify-manager-kp.pem centos@172.25.1.18 "sudo mv /home/centos/index.html /opt/cloudify-stage/dist/index.html"

sudo scp -i /home/cloudify/.ssh/cloudify-manager-kp.pem ${SCRIPT_PATH} centos@172.25.1.18:/home/centos/update_name.py

sudo ssh -i /home/cloudify/.ssh/cloudify-manager-kp.pem centos@172.25.1.18 "sudo python /home/centos/update_name.py ${NAME}"