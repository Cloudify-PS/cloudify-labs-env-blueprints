#!/usr/bin/env bash

NAME=$(ctx deployment id)
SCRIPT_PATH=$(ctx download-resource "scripts/update_name.py")
HTML_PATH=$(ctx download-resource "config/index_analytics.html")

sudo mv ${HTML_PATH} /opt/cloudify-stage/dist/index.html
sudo python ${SCRIPT_PATH} ${NAME}