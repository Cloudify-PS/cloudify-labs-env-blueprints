#!/bin/bash

# Use openstack flavor m1.xlarge

#VARIABLES
if [ -z "${1}" ]; then
    echo "Set a release name"
    echo "Usage: bash $0 <release name>"
    exit 1
else
    RELEASE_NAME=${1}
fi

PASSWORD="cloudify1234"
NIC="eth0"
IPADDRESS=`ip a show dev $NIC | sed '3q;d' | gawk '{match($2,/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/);ip = substr($2,RSTART,RLENGTH);print ip}'`
CONFIG_CINDER_VOLUMES_SIZE="30G"

cat << EOB | sudo tee -a /etc/hosts
10.10.25.1 oib oib.cloudify.labs
EOB

sudo hostnamectl set-hostname $(hostname)

# fix root's authorized_keys
sudo sed -i -e 's/.*ssh-rsa/ssh-rsa/' /root/.ssh/authorized_keys

# RDO
# Prepare networks

sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl disable NetworkManager
sudo systemctl stop NetworkManager
sudo systemctl enable network
sudo systemctl start network

# Install $RELEASE_NAME openstack repository
if ! yum info centos-release-openstack-$RELEASE_NAME; then
    echo "There is no RDO with name $RELEASE_NAME in repository"
    exit 1
fi

sudo yum install -y centos-release-openstack-$RELEASE_NAME
sudo yum install -y yum-utils.noarch
sudo yum-config-manager --enable openstack-$RELEASE_NAME

sudo yum update -y

# OVS install

sudo yum -y install openvswitch


cat << EOB | sudo tee /etc/sysconfig/network-scripts/ifcfg-br-ex
DEVICE=br-ex
DEVICETYPE=ovs
TYPE=OVSBridge
BOOTPROTO=none
ONBOOT=yes
IPADDR=172.25.1.1
NETMASK=255.255.255.0
GATEWAY=172.25.1.1
DNS1=172.25.1.1
MTU=1500
EOB

cat << EOB | sudo tee /etc/sysconfig/network-scripts/ifcfg-br-mng
DEVICE=br-mng
DEVICETYPE=ovs
TYPE=OVSBridge
BOOTPROTO=static
IPADDR=10.10.25.1
NETMASK=255.255.255.0
GATEWAY=10.10.25.1
DNS1=10.10.25.1
MTU=1470
ONBOOT=yes
EOB

sudo service network restart

sudo yum install -y openstack-packstack

cat << EOB | sudo tee /etc/environment
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
EOB

packstack --allinone \
          --provision-demo=n \
          --install-hosts=$(hostname -f) \
          --keystone-admin-passwd=$PASSWORD \
          --os-neutron-l2-agent=openvswitch \
          --os-neutron-ovs-bridge-mappings=extnet:br-ex \
          --os-neutron-ovs-bridge-interfaces=br-ex:$NIC \
          --os-neutron-ml2-mechanism-drivers=openvswitch \
          --os-neutron-ml2-type-drivers=vxlan,flat \
          --os-neutron-ml2-tenant-network-types=vxlan \
          --gen-answer-file answers.txt

# Fix answers
# Fix here IP addresses
sed -i -e "s/$IPADDRESS/10.10.25.1/" answers.txt
sed -i -e "s/CONFIG_CINDER_VOLUMES_SIZE=.*/CONFIG_CINDER_VOLUMES_SIZE=$CONFIG_CINDER_VOLUMES_SIZE/g" answers.txt
cat ~/.ssh/id_rsa.pub | sudo tee -a /root/.ssh/authorized_keys
# Temporary all SSH root login
sudo sed -i -e "s/PermitRootLogin no/PermitRootLogin yes/g" /etc/ssh/sshd_config
sudo sed -i -e "s/#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config
sudo sed -i -e "s/#GatewayPorts no/GatewayPorts yes/g" /etc/ssh/sshd_config
sudo sed -i -e "s/#GatewayPorts yes/GatewayPorts yes/g" /etc/ssh/sshd_config
sudo systemctl restart sshd
#Change to tcp due ssh prevent injecting ssh key to new instance
sed -i -e "s/CONFIG_NOVA_COMPUTE_MIGRATE_PROTOCOL=ssh/CONFIG_NOVA_COMPUTE_MIGRATE_PROTOCOL=tcp/g" answers.txt
packstack --answer-file=answers.txt
sudo yum install -y openstack-utils openstack-selinux

#Disable SSH root login
sudo sed -i -e "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
sudo systemctl restart sshd

# Restore network interfaces.
cat << EOB | sudo tee /etc/sysconfig/network-scripts/ifcfg-br-ex
DEVICE=br-ex
DEVICETYPE=ovs
TYPE=OVSBridge
BOOTPROTO=none
ONBOOT=yes
IPADDR=172.25.1.1
NETMASK=255.255.255.0
GATEWAY=172.25.1.1
DNS1=172.25.1.1
MTU=1500
EOB


