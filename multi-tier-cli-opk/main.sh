#!/usr/bin/env bash

set -o errexit
set -o pipefail

KOLLA_DEBUG=${KOLLA_DEBUG:-0}
KOLLA_CONFIG_PATH=${KOLLA_CONFIG_PATH:-/etc/kolla}

KOLLA_OPENSTACK_COMMAND=openstack

if [[ $KOLLA_DEBUG -eq 1 ]]; then
    set -o xtrace
    KOLLA_OPENSTACK_COMMAND="$KOLLA_OPENSTACK_COMMAND --debug"
fi

ARCH=$(uname -m)
RANCHEROS_RELEASE=v1.5.8
IMAGE_PATH=/opt/cache/files/
IMAGE_URL=https://github.com/rancher/os/releases/download/${RANCHEROS_RELEASE}/
IMAGE=rancheros-openstack.img
IMAGE_NAME=rancheros
IMAGE_TYPE=linux

# This EXT_NET_CIDR is your public network,that you want to connect to the internet via.
ENABLE_EXT_NET=${ENABLE_EXT_NET:-1}
EXT_NET_CIDR=${EXT_NET_CIDR:-'9.12.93.0/24'}
EXT_NET_RANGE=${EXT_NET_RANGE:-'start=9.12.93.100,end=9.12.93.199'}
EXT_NET_GATEWAY=${EXT_NET_GATEWAY:-'9.12.93.1'}

# Sanitize language settings to avoid commands bailing out
# with "unsupported locale setting" errors.
unset LANG
unset LANGUAGE
LC_ALL=C
export LC_ALL
for i in curl openstack; do
    if [[ ! $(type ${i} 2>/dev/null) ]]; then
        if [ "${i}" == 'curl' ]; then
            echo "Please install ${i} before proceeding"
        else
            echo "Please install python-${i}client before proceeding"
        fi
        exit
    fi
done

# Test for clouds.yaml
if [[ ! -f ${KOLLA_CONFIG_PATH}/clouds.yaml ]]; then
    echo "${KOLLA_CONFIG_PATH}/clouds.yaml is missing."
    echo " Did your deploy finish successfully?"
    exit 1
fi

# Specify clouds.yaml file to use
export OS_CLIENT_CONFIG_FILE=${KOLLA_CONFIG_PATH}/clouds.yaml

# Select admin account from clouds.yaml
export OS_CLOUD=kolla-admin


echo Checking for locally available rancheros image.
# Let's first try to see if the image is available locally
# nodepool nodes caches them in $IMAGE_PATH
if ! [ -f "${IMAGE_PATH}/${IMAGE}" ]; then
    IMAGE_PATH='./'
    if ! [ -f "${IMAGE_PATH}/${IMAGE}" ]; then
        echo None found, downloading rancheros image.
        curl --fail -L -o ${IMAGE_PATH}/${IMAGE} ${IMAGE_URL}/${IMAGE}
    fi
else
    echo Using cached rancheros image from the nodepool node.
fi

echo Creating glance image.
$KOLLA_OPENSTACK_COMMAND image create --disk-format qcow2 --container-format bare --public \
    --property os_type=${IMAGE_TYPE} --file ${IMAGE_PATH}/${IMAGE} ${IMAGE_NAME}

echo Configuring neutron.

$KOLLA_OPENSTACK_COMMAND router create generic-router

$KOLLA_OPENSTACK_COMMAND network create adm-net
$KOLLA_OPENSTACK_COMMAND subnet create --no-dhcp --subnet-range 172.16.1.0/24 --network adm-net \
    --gateway 172.16.1.1 --dns-nameserver 8.8.8.8 adm-subnet
$KOLLA_OPENSTACK_COMMAND router add subnet generic-router adm-subnet

$KOLLA_OPENSTACK_COMMAND network create app-net
$KOLLA_OPENSTACK_COMMAND subnet create --no-dhcp --subnet-range 10.50.1.0/24 --network app-net \
    --gateway 10.50.1.1 --dns-nameserver 8.8.8.8 app-subnet
$KOLLA_OPENSTACK_COMMAND router add subnet generic-router app-subnet

$KOLLA_OPENSTACK_COMMAND network create db-net
$KOLLA_OPENSTACK_COMMAND subnet create --no-dhcp --subnet-range 192.168.1.0/24 --network db-net \
    --gateway 192.168.1.1 --dns-nameserver 8.8.8.8 db-subnet
$KOLLA_OPENSTACK_COMMAND router add subnet generic-router adm-subnet

if [[ $ENABLE_EXT_NET -eq 1 ]]; then
    $KOLLA_OPENSTACK_COMMAND network create --external --provider-physical-network physnet1 \
        --provider-network-type flat external-network
    $KOLLA_OPENSTACK_COMMAND subnet create --no-dhcp \
        --allocation-pool ${EXT_NET_RANGE} --network external-network \
        --subnet-range ${EXT_NET_CIDR} --gateway ${EXT_NET_GATEWAY} external-subnet
    $KOLLA_OPENSTACK_COMMAND router set --external-gateway external-network generic-router
