#!/usr/bin/env bash

SCRIPT_PATH=$(ctx download-resource "scripts/mng41/install_guides.py")

sudo python ${SCRIPT_PATH}
