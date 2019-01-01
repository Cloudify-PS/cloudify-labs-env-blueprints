#!/bin/bash

#  Install current plugins bundle.
sudo -u centos  cfy plugins bundle-upload >> /tmp/cfy_status.txt 2>&1

sudo -u centos  cfy plugins upload \
    "http://repository.cloudifysource.org/cloudify/wagons/cloudify-dblb/0.2/cloudify_dblb-0.2-py27-none-linux_x86_64-centos-Core.wgn" \
    -y "http://www.getcloudify.org/spec/dblb/0.2/plugin.yaml"  >> /tmp/cfy_status.txt 2>&1


# Put AWS Network Blueprint before uploading the AWS DB and LB.
sudo -u centos  cfy blueprints upload -n update-blueprint.yaml \
    -b "aws-example-network" \
    "https://github.com/cloudify-examples/aws-example-network/archive/4.5.zip" >> /tmp/cfy_status.txt 2>&1

# Wait for all system workflows to be compleated
while [ "`sudo -u centos cfy executions list  --include-system-workflows | grep  "install_plugin" | grep -v compleated`" == "" ]; do sleep 1 ;echo sleeping ; done

# Install base example environment.
sudo -u centos  cfy install \
    --timeout 1800 \
    -n blueprint.yaml \
    -b "e2e" \
    "https://github.com/Cloudify-PS/e2e-deployment/archive/v7.zip" >> /tmp/cfy_status.txt 2>&1 &

# Add AWS DB Blueprint
sudo -u centos  cfy blueprints upload -n aws.yaml \
    -b "db-aws" \
    "https://github.com/cloudify-examples/mariadb-blueprint/archive/4.5.zip" >> /tmp/cfy_status.txt 2>&1 &

# Add AWS LB Blueprint
sudo -u centos  cfy blueprints upload -n aws.yaml \
    -b "lb-aws" \
    "https://github.com/cloudify-examples/haproxy-blueprint/archive/4.5.zip" >> /tmp/cfy_status.txt 2>&1 &