fi

# Get admin user and tenant IDs
ADMIN_PROJECT_ID=$($KOLLA_OPENSTACK_COMMAND project list | awk '/ admin / {print $2}')
ADMIN_SEC_GROUP=$($KOLLA_OPENSTACK_COMMAND security group list --project ${ADMIN_PROJECT_ID} | awk '/ default / {print $2}')

$KOLLA_OPENSTACK_COMMAND security group create admin-secgroup
$KOLLA_OPENSTACK_COMMAND security group create application-secgroup
$KOLLA_OPENSTACK_COMMAND security group create database-secgroup

# Sec Group Config

# Admin Security Group Rules
$KOLLA_OPENSTACK_COMMAND security group rule create --egress --ethertype IPv4 \
    --protocol tcp --dst-port 1:65535 admin-secgroup

$KOLLA_OPENSTACK_COMMAND security group rule create --egress --ethertype IPv4 \
    --protocol udp --dst-port 1:65535 admin-secgroup

$KOLLA_OPENSTACK_COMMAND security group rule create --egress --ethertype IPv4 \
    --protocol icmp admin-secgroup

$KOLLA_OPENSTACK_COMMAND security group rule create --ingress --ethertype IPv4 \
    --protocol tcp --dst-port 22 admin-secgroup

# Application Security Group Rules
$KOLLA_OPENSTACK_COMMAND security group rule create --egress --ethertype IPv4 \
    --protocol tcp --dst-port 1:65535 application-secgroup

$KOLLA_OPENSTACK_COMMAND security group rule create --egress --ethertype IPv4 \
    --protocol udp --dst-port 1:65535 application-secgroup

$KOLLA_OPENSTACK_COMMAND security group rule create --egress --ethertype IPv4 \
    --protocol icmp application-secgroup

$KOLLA_OPENSTACK_COMMAND security group rule create --ingress --ethertype IPv4 \
    --protocol tcp --dst-port 1:65535 --remote-ip 172.16.1.0/24 application-secgroup

$KOLLA_OPENSTACK_COMMAND security group rule create --ingress --ethertype IPv4 \
    --protocol udp --dst-port 1:65535 --remote-ip 172.16.1.0/24 application-secgroup

$KOLLA_OPENSTACK_COMMAND security group rule create --ingress --ethertype IPv4 \
    --protocol icmp --remote-ip 172.16.1.0/24 application-secgroup

$KOLLA_OPENSTACK_COMMAND security group rule create --ingress --ethertype IPv4 \
    --protocol tcp --dest-port 80 application-secgroup

$KOLLA_OPENSTACK_COMMAND security group rule create --ingress --ethertype IPv4 \
    --protocol tcp --dest-port 443 application-secgroup

# Database Security Group Rules
$KOLLA_OPENSTACK_COMMAND security group rule create --egress --ethertype IPv4 \
    --protocol tcp --dst-port 1:65535 database-secgroup

$KOLLA_OPENSTACK_COMMAND security group rule create --egress --ethertype IPv4 \
    --protocol udp --dst-port 1:65535 database-secgroup

$KOLLA_OPENSTACK_COMMAND security group rule create --egress --ethertype IPv4 \
    --protocol icmp database-secgroup

$KOLLA_OPENSTACK_COMMAND security group rule create --ingress --ethertype IPv4 \
    --protocol tcp --dst-port 1:65535 --remote-ip 172.16.1.0/24 database-secgroup

$KOLLA_OPENSTACK_COMMAND security group rule create --ingress --ethertype IPv4 \
    --protocol udp --dst-port 1:65535 --remote-ip 172.16.1.0/24 database-secgroup

$KOLLA_OPENSTACK_COMMAND security group rule create --ingress --ethertype IPv4 \
    --protocol icmp --remote-ip 172.16.1.0/24 database-secgroup

$KOLLA_OPENSTACK_COMMAND security group rule create --ingress --ethertype IPv4 \
    --protocol tcp --dest-port 1521 --remote-ip 10.50.1.0/24 database-secgroup


if [ ! -f ~/.ssh/id_ecdsa.pub ]; then
    echo Generating admin ssh key.
    ssh-keygen -t ecdsa -N '' -f ~/.ssh/id_ecdsa_adm
    echo Generating applications ssh keys.
    ssh-keygen -t ecdsa -N '' -f ~/.ssh/id_ecdsa_app_1
    ssh-keygen -t ecdsa -N '' -f ~/.ssh/id_ecdsa_app_2
    echo Generating databases ssh keys.
    ssh-keygen -t ecdsa -N '' -f ~/.ssh/id_ecdsa_db_1
    ssh-keygen -t ecdsa -N '' -f ~/.ssh/id_ecdsa_db_2
