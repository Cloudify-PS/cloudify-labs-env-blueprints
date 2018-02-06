#!/bin/sh

REMOTEKEY=$(ctx download-resource "certs/oib")
SERVICE_DEF=$(ctx download-resource "components/CentOS7/config/sshportfwd.service")

sudo cp $REMOTEKEY /root/remote.rsa
sudo chmod 600 /root/remote.rsa
sudo rm $REMOTEKEY

sudo cp  $SERVICE_DEF /usr/lib/systemd/system/sshportfwd.service
