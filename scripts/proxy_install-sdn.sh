#!/bin/sh
. $(ctx download-resource "utils/utils")

ctx instance runtime-properties public_ip $public_ip

sudo setenforce 0

#ctx download-resource-and-render "config/10-proxy.conf" "/etc/httpd/conf.d/10-proxy.conf"

deploy_blueprint_resource "config/10-proxy-sdn.conf"  "/etc/httpd/conf.d/10-proxy.conf"

sudo chown root:root /etc/httpd/conf.d/10-proxy.conf
