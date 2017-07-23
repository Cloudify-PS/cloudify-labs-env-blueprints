cfy secret create ubuntu_trusty_image -s 05bb3a46-ca32-4032-bedd-8d7ebd5c8100
cfy secret create small_image_flavor -s 4d798e17-3439-42e1-ad22-fb956ec22b54
cfy secret create keystone_username -s admin
cfy secret create keystone_password -s 'cloudify1234'
cfy secret create keystone_tenant_name -s admin
cfy secret create keystone_url -s http://10.10.25.1:5000/v2.0
cfy secret create region -s RegionOne
cfy secret create agent_key_private -s /etc/cloudify/.ssh/cfy-agent-kp.pem
#cfy secret create agent_key_public -s 'ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAqRWxUBauLqyxPxtLdCvI4tEL8zAUuwZdpxq1gL26m8LUrcZpMvv0fPmV0t0/4zSLTRGE3A+lVelunznpU23uRqK2UWkBFKmMgX1fgKW4BvPQjniBtZbO6lRbt9Gq8BL/vbv2TAg19vbjTm+5nNjtyi4CC9UgFDVrxmPVezBPVZCKicexj4p6zg/vnYYC0XEwwpLbPGejFsSYM6iHUNuU1/xFsPgVW/n7SL+Lv8w4WYYY8V/WLpqGpGB2q9WyHV7GrrYlCXBjpnjB9X/qGywME3qx1P7rT8GUf597+PVq1p5bn5vIk52uok54Gv2a3RgDw6l2BmbryQXcDlwr0vs8bQ== agent key'
cfy secret create agent_key_public --secret-file /etc/cloudify/.ssh/cfy-agent-kp.pub
cfy secret create private_subnet_name -s provider_subnet
cfy secret create private_network_name -s provider
cfy secret create public_subnet_name -s private_subnet
cfy secret create public_network_name -s private_network
cfy secret create router_name -s router1
cfy secret create external_network_name -s external_network
