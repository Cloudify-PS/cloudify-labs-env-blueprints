#!/bin/bash

env -i cfy blueprints upload -n openstack.yaml    -b "NodeCellar-Bluperint"  "https://github.com/cloudify-examples/nodecellar-auto-scale-auto-heal-blueprint/archive/master.zip"  >> /tmp/cfy_status.txt 2>&1

env -i cfy deployments create  -b  "NodeCellar-Bluperint"  "NodeCellar-Deployment"  >> /tmp/cfy_status.txt 2>&1

env -i cfy executions start install -d "NodeCellar-Deployment"  >> /tmp/cfy_status.txt 2>&1 &