cat << EOB | sudo tee /etc/sysconfig/network-scripts/ifcfg-br-mng
DEVICE=br-mng
DEVICETYPE=ovs
TYPE=OVSBridge
BOOTPROTO=static
IPADDR=10.10.25.1
NETMASK=255.255.255.0
GATEWAY=10.10.25.1
DNS1=10.10.25.1
MTU=1470
ONBOOT=yes
EOB

sudo systemctl restart network
sudo systemctl restart openvswitch

# rabbitmq-server.service edit
sudo sed -i -e '/\[Service\]/a RestartSec=15s' /usr/lib/systemd/system/rabbitmq-server.service
sudo sed -i -e '/\[Service\]/a Restart=on-failure' /usr/lib/systemd/system/rabbitmq-server.service
sudo systemctl daemon-reload

# nova config
sudo crudini --set /etc/nova/nova.conf libvirt virt_type kvm
sudo crudini --set /etc/nova/nova.conf DEFAULT resume_guests_state_on_host_boot true

# Enable spice
# sudo yum install -y epel-release.noarch
sudo yum install --enablerepo=epel -y openstack-nova-spicehtml5proxy.noarch spice-html5.noarch python-websockify.noarch spice-server.x86_64 spice-protocol.noarch
sudo crudini --set /etc/nova/nova.conf DEFAULT web "/usr/share/spice-html5"
sudo crudini --set /etc/nova/nova.conf vnc enabled false
sudo crudini --set /etc/nova/nova.conf spice enabled true
sudo crudini --set /etc/nova/nova.conf spice agent_enabled true
sudo crudini --set /etc/nova/nova.conf spice html5proxy_base_url "http://10.10.25.1:6082/spice_auto.html"
sudo crudini --set /etc/nova/nova.conf spice server_proxyclient_address 10.10.25.1
sudo crudini --set /etc/nova/nova.conf spice server_listen 10.10.25.1
sudo crudini --set /etc/nova/nova.conf spice keymap en-us
sudo crudini --set /etc/nova/nova.conf spice html5proxy_host 0.0.0.0
sudo crudini --set /etc/nova/nova.conf spice html5proxy_port 6082

sudo cp /usr/share/doc/spice-html5-0.1.7/apache.conf.sample /etc/httpd/conf.d/spice.conf

# Allow to allocate more then existing RAM
sudo crudini --set /etc/nova/nova.conf DEFAULT ram_allocation_ratio 4
# Allow to allocate more then existing Disk
sudo crudini --set /etc/nova/nova.conf DEFAULT disk_allocation_ratio 10

# apply configs
sudo systemctl restart openstack-nova-compute
sudo systemctl restart httpd
sudo systemctl start openstack-nova-spicehtml5proxy
sudo systemctl enable openstack-nova-spicehtml5proxy

# fix instances behaviour on reboot
sudo sed -i 's/#ON_BOOT=start/ON_BOOT=start/g' /etc/sysconfig/libvirt-guests
sudo sed -i 's/#ON_SHUTDOWN=suspend/ON_SHUTDOWN=suspend/g' /etc/sysconfig/libvirt-guests
sudo systemctl restart libvirt-guests


# update iptables
sudo modprobe nf_conntrack_proto_gre
sudo iptables -I INPUT -p tcp -m multiport --dports 2222,53333,5671,53229 -m comment --comment "CM manager ports" -j ACCEPT
sudo iptables -I INPUT -p tcp -m multiport --dports 6082 -m comment --comment "Allow SPICE connections for console access " -j ACCEPT
sudo iptables -I INPUT -p 47 -j ACCEPT
sudo iptables -I INPUT -i tun+ -j ACCEPT
sudo iptables -I INPUT -p udp --dport 1194 -j ACCEPT
sudo iptables -I FORWARD -p tcp -m multiport --dports 2222,53333,5671,53229 -m comment --comment "CM manager ports" -j ACCEPT
sudo iptables -I FORWARD -p 47 -j ACCEPT
sudo iptables -I FORWARD -i tun+ -j ACCEPT
sudo iptables -I FORWARD -o tun+ -j ACCEPT
sudo iptables -I FORWARD -s 172.25.1.0/24 -j ACCEPT
sudo iptables -I FORWARD -d 172.25.1.0/24 -o br-ex -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s 172.25.1.0/24 -d 0/0 -o $NIC -j MASQUERADE

# save iptables file
sudo iptables-save | sudo tee /etc/sysconfig/iptables

# enable forwarding
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf


