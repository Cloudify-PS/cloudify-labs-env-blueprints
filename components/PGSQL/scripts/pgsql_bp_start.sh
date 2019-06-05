#!/bin/bash

DATABASE=$database

sql_temp_file=`mktemp`

ctx download-resource-and-render "$sql_path" "${sql_temp_file}"
cat "${sql_temp_file}" | sudo su - postgres -c "psql $DATABASE"
