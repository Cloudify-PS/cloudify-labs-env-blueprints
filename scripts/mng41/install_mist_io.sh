#!/usr/bin/env bash

sudo mkdir -p ~/mist
cd ~/mist

git clone --depth 1 --single-branch --branch v1.1.0 https://gitlab.ops.mist.io/mistio/amqp-middleware-blueprints
cd amqp-middleware-blueprints

INPUTS=$(ctx download-resource "config/mist_imputs.yaml")

sudo mv ${INPUTS} inputs/local-blueprint-inputs.yaml

cfy local init -p local-blueprint.yaml -i inputs/local-blueprint-inputs.yaml
cfy local execute -w install

cfy local outputs
