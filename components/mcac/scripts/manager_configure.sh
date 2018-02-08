#!/bin/bash


env -i cfy plugins upload "https://github.com/EarthmanT/cloudify-dblb/releases/download/0.2/cloudify_dblb-0.2-py27-none-linux_x86_64-centos-Core.wgn" >> /tmp/cfy_status.txt 2>&1


env -i cfy blueprints upload -n simple-blueprint.yaml -b "Network-Openstack-Bluperint"  "https://github.com/cloudify-examples/openstack-example-network/archive/master.zip"  >> /tmp/cfy_status.txt 2>&1
env -i cfy blueprints upload -n update-blueprint.yaml -b "Network-AWS-Bluperint"        "https://github.com/cloudify-examples/aws-example-network/archive/master.zip"  >> /tmp/cfy_status.txt 2>&1
env -i cfy blueprints upload -n aws.yaml              -b "MAriadb-AWS-Bluperint"        "https://github.com/cloudify-examples/mariadb-blueprint/archive/master.zip"  >> /tmp/cfy_status.txt 2>&1
env -i cfy blueprints upload -n aws.yaml              -b "HAProxy-AWS-Bluperint"        "https://github.com/cloudify-examples/haproxy-blueprint/archive/master.zip"  >> /tmp/cfy_status.txt 2>&1
env -i cfy blueprints upload -n openstack.yaml        -b "Dreupal-Openstack-Bluperint"  "https://github.com/cloudify-examples/drupal-blueprint/archive/master.zip"  >> /tmp/cfy_status.txt 2>&1
env -i cfy blueprints upload -n blueprint.yaml        -b "Database-Loaf-Balancer-Bluperint"  "https://github.com/EarthmanT/db-lb-app/archive/master.zip"  >> /tmp/cfy_status.txt 2>&1
