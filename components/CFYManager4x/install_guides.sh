#!/usr/bin/env bash

SCRIPT_PATH=$(ctx download-resource "components/CFYManager4x/install_guides.py")

sudo python ${SCRIPT_PATH}
