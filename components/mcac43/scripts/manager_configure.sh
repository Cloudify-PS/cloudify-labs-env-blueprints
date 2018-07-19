#!/bin/bash

# Install current plugins bundle.
env -i cfy plugins bundle-upload >> /tmp/cfy_status.txt 2>&1

# Put AWS Network Blueprint before uploading the AWS DB and LB.
env -i cfy blueprints upload -n update-blueprint.yaml \
    -b "aws-example-network" \
    "https://github.com/cloudify-examples/aws-example-network/archive/4.3.2.zip" >> /tmp/cfy_status.txt 2>&1 &

# Install base example environment.
env -i cfy install \
    --timeout 1800 \
    -n blueprint.yaml \
    -b "e2e" \
    "https://github.com/EarthmanT/e2e-deployment/archive/v1.zip" >> /tmp/cfy_status.txt 2>&1 &

# Add AWS DB Blueprint
env -i cfy blueprints upload -n aws.yaml \
    -b "db-aws" \
    "https://github.com/cloudify-examples/mariadb-blueprint/archive/4.3.2.zip" >> /tmp/cfy_status.txt 2>&1 &

# Add AWS LB Blueprint
env -i cfy blueprints upload -n aws.yaml \
    -b "lb-aws" \
    "https://github.com/cloudify-examples/haproxy-blueprint/archive/4.3.2.zip" >> /tmp/cfy_status.txt 2>&1 &
