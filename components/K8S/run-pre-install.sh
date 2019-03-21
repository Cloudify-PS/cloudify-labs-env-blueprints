#!/bin/bash


SCRIPT_PATH=$(ctx download-resource "components/K8S/pre-install.sh")
chmod 777 $SCRIPT_PATH
sudo $SCRIPT_PATH
