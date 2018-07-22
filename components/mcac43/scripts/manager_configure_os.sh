#!/bin/bash

# Install latest plugins.
env -i cfy plugins bundle-upload >> /tmp/cfy_status.txt 2>&1

# Put AWS Network Blueprint before uploading the AWS DB and LB.
env -i cfy blueprints upload -n update-blueprint.yaml \
    -b "aws-example-network" \
    "https://github.com/cloudify-examples/aws-example-network/archive/4.3.2.zip" >> /tmp/cfy_status.txt 2>&1 &

# Install base example environment.
env -i cfy install --timeout 1800 \
    -n blueprint.yaml \
    -b "e2e" \
    "https://github.com/EarthmanT/e2e-deployment/archive/v1.zip" >> /tmp/cfy_status.txt 2>&1 &
