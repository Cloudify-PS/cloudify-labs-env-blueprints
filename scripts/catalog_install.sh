#!/bin/sh

. $(ctx download-resource "utils/utils")


catalogtarball=$( download_file https://github.com/Cloudify-PS/blueprint-catalog/archive/labs-catalog.tar.gz )

tempdir=`mktemp -d`

catalogdir="/var/www/html/catalog"

sudo setenforce 0

sudo tar -xzf $catalogtarball -C $tempdir

#sudo rm "$tempdir/blueprint-catalog-labs-catalog/CatalogApp.js"

#sudo chown -R centos:centos $tempdir

sudo sed -i "s/\[CloudifyURL\]/http:\/\/${public_ip}\//g" $tempdir/blueprint-catalog-labs-catalog/CatalogApp.js

#deploy_blueprint_resource "config/CatalogApp.js" "$tempdir/blueprint-catalog-labs-catalog/CatalogApp.js"

sudo cp -rp $tempdir/blueprint-catalog-labs-catalog  $catalogdir

sudo chown -R root:root $catalogdir

