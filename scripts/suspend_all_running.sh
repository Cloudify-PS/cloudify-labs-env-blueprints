#!/bin/bash
. keystonerc_admin
for INSTANCE_ID in $( nova list | grep ACTIVE | grep Running  | awk '{ print$2 }' ); do

echo Instance $INSTANCE_ID Suspending

nova suspend $INSTANCE_ID

done

echo Waiting for instances to suspend

while [ $? -eq 0 ]; do

sleep 1

nova list | grep -E 'ACTIVE.*suspending'

done

