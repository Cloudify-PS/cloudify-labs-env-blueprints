import sys

full_name = sys.argv[1]

if "@" in full_name:
    mail = full_name.split('-')[-2]
    spl = mail.split('@')
    name, company = spl[0], spl[1]
    company = company.split('.')[0]
    lab_name = name + "-" + company
else:
    lab_name = full_name

## replace lab name in index.html file
# Read in the file
with open('/opt/cloudify-stage/dist/index.html', 'r') as f:
    filedata = f.read()
# Replace the target string
filedata = filedata.replace('CloudifyLabName', ('cloudify-lab - '+lab_name))
# Write the file out again
with open('/opt/cloudify-stage/dist/index.html', 'w') as f:
    f.write(filedata)


# datadog_script = "/home/centos/datadog-env.sh"
#
# board_id = '000000'
#
# # replace name in datadog-env script
# with open(datadog_script, 'r') as f:
#     filedata = f.read()
# filedata = filedata.replace('CloudifyLabName', lab_name)
# with open(datadog_script, 'w') as f:
#     f.write(filedata)
#
# #board_id replace
# with open(datadog_script, 'r') as f:
#     filedata = f.read()
# filedata = filedata.replace('BoardID', board_id)
# with open(datadog_script, 'w') as f:
#     f.write(filedata)