# tuning nested
# Enable nested mode
echo "options kvm_intel nested=1" | sudo tee -a /etc/modprobe.d/kvm.conf

# Allow to overcommit memory for instances
echo "vm.overcommit_memory=1" | sudo tee -a /etc/sysctl.conf

sudo sysctl -p

sudo mkdir /etc/tuned/no-thp
cat << EOB | sudo tee /etc/tuned/no-thp/tuned.conf
[main]
include=virtual-guest

[vm]
transparent_hugepages=never

[script]
script=script.sh

EOB

cat << EOB | sudo tee /etc/tuned/no-thp/script.sh
#!/bin/sh

. /usr/lib/tuned/functions

start() {
 echo never > /sys/kernel/mm/transparent_hugepage/defrag
 return 0
}

stop() {
 return 0
}

process $@

EOB

sudo chmod +x /etc/tuned/no-thp/script.sh
sudo tuned-adm profile no-thp


sudo cp /root/keystonerc_admin ${HOME}
sudo chown $(whoami):$(whoami) ${HOME}/keystonerc_admin


#In some issues with  Newton it may help to run instances
# Edin /etc/nova/nova.conf
#hw_machine_type=x86_64=pc-i440fx-rhel7.4.0,x86_64=pc-i440fx-rhel7.3.0,x86_64=pc-i440fx-rhel7.2.0
# Restart compute-api and compute
if [[ "$RELEASE_NAME" -eq "newton" ]]
then
  sudo crudini --set /etc/nova/nova.conf libvirt hw_machine_type "x86_64=pc-i440fx-rhel7.4.0,x86_64=pc-i440fx-rhel7.3.0,x86_64=pc-i440fx-rhel7.2.0"
  sudo systemctl restart openstack-nova-compute
  sudo systemctl restart openstack-nova-api
fi

# set workaround for the bug https://bugs.launchpad.net/nova/+bug/1767139/comments/6
sudo sed -i -e '/\[Service\]/a ExecStartPre=/bin/sleep 90' /usr/lib/systemd/system/openstack-nova-compute.service
sudo systemctl daemon-reload


# Create openstack external router and network
EXTERNAL_NETWORK="external_network"
source ${HOME}/keystonerc_admin
neutron net-create $EXTERNAL_NETWORK --provider:network_type flat --provider:physical_network extnet --router:external --share
neutron subnet-create --name ext_sub --enable_dhcp=False --allocation-pool=start=172.25.1.10,end=172.25.1.250 --gateway=172.25.1.1 $EXTERNAL_NETWORK 172.25.1.0/24

openstack router create router1
openstack router set router1 --external-gateway $EXTERNAL_NETWORK

# create private_network
neutron net-create private_network
neutron subnet-create --name private_subnet --dns-nameserver 8.8.8.8 --dns-nameserver 8.8.4.4 private_network 192.168.113.0/24
neutron router-interface-add router1 private_subnet

# create provider network and subnet
neutron net-create provider --provider:network_type flat --provider:physical_network provider
neutron subnet-create provider 10.10.25.0/24 --name provider_subnet --enable-dhcp --allocation-pool start=10.10.25.100,end=10.10.25.200 --dns-nameserver 8.8.8.8 --ip-version 4 --gateway 10.10.25.253
neutron router-interface-add router1 provider_subnet

# create openstack images
echo "Uploading CentOS 7.6 ..."
curl https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1809.qcow2 -o /tmp/CentOS-7-x86_64-GenericCloud-1809.qcow2
openstack image create --disk-format qcow2 --id aee5438f-1c7c-497f-a11e-53360241cf0f --file /tmp/CentOS-7-x86_64-GenericCloud-1809.qcow2 CentOS7
rm -f /tmp/CentOS-7-x86_64-GenericCloud-1809.qcow2

echo "Uploading Ubuntu ..."
curl https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img -o /tmp/bionic-server-cloudimg-amd64.img
openstack image create --disk-format raw --id 05bb3a46-ca32-4032-bedd-8d7ebd5c8100 --file /tmp/bionic-server-cloudimg-amd64.img Ubuntu
rm -f /tmp/bionic-server-cloudimg-amd64.img

echo "Uploading cirros ..."
curl http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img -o /tmp/cirros-0.4.0-x86_64-disk.img
openstack image create --disk-format raw --id a95c112f-a1ab-40b4-a3cc-7604485a43d2 --file /tmp/cirros-0.4.0-x86_64-disk.img cirros
rm -f /tmp/cirros-0.4.0-x86_64-disk.img

#create flavors
echo "Create Flavor 1 Core & 2 GB RAM 20 GB Disk - 1x2"
openstack flavor create --id '4d798e17-3439-42e1-ad22-fb956ec22b54' --ram 2048 --disk 20 --vcpus 1 --public 1x2

