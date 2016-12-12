#!/bin/sh

. $(ctx download-resource "utils/utils")

ctx instance runtime-properties public_ip $public_ip

sudo mkdir -p "/var/www/html/vpn"

deploy_blueprint_resource "config/client.ovpn"  "/var/www/html/vpn/client.ovpn"