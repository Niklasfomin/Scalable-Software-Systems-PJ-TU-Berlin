#!/bin/bash

# Parameters
PG_SETUP_SCRIPT_PATH="./setup_postgres.sh"
VM_NAME="postgres-vm"
OS_VARIANT="ubuntu20.04"
ISO_URL="http://cdimage.ubuntu.com/ubuntu/releases/20.04/release/ubuntu-20.04.6-live-server-amd64.iso"
ISO_PATH="/var/lib/libvirt/images/ubuntu-server.iso"
DISK_PATH="/var/lib/libvirt/images/${VM_NAME}.qcow2"
DISK_SIZE="20G"
RAM="2048"
VCPUS="2"

# Download Ubuntu ISO if it doesn't already exist
if [ ! -f "$ISO_PATH" ]; then
    echo "Downloading Ubuntu Server ISO..."
    sudo wget -o $ISO_PATH http://cdimage.ubuntu.com/ubuntu/releases/20.04/release/ubuntu-20.04.6-live-server-amd64.iso
fi

# Define image and specs
sudo qemu-img create -f qcow2 $DISK_PATH $DISK_SIZE

# Install the VM
sudo virt-install \
    --name $VM_NAME \
    --ram $RAM \
    --vcpus $VCPUS \
    --os-type linux \
    --os-variant $OS_VARIANT \
    --network network=default,model=virtio \
    --disk path=$DISK_PATH,format=qcow2,bus=virtio \
    --cdrom $ISO_PATH \
    --graphics none \
    --console pty,target_type=serial \
    --wait -1

# Wait for VM to obtain IP Address
echo "Waiting for VM to obtain an IP address..."
sleep 30  # Wait 30 seconds for the DHCP to assign an IP; adjust as needed.

VM_IP=$(sudo virsh domifaddr $VM_NAME | grep ipv4 | awk '{print $4}' | cut -d '/' -f1)

if [ -n "$VM_IP" ]; then
    echo "Setting up port forwarding for PostgreSQL..."
    sudo iptables -t nat -A PREROUTING -p tcp --dport 5432 -j DNAT --to-destination $VM_IP:5432
    sudo iptables -t nat -A POSTROUTING -j MASQUERADE
    bash "$PG_SETUP_SCRIPT_PATH" "$VM_IP"
else
    echo "Failed to discover VM's IP address."
fi
