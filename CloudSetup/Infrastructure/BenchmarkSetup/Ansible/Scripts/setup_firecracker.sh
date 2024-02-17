#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

sudo apt install -yqq tmux > /dev/null

# Setup networking on the host
sudo iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE
sudo iptables -A FORWARD -i ens4 -o tap-fc-dev -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -o ens4 -i tap-fc-dev -j ACCEPT

# Download installation wizard for aws firecracker
git clone https://github.com/Schachte/Firecracker-VM-Wizard.git

cd Firecracker-VM-Wizard

# Setup kernel, filesystem and vm config
sudo bash -c 'sudo bash wizard <<EOF
1
2
3
EOF
'

sudo bash -c 'sudo bash wizard <<EOF
4
EOF
'

# Setup tap device and configure vm network
{     echo 5;     for i in {1..5}; do         echo;     done;     echo 8;} | sudo bash wizard

tmux has-session -t FirecrackerVM 2>/dev/null && tmux kill-session -t FirecrackerVM

tmux new-session -d -s FirecrackerVM -n Setup 
tmux split-window -h -t FirecrackerVM:Setup 'echo "Starting VM..."; sudo bash wizard <<EOF
6
EOF
; read -p "Press enter to close..."' 

tmux resize-pane -t FirecrackerVM:Setup -L 20
tmux select-pane -t FirecrackerVM:Setup.0
tmux send-keys -t FirecrackerVM:Setup.0 'read -p "SSH now? (Press enter to continue...)"; clear; ssh -i ~/.ssh/hacker alpine@172.16.0.2' C-m
tmux attach-session -t FirecrackerVM