echo "Create Flavor 2 Core & 2 GB RAM 20 GB Disk - 2x2"
openstack flavor create --id '62ed898b-0871-481a-9bb4-ac5f81263b33' --ram 2048 --disk 20 --vcpus 2 --public 2x2

echo "Create Flavor for Cloudify Manager 2 Cores,  5GB RAM 20 GB Disk -  cloudify_flavor"
openstack flavor create --id 'b1cefcbf-fab9-40d9-a084-8aeb2514028b' --ram 5000 --disk 20 --vcpus 2 --public cloudify_flavor

# # Change admin password
# openstack user password set --password $PASSWORD --original-password $OS_PASSWORD
# sed -i "s/OS_PASSWORD='.*'/OS_PASSWORD=$PASSWORD/g" ${HOME}/keystonerc_admin
# sudo sed -i "s/OS_PASSWORD='.*'/OS_PASSWORD=$PASSWORD/g" /root/keystonerc_admin

#OpenVPN
sudo yum -y --enablerepo=epel install openvpn

cat << EOB | sudo tee /etc/openvpn/server.conf
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key  # This file should be kept secret
dh dh2048.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "route 10.10.25.0 255.255.255.0"
push "route 172.25.1.0 255.255.255.0"
duplicate-cn
keepalive 10 120
tls-auth ta.key 0 # This file is secret
comp-lzo
max-clients 10
user nobody
group nobody
persist-key
persist-tun
status /tmp/openvpn-status.log
log        /tmp/openvpn.log
log-append  /tmp/openvpn.log
verb 3
mute 20
tun-mtu-extra 32
tun-mtu 1460
mssfix 1420
reneg-sec 0

EOB

cat << EOB | sudo tee /etc/openvpn/ca.crt
-----BEGIN CERTIFICATE-----
MIIFEjCCA/qgAwIBAgIJAMk3o2jhtG2oMA0GCSqGSIb3DQEBCwUAMIG2MQswCQYD
VQQGEwJVUzELMAkGA1UECBMCQ0ExFTATBgNVBAcTDFNhbkZyYW5jaXNjbzEVMBMG
A1UEChMMRm9ydC1GdW5zdG9uMR0wGwYDVQQLExRNeU9yZ2FuaXphdGlvbmFsVW5p
dDEYMBYGA1UEAxMPRm9ydC1GdW5zdG9uIENBMRAwDgYDVQQpEwdFYXN5UlNBMSEw
HwYJKoZIhvcNAQkBFhJtZUBteWhvc3QubXlkb21haW4wHhcNMTUwNTIwMTE0MzA4
WhcNMjUwNTE3MTE0MzA4WjCBtjELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAkNBMRUw
EwYDVQQHEwxTYW5GcmFuY2lzY28xFTATBgNVBAoTDEZvcnQtRnVuc3RvbjEdMBsG
A1UECxMUTXlPcmdhbml6YXRpb25hbFVuaXQxGDAWBgNVBAMTD0ZvcnQtRnVuc3Rv
biBDQTEQMA4GA1UEKRMHRWFzeVJTQTEhMB8GCSqGSIb3DQEJARYSbWVAbXlob3N0
Lm15ZG9tYWluMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxSRWliym
7a7I1fGaNSUqcakx8ysJz6udWjGiQV1MJhVCsYkG57FUjmtiGCkrHK/xwbqfQPo7
Nw83xhdIcbG2dWuoMM9dPdRwNlfcMKDuRKKZEYmfQTY5BnDUvzE5HunBvO5f9Le7
tAdb+1RMYGjs9sx/WALEXvnxNQ97/oMv9kQefLZ8YSYx4sNT0kSy68GJ5ciTbDGj
zHTGzJbKJTvUDlFS4d7GqU0qJJxXMdqVyw3pi2xcwVNU7UMbdGRKi1zLV3JumL9V
5MOTQQy3iL8miY2M3lbsm6CvxZxs+WHyQ/dMvjfaVbCfKuv2Q2iV3UN/PH9s+j1L
fzxuNya1Ao4B9wIDAQABo4IBHzCCARswHQYDVR0OBBYEFDMP/qluRn3hYAqbs83U
If4pM0f4MIHrBgNVHSMEgeMwgeCAFDMP/qluRn3hYAqbs83UIf4pM0f4oYG8pIG5
MIG2MQswCQYDVQQGEwJVUzELMAkGA1UECBMCQ0ExFTATBgNVBAcTDFNhbkZyYW5j
aXNjbzEVMBMGA1UEChMMRm9ydC1GdW5zdG9uMR0wGwYDVQQLExRNeU9yZ2FuaXph
dGlvbmFsVW5pdDEYMBYGA1UEAxMPRm9ydC1GdW5zdG9uIENBMRAwDgYDVQQpEwdF
YXN5UlNBMSEwHwYJKoZIhvcNAQkBFhJtZUBteWhvc3QubXlkb21haW6CCQDJN6No
4bRtqDAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQBejEzePmlhRZUL
axoGNGg3kRs4amPS2MrXb0GMHS1jLQS6DjTN1180oRREF0CuF/ENc45m9Z9+QVFl
g0Xx6xUAATc2SC47/ppXR0rMOJ/e8dDCU2JPhLgHPB1ZF2NCn98a1XJj85q4Uerh
bWWuxRiUAWTS2RGHoQMbbPE7Qey+RIb5p9QVstEF9isqNUE8+T+f7dIzHThkc58Q
Cn+Rd8Z7vYtLC5/wxRCt5my4HvofpzycOAF7TXBL1fi1tp34iD8b4SnzM6RC5PD1
7HHCcObLvflJftTHcwu8+Z89Wi8M+xo1MAKGGJFA4d5n4h8ERTZO32R07AlmL5+h
vtjTGrfE
-----END CERTIFICATE-----

