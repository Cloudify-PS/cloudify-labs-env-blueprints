#!/usr/bin/env bash

NAME=$(ctx deployment id)
SCRIPT_PATH=$(ctx download-resource "components/CFYManager4x/update_name.py")
HTML_PATH=$(ctx download-resource "components/CFYManager4x/config/index_analytics.html")

sudo python ${SCRIPT_PATH} ${NAME}
