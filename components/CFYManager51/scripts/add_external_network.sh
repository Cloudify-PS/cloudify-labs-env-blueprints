#!/bin/bash

PUBLIC_IP=$public_ip
PRIVATE_IP=$private_ip

cfy_manager add-networks --networks "{\"external\": \"${PUBLIC_IP}\"}"

sudo systemctl restart cloudify-mgmtworker

sudo systemctl restart nginx

sudo systemctl restart cloudify-rabbitmq
