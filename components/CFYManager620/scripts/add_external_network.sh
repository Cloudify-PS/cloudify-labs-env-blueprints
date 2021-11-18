#!/bin/bash

PUBLIC_IP=$public_ip
PRIVATE_IP=$private_ip

cfy_manager add-networks --networks "{\"external\": \"${PUBLIC_IP}\"}"

sudo supervisorctl restart cloudify-mgmtworker

sudo supervisorctl restart nginx

sudo supervisorctl restart cloudify-rabbitmq