EOB

cat << EOB | sudo tee /etc/openvpn/dh2048.pem
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEA1xSLDhq8xpILQ4OXxIPrOq/ZvZ4KTbRI3w16PXlZ+XAf3XiBF3dg
mPp72Bk0BMLmo5Dl/xsR380ki70Gsh+BAT3ZrCfRli6BKx6tIomXj1fevt0MFE7R
jOUvBzqVmG66Q1/mSCEd6Zu2QO7zLLhZvEqYFeckM8XMTyQXininGizHw/VsErOS
4egXyQYg0uigf6gVBp1W4x1XjfrnMk3y9+ie1MiQH8k9i8NLrgn//LCWJIg26Z6C
P2k+ZONDJa6TBvy+cPiZ+mYSlgo0QPidK2lXWifxV2yoM+xPqoUEzUZa5UvRvVwf
cLqtQz0x7pcT/Yf7zd09WlleFAhvU5w3MwIBAg==
-----END DH PARAMETERS-----

EOB

cat << EOB | sudo tee /etc/openvpn/ipp.txt
EOB

cat << EOB | sudo tee /etc/openvpn/openvpn.log
EOB

cat << EOB | sudo tee /etc/openvpn/openvpn-status.log
EOB

cat << EOB | sudo tee /etc/openvpn/server.crt # should be replaced to generate new cert function
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 1 (0x1)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=CA, L=SanFrancisco, O=Fort-Funston, OU=MyOrganizationalUnit, CN=Fort-Funston CA/name=EasyRSA/emailAddress=me@myhost.mydomain
        Validity
            Not Before: May 20 11:43:48 2015 GMT
            Not After : May 17 11:43:48 2025 GMT
        Subject: C=US, ST=CA, L=SanFrancisco, O=Fort-Funston, OU=MyOrganizationalUnit, CN=server/name=EasyRSA/emailAddress=me@myhost.mydomain
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:ed:b7:74:89:15:2c:f0:62:dc:52:60:35:89:5c:
                    f4:e6:7e:5a:68:45:fb:a4:c9:88:d1:9e:c1:46:01:
                    ec:55:9d:1b:43:63:a7:23:c4:29:9f:8e:dc:df:0e:
                    f6:41:d9:f1:49:6b:56:ed:ef:d8:4b:ef:69:24:dd:
                    96:1c:ff:4e:72:15:b5:51:38:ad:b0:e4:d5:aa:04:
                    21:09:87:5e:c4:ee:0f:79:83:1e:ef:5d:ff:b8:05:
                    50:6b:05:b4:3c:70:86:43:31:20:a5:9c:1b:3f:6a:
                    e7:72:39:5d:4f:b0:3c:29:cd:07:89:c3:4e:d8:6b:
                    76:7f:56:1c:34:93:f7:61:c6:a0:53:0d:44:8d:98:
                    64:a1:5a:07:97:00:93:42:5f:e5:0b:01:3c:3e:8b:
                    90:04:85:e9:4b:0b:db:12:44:ee:8f:f0:ae:66:ea:
                    6f:61:b5:8e:a5:38:c2:4d:a8:72:02:87:8d:5f:70:
                    b4:ad:5f:d6:ed:ea:fa:1b:47:ca:1a:20:93:2a:00:
                    27:3e:8d:ba:cd:ab:c5:96:f9:74:24:79:9a:98:d6:
                    7a:cd:eb:72:3b:95:8e:1b:4d:a9:d5:00:a4:79:40:
                    72:b7:0f:94:b9:ef:8d:b1:a4:d0:b7:73:75:7f:8b:
                    8c:3d:9d:34:66:bc:db:0d:4c:0a:d4:68:1b:47:3d:
                    57:17
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            Netscape Cert Type:
                SSL Server
            Netscape Comment:
                Easy-RSA Generated Server Certificate
            X509v3 Subject Key Identifier:
                0B:D2:99:6A:C1:08:A8:18:5E:B3:C8:C3:D5:95:8C:76:D3:A1:20:39
            X509v3 Authority Key Identifier:
                keyid:33:0F:FE:A9:6E:46:7D:E1:60:0A:9B:B3:CD:D4:21:FE:29:33:47:F8
                DirName:/C=US/ST=CA/L=SanFrancisco/O=Fort-Funston/OU=MyOrganizationalUnit/CN=Fort-Funston CA/name=EasyRSA/emailAddress=me@myhost.mydomain
                serial:C9:37:A3:68:E1:B4:6D:A8

            X509v3 Extended Key Usage:
                TLS Web Server Authentication
            X509v3 Key Usage:
                Digital Signature, Key Encipherment
            X509v3 Subject Alternative Name:
                DNS:server
    Signature Algorithm: sha256WithRSAEncryption
         0a:49:b7:7a:71:32:3a:6d:ac:73:15:2f:48:f9:b3:f1:bf:e8:
         3d:79:b9:75:8f:2c:33:f0:77:75:9c:66:51:f3:56:1f:3c:fa:
         1b:5b:74:d6:fd:76:28:2c:e8:19:97:a1:d0:a1:52:9f:3a:fd:
         fe:5e:e4:90:2b:dc:42:7d:30:a0:67:e9:3a:a9:2e:9b:86:1a:
         7f:18:6e:fe:e8:5d:bd:20:59:8c:26:9f:17:ab:19:a9:86:dd:
         85:26:ec:5a:2e:3f:58:e7:cf:92:2c:b8:af:0b:71:97:40:5a:
         56:0c:7e:bc:cd:32:bc:ae:48:e5:6c:d0:c9:cb:4a:7e:7c:73:
         3d:6d:ff:9e:7b:96:e4:cd:e0:13:11:b4:64:ac:54:ca:3b:36:
         59:f8:1c:a1:1f:e6:0b:78:eb:36:58:f3:9b:fb:03:54:10:ce:
         cf:3f:d6:62:fb:10:a5:a4:91:1d:c8:1f:10:16:8f:2a:37:4c:
         1a:dd:a4:49:e3:7c:47:9c:37:39:fd:25:20:9e:71:65:50:73:
         88:5b:20:c7:8b:d4:d3:fd:69:fa:9f:91:af:22:b6:84:35:9f:
         e8:57:70:a4:9a:eb:32:6a:51:ba:a4:15:e2:af:e3:ff:95:f8:
         f7:ce:b9:9e:d2:af:21:e9:d9:84:8d:15:8d:d1:da:c1:c6:78:
         91:ac:7f:b9
