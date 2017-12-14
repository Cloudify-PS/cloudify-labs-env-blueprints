#!/bin/sh

ctx instance runtime-properties public_ip $public_ip

sudo mkdir -p "/var/www/html/vpn"

sudo chmod  777 "/var/www/html/vpn"

ctx download-resource-and-render "components/VPN/config/client.ovpn"  "/var/www/html/vpn/client.ovpn"
