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

# DB setup
sudo iptables -t nat -A PREROUTING -p tcp --dport 5432 -j DNAT --to-destination 172.16.0.2:5432
sudo iptables -A FORWARD -p tcp -d 172.16.0.2 --dport 5432 -j ACCEPT


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
EOF'

sleep 4

tmux resize-pane -t FirecrackerVM:Setup -L 5
tmux select-pane -t FirecrackerVM:Setup.0
# Path for fc pgsql needs to be adjusted in playbook or here
tmux send-keys -t FirecrackerVM:Setup.0 'scp -i ~/.ssh/hacker /opt/setup_fc_pgsql.sh alpine@172.16.0.2:~/' Enter 
tmux send-keys -t FirecrackerVM:Setup.0 'ssh -i ~/.ssh/hacker alpine@172.16.0.2' Enter
tmux send-keys -t FirecrackerVM:Setup.0 'chmod +x setup_fc_pgsql.sh' Enter
tmux send-keys -t FirecrackerVM:Setup.0 './setup_fc_pgsql.sh' Enter
tmux attach-session -t FirecrackerVM