-----BEGIN CERTIFICATE-----
MIIFfDCCBGSgAwIBAgIBATANBgkqhkiG9w0BAQsFADCBtjELMAkGA1UEBhMCVVMx
CzAJBgNVBAgTAkNBMRUwEwYDVQQHEwxTYW5GcmFuY2lzY28xFTATBgNVBAoTDEZv
cnQtRnVuc3RvbjEdMBsGA1UECxMUTXlPcmdhbml6YXRpb25hbFVuaXQxGDAWBgNV
BAMTD0ZvcnQtRnVuc3RvbiBDQTEQMA4GA1UEKRMHRWFzeVJTQTEhMB8GCSqGSIb3
DQEJARYSbWVAbXlob3N0Lm15ZG9tYWluMB4XDTE1MDUyMDExNDM0OFoXDTI1MDUx
NzExNDM0OFowga0xCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJDQTEVMBMGA1UEBxMM
U2FuRnJhbmNpc2NvMRUwEwYDVQQKEwxGb3J0LUZ1bnN0b24xHTAbBgNVBAsTFE15
T3JnYW5pemF0aW9uYWxVbml0MQ8wDQYDVQQDEwZzZXJ2ZXIxEDAOBgNVBCkTB0Vh
c3lSU0ExITAfBgkqhkiG9w0BCQEWEm1lQG15aG9zdC5teWRvbWFpbjCCASIwDQYJ
KoZIhvcNAQEBBQADggEPADCCAQoCggEBAO23dIkVLPBi3FJgNYlc9OZ+WmhF+6TJ
iNGewUYB7FWdG0NjpyPEKZ+O3N8O9kHZ8UlrVu3v2EvvaSTdlhz/TnIVtVE4rbDk
1aoEIQmHXsTuD3mDHu9d/7gFUGsFtDxwhkMxIKWcGz9q53I5XU+wPCnNB4nDTthr
dn9WHDST92HGoFMNRI2YZKFaB5cAk0Jf5QsBPD6LkASF6UsL2xJE7o/wrmbqb2G1
jqU4wk2ocgKHjV9wtK1f1u3q+htHyhogkyoAJz6Nus2rxZb5dCR5mpjWes3rcjuV
jhtNqdUApHlAcrcPlLnvjbGk0LdzdX+LjD2dNGa82w1MCtRoG0c9VxcCAwEAAaOC
AZowggGWMAkGA1UdEwQCMAAwEQYJYIZIAYb4QgEBBAQDAgZAMDQGCWCGSAGG+EIB
DQQnFiVFYXN5LVJTQSBHZW5lcmF0ZWQgU2VydmVyIENlcnRpZmljYXRlMB0GA1Ud
DgQWBBQL0plqwQioGF6zyMPVlYx206EgOTCB6wYDVR0jBIHjMIHggBQzD/6pbkZ9
4WAKm7PN1CH+KTNH+KGBvKSBuTCBtjELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAkNB
MRUwEwYDVQQHEwxTYW5GcmFuY2lzY28xFTATBgNVBAoTDEZvcnQtRnVuc3RvbjEd
MBsGA1UECxMUTXlPcmdhbml6YXRpb25hbFVuaXQxGDAWBgNVBAMTD0ZvcnQtRnVu
c3RvbiBDQTEQMA4GA1UEKRMHRWFzeVJTQTEhMB8GCSqGSIb3DQEJARYSbWVAbXlo
b3N0Lm15ZG9tYWluggkAyTejaOG0bagwEwYDVR0lBAwwCgYIKwYBBQUHAwEwCwYD
VR0PBAQDAgWgMBEGA1UdEQQKMAiCBnNlcnZlcjANBgkqhkiG9w0BAQsFAAOCAQEA
Ckm3enEyOm2scxUvSPmz8b/oPXm5dY8sM/B3dZxmUfNWHzz6G1t01v12KCzoGZeh
0KFSnzr9/l7kkCvcQn0woGfpOqkum4Yafxhu/uhdvSBZjCafF6sZqYbdhSbsWi4/
WOfPkiy4rwtxl0BaVgx+vM0yvK5I5WzQyctKfnxzPW3/nnuW5M3gExG0ZKxUyjs2
WfgcoR/mC3jrNljzm/sDVBDOzz/WYvsQpaSRHcgfEBaPKjdMGt2kSeN8R5w3Of0l
IJ5xZVBziFsgx4vU0/1p+p+RryK2hDWf6FdwpJrrMmpRuqQV4q/j/5X49865ntKv
IenZhI0VjdHawcZ4kax/uQ==
-----END CERTIFICATE-----

