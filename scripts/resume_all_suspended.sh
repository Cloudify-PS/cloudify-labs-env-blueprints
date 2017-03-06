#!/bin/bash
. keystonerc_admin
for INSTANCE_ID in $( nova list | grep SUSPENDED | awk '{ print$2 }' ); do

echo Instance $INSTANCE_ID Resuming

nova resume $INSTANCE_ID

done

