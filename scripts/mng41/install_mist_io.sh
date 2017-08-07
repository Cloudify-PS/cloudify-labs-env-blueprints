#!/usr/bin/env bash

sudo yum install git -y

mkdir -p ~/mist
cd ~/mist

git clone --depth 1 --single-branch --branch v1.1.0 https://gitlab.ops.mist.io/mistio/amqp-middleware-blueprints.git

cd amqp-middleware-blueprints

INPUTS=$(ctx download-resource "config/mist_inputs.yaml")

sudo mv ${INPUTS} inputs/local-blueprint-inputs.yaml

cfy install local-blueprint.yaml -i inputs/local-blueprint-inputs.yaml


cfy outputs
