#!/bin/bash

if [ -f /var/tmp/setup_hosts.sh ];
then
	exit 0
fi

cat >> /etc/hosts <<EOF
192.168.56.71    k8s-master
192.168.56.72    k8s-worker1
192.168.56.73    k8s-worker2
EOF

sudo sed -i 's/127.0.1.1/#127.0.1.1/g' /etc/hosts

touch /var/tmp/setup_hosts.sh