fi
if [ -r ~/.ssh/id_ecdsa_adm.pub ]; then
    echo Configuring nova public keys.
    $KOLLA_OPENSTACK_COMMAND keypair create --public-key ~/.ssh/id_ecdsa_adm.pub adm-keypair
    $KOLLA_OPENSTACK_COMMAND keypair create --public-key ~/.ssh/id_ecdsa_app_1.pub app-keypair-1
    $KOLLA_OPENSTACK_COMMAND keypair create --public-key ~/.ssh/id_ecdsa_app_2.pub app-keypair-2
    $KOLLA_OPENSTACK_COMMAND keypair create --public-key ~/.ssh/id_ecdsa_db_1.pub db-keypair-1
    $KOLLA_OPENSTACK_COMMAND keypair create --public-key ~/.ssh/id_ecdsa_db_2.pub db-keypair-2
fi


# Creating the ports

$KOLLA_OPENSTACK_COMMAND port create --network adm-net --security-group admin-secgroup \
    --fixed-ip subnet=adm-subnet,ip-address=172.16.1.2 adm-port

$KOLLA_OPENSTACK_COMMAND port create --network app-net --security-group application-secgroup \
    --fixed-ip subnet=app-subnet,ip-address=10.50.1.2 app-port-1

$KOLLA_OPENSTACK_COMMAND port create --network app-net --security-group application-secgroup \
    --fixed-ip subnet=app-subnet,ip-address=10.50.1.3 app-port-2

$KOLLA_OPENSTACK_COMMAND port create --network db-net --security-group database-secgroup \
    --fixed-ip subnet=db-subnet,ip-address=192.168.1.2 db-port-1

$KOLLA_OPENSTACK_COMMAND port create --network db-net --security-group database-secgroup \
    --fixed-ip subnet=db-subnet,ip-address=192.168.1.3 db-port-2


# Increase the quota to allow 40 m1.small instances to be created

# 40 instances
$KOLLA_OPENSTACK_COMMAND quota set --instances 40 ${ADMIN_PROJECT_ID}

# 40 cores
$KOLLA_OPENSTACK_COMMAND quota set --cores 40 ${ADMIN_PROJECT_ID}

# 96GB ram
$KOLLA_OPENSTACK_COMMAND quota set --ram 96000 ${ADMIN_PROJECT_ID}

# add default flavors, if they don't already exist
if ! $KOLLA_OPENSTACK_COMMAND flavor list | grep -q m1.tiny; then
    $KOLLA_OPENSTACK_COMMAND flavor create --id 1 --ram 512 --disk 1 --vcpus 1 m1.tiny
    $KOLLA_OPENSTACK_COMMAND flavor create --id 2 --ram 2048 --disk 20 --vcpus 1 m1.small
    $KOLLA_OPENSTACK_COMMAND flavor create --id 3 --ram 4096 --disk 40 --vcpus 2 m1.medium
    $KOLLA_OPENSTACK_COMMAND flavor create --id 4 --ram 8192 --disk 80 --vcpus 4 m1.large
    $KOLLA_OPENSTACK_COMMAND flavor create --id 5 --ram 16384 --disk 160 --vcpus 8 m1.xlarge
fi

$KOLLA_OPENSTACK_COMMAND flavor create --ram 1024 --disk 10 --vcpus 2 t1.adm
$KOLLA_OPENSTACK_COMMAND flavor create --ram 1024 --disk 10 --vcpus 1 t1.app
$KOLLA_OPENSTACK_COMMAND flavor create --ram 1024 --disk 10 --vcpus 1 t1.db


# Creating the instances

$KOLLA_OPENSTACK_COMMAND server create \
    --image ${IMAGE_NAME} \
    --flavor t1.adm \
    --key-name adm-keypair \
    --port adm-port \
    admin-ins

$KOLLA_OPENSTACK_COMMAND server create \
    --image ${IMAGE_NAME} \
    --flavor t1.app \
    --key-name app-keypair-1 \
    --port app-port-1 \
    --user-data ./scripts/web-boot.sh \
    application-ins-1

$KOLLA_OPENSTACK_COMMAND server create \
    --image ${IMAGE_NAME} \
    --flavor t1.app \
    --key-name app-keypair-2 \
    --port app-port-2 \
    --user-data ./scripts/web-boot.sh \
    application-ins-2

$KOLLA_OPENSTACK_COMMAND server create \
    --image ${IMAGE_NAME} \
    --flavor t1.db \
    --key-name db-keypair-1 \
    --port db-port-1 \
    database-ins-1

$KOLLA_OPENSTACK_COMMAND server create \
    --image ${IMAGE_NAME} \
    --flavor t1.db \
    --key-name db-keypair-2 \
    --port db-port-2 \
    database-ins-2



cat << EOF

Everything has been deployed successfully.

You can access to the instances using the ssh credentials that have been
created in the ~/.ssh folder.

EOF
