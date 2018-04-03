#!/bin/bash


env -i cfy plugins  bundle-upload -p https://storage.reading-a.openstack.memset.com:8080/swift/v1/ca0c4540c8f84ad3917c40b432a49df8/PluginsMD/mcac-cloudify-plugins-bundel.tar.gz >> /tmp/cfy_status.txt 2>&1


env -i cfy blueprints upload -n update-blueprint.yaml -b "aws-example-network"        "https://github.com/cloudify-examples/aws-example-network/archive/master.zip"  >> /tmp/cfy_status.txt 2>&1 &
env -i cfy blueprints upload -n openstack.yaml        -b "db"        "https://github.com/cloudify-examples/mariadb-blueprint/archive/master.zip"  >> /tmp/cfy_status.txt 2>&1 &
env -i cfy blueprints upload -n openstack.yaml        -b "lb"        "https://github.com/cloudify-examples/haproxy-blueprint/archive/master.zip"  >> /tmp/cfy_status.txt 2>&1 &
env -i cfy blueprints upload -n openstack.yaml        -b "drupal"         "https://github.com/cloudify-examples/drupal-blueprint/archive/master.zip"  >> /tmp/cfy_status.txt 2>&1 &
env -i cfy blueprints upload -n blueprint.yaml        -b "db-lb-app"                "https://github.com/EarthmanT/db-lb-app/archive/master.zip"  >> /tmp/cfy_status.txt 2>&1 &
env -i cfy blueprints upload -n openstack.yaml        -b "k8s-e2e"                  "https://github.com/EarthmanT/e2e/releases/download/k8s-e2e-download/k8s-e2e.zip"  >> /tmp/cfy_status.txt 2>&1 &
