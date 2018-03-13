#!/bin/bash
SQLURL=$sql_url
DATABASE=$database

curl "$SQLURL" | sudo su - postgres -c "psql $DATABASE"
