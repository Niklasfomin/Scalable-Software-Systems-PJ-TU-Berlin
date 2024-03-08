#!/bin/bash

if [ "$#" -ne 1 ]; then 
    echo "Use IP: $0 <VM_IP_ADDRESS>"
    exit 1
fi

VM_IP=$1
VM_USER=ubuntu

ssh -o StrictHostKeyChecking=no $VM_USER@$VM_IP << 'EOF'
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
EOF

echo "PostgreSQL setup is complete on the VM."
    