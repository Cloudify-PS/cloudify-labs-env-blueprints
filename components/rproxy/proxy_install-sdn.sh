#!/bin/sh

ctx instance runtime-properties public_ip $public_ip

sudo setenforce 0

sudo touch /etc/httpd/conf.d/10-proxy.conf

sudo chown centos:centos /etc/httpd/conf.d/10-proxy.conf

ctx download-resource-and-render "components/rproxy/config/10-proxy-sdn.conf"  "/etc/httpd/conf.d/10-proxy.conf"

sudo chown root:root /etc/httpd/conf.d/10-proxy.conf