EOB

cat << EOB | sudo tee /etc/openvpn/server.key
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDtt3SJFSzwYtxS
YDWJXPTmflpoRfukyYjRnsFGAexVnRtDY6cjxCmfjtzfDvZB2fFJa1bt79hL72kk
3ZYc/05yFbVROK2w5NWqBCEJh17E7g95gx7vXf+4BVBrBbQ8cIZDMSClnBs/audy
OV1PsDwpzQeJw07Ya3Z/Vhw0k/dhxqBTDUSNmGShWgeXAJNCX+ULATw+i5AEhelL
C9sSRO6P8K5m6m9htY6lOMJNqHICh41fcLStX9bt6vobR8oaIJMqACc+jbrNq8WW
+XQkeZqY1nrN63I7lY4bTanVAKR5QHK3D5S5742xpNC3c3V/i4w9nTRmvNsNTArU
aBtHPVcXAgMBAAECggEAU0B0p62q12VIE/FtznWnrzGBKBOaVdPe/srClWoHAtTK
v4ce+f+xNBgsclIjHFzfi/7zqtDcx3tJL4gLEoy3RG0l2xQmgFUkHy7jAxtNrVpS
QRQSuXIKJMB3sYOF48TkwJNsA5PwVv1xoSdF7qqh52HOygiEjHbWQTI/HorTkIH6
yMtcbEJwAMWXpC16vl3Q1viFr7A8L959TDKKYru2+cWGnJflFEP1yICP6KNO9HXx
9nPlv8y+qy6EOMHk5Op79Eqm0OB3fECnTOBhbs5JTy4CHA0Puojj+mxlc25pysyb
te0pr7tR7cy7GDLlxKtNgyBCXpahVhmyTISiWhM9QQKBgQD4Qx60SPaU1HvbV5KC
d+7qZl6x2VcIohI/tNxgNyJp7un/ZA2oJ+ozil0+g/Yo13c/69wC2kEmdRfhSmH6
UXyt8Q7uKywmYs9fUGNSTVArZFrBOen5FhgiMEAu0EgJODxEGJijQdHzKUm3ysSz
9ScMsxHf7CR13f5ur13LOm+x1QKBgQD1IDE/yYH/l3IzRvUVB+oSl65yCITK11AX
ZgDUHbisL5Cg46YPz/TTKIcwKpBiEN1etoboCPye5QCcWUL+X/sQJ9NitOUZrIhO
NhUf+ck+VdzhtWMMYURUxU3n4W6qf6xljmS+pJXd43ls7IbNxRgBB+/UoCZcTFu0
KtokKdRvOwKBgEdBLHzePDe3TN1Foz1jIuWQADnXgY1uxwIV7PKIoI37DppIo0rS
OfwVCHI6+dn7DbUBAyKmdfCNxw7YhIqN/NUHzRs6tO9HiPF4ZylmG054/TtcXfUq
DD8zzhghm6tZwqJg1N52s8Ww4gGoZxCnmk+gzc6RPl2+G5q1Jpx/5zMJAoGBAI4e
bQ9rmIiE2Pxr3nqkDQ1cjhKlZ8BnF5OJW1+gH8sNBNCTTFuMmYi3zbGaa/2/g2l/
cDYlx7mkUjdT9WigY2LZhFCNSusYwip+Zr8URp5yj875KIUr+78eae3QISaPQXfc
GAMET7PHSEZj2ECDTkiCvoVLmRIYX27VDYa8DeOzAoGBANvjhLSG+tSfGl6QqAwa
97QH4jOLdEzDAqhy/isOSgeSONBe11HglPIQOy/SCFW/fUkvOUgu3PlEC59/ufTt
iCGKkaV1F0ALOWxQ8k8KRtvENpGGZoSHDb2JxqN9oh/2D9ulwFi65xkPi3IqQzqK
ecmc4DRM1TInCSXZe36QqIAi
-----END PRIVATE KEY-----

