#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

sudo apt install -yqq tmux > /dev/null

# Setup networking on the host
#sudo iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE
#sudo iptables -A FORWARD -i ens4 -o tap-fc-dev -m state --state RELATED,ESTABLISHED -j ACCEPT
#sudo iptables -A FORWARD -o ens4 -i tap-fc-dev -j ACCEPT

sleep 10

# Download installation wizard for aws firecracker
git clone https://github.com/Schachte/Firecracker-VM-Wizard.git

cd Firecracker-VM-Wizard

{
    echo 5
    for i in {1..5}; do
        echo
    done 
    echo 7
} | sudo ./wizard


sleep 3

export CONFIG_LOCATION=/firecracker/configs
sudo firecracker --no-api --config-file $CONFIG_LOCATION/alpine-config.json 

#cd ..
#cd Firecracker-VM-Wizard

# Run login shell in different session because useless
#tmux new-session -d -s Firecracker "echo 6 | sudo ./wizard"

# Connect to MicroVM
#sudo ssh -i ~/.ssh/hacker alpine@172.16.0.2

# Setup networking
#sudo ip addr add 172.16.0.2/24 dev eth0
#sudo ip link set eth0 up
#sudo ip route add default via 172.16.0.1
