#!/bin/sh


OrigianlCatalogURL='//repository.cloudifysource.org/cloudify/blueprints/4.4/examples.json'
NewCatalogURL=$catalog

#Dump the userdata
cd ~
sudo su - postgres -c "pg_dump stage -c --table='\"UserApps\"'"  > stage-dump-UserApps.dump

#make escaped variables for sed
origesc="`echo $OrigianlCatalogURL | sed -e 's/[]\/\$\*.^[]/\\\\&/g'`"
newesc="`echo $NewCatalogURL | sed -e 's/[]\/\$\*.^[]/\\\\&/g'`"

# replace the original catalog
sed -i "s/${origesc}/${newesc}/g" stage-dump-UserApps.dump


cat stage-dump-UserApps.dump | sudo su - postgres -c "psql stage"
