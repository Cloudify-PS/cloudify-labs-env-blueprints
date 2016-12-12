#!/bin/sh

. $(ctx download-resource "utils/utils")


WEBCONSOLEPATH="/var/www/html/webc"

WEBCONSOLEPHP=$(ctx download-resource "config/webconsole.php")


sudo mkdir -p $WEBCONSOLEPATH

sudo cp "$WEBCONSOLEPHP" "$WEBCONSOLEPATH/index.php"