EOB

cat << EOB | sudo tee /etc/openvpn/ta.key
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
3823180fe070f87f5475ef2352183b41
93ca866c1fa188c08aaab0375dbd03e1
d2116b7e7448b4dd605d4541e22c213c
cfeebab34046ff989399816617e23122
05363b0f0b33d1c23fdf663fbaf78385
e9f533d50a60aa2f0569fec87e5caab3
e7725d10bcdfb806db7d1fd329fa80c0
ebb53a512a8b2736069e29362023ebee
03e581cff5d29f7865f787116c1e7a5c
08cab7d476d829d9f3e2f83a88f44316
a611b2bb7d8b6194e32adcb8a63518e0
c94db0f7e0cb5e527399433067990cfe
9131280813ae1097ec3f19a0e9e40126
6044b53163c7467134f42b3d284124e2
4ded84c7f154322f2e3a831809ba9ccd
54ae3f9986fe6377d0451ebad491b32c
-----END OpenVPN Static key V1-----

EOB

sudo systemctl start openvpn@server
sudo systemctl enable openvpn@server

#create user cloudify and set authorithed keys
# Cloudify user uses to set CM port forwarding via OIB

sudo adduser cloudify
sudo usermod -aG wheel cloudify
sudo mkdir /home/cloudify/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAgJTYbfKC+adktZu3etKSSjw6pxRqOVrSuU7jJ6+ssFLLftbxi5YJL8ITllmfChZnqJecGiBFotbzr5WekGX8ROqSHT1p984bX0hJRjrsxPLirnX/bqYGoQudse3F/D6bUlkusA/t4ZFFibkOFiDp0kwpOa/Ch4sQAqiYacqO2/KBKRf5r6xTgdQyUt9GnQ7iZCOz5oaky889z37Jjy1J3EiAej8sRxKo+4b5rNke+YozCpoF/c7IORpgguVW5sBI5af7jfRJwWpTq4UoGiiIHc47qJVbl7PPJUfVtx4mswiS3LifgYf/N+/ohWpf/ERKsp0SRIDuS8tAIvTFkoYb cloudify" | sudo tee -a /home/cloudify/.ssh/authorized_keys
sudo chmod 700 /home/cloudify/.ssh
sudo chmod -R 600 /home/cloudify/.ssh/authorized_keys
sudo chown -R cloudify:cloudify /home/cloudify/.ssh

# Copy keystone_admin file
# sudo cp ${HOME}/keystonerc_admin /root/
sudo cp ${HOME}/keystonerc_admin /home/cloudify/
sudo chown cloudify:cloudify /home/cloudify/keystonerc_admin


# clean
sudo rm -f /root/.ssh/authorized_keys
rm -f ${HOME}/.ssh/authorized_keys

cd ${HOME}
rm -fr ${HOME}/cloudify-labs-env-blueprints
history -c
sudo poweroff
