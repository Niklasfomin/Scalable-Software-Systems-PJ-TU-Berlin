#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

container_exists() {
    lxc info "$1" > /dev/null 2>&1
    return $?
}

# Variables
CONTAINER_NAME="pgsql"
PG_USER="postgres"
PG_PWD="postgres"
DB_NAME="postgres"
PG_PORT="5432"
hammerDB_IP=$(cat /opt/hammerDB_server_ip.txt)

print_message "Initializing LXD..."

# Initialize LXD 
lxd init --auto

sleep 3

print_message "Initialization done....continue..."

sleep 2

print_message "Launching Ubuntu LXC container..."

if container_exists "$CONTAINER_NAME"; then
    print_message "Container already exists. Skipping creation."
else
    print_message "Container not found. Creating a new one..."
    lxc launch images:ubuntu/20.04 "$CONTAINER_NAME"
fi

print_message "Waiting for container to start..."
sleep 10

print_message "Installing PostgreSQL inside the container..."
lxc exec "$CONTAINER_NAME" -- apt update > /dev/null
lxc exec "$CONTAINER_NAME" -- apt install -yqq postgresql > /dev/null

print_message "Setting up PostgreSQL user and password..."
lxc exec "$CONTAINER_NAME" -- su postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD '$PG_PWD';\""

print_message "Switching to psql prompt..."
lxc exec "$CONTAINER_NAME" -- sudo -u postgres psql <<EOF

-- SQL commands to setup benchmark-db + user + permissions
CREATE DATABASE tpcc;
CREATE USER tpcc WITH PASSWORD 'tpcc';
GRANT ALL PRIVILEGES ON DATABASE tpcc TO tpcc;
EOF

print_message "Configuring port forwarding..."
lxc config device add "$CONTAINER_NAME" pg_port"$PG_PORT" proxy listen=tcp:0.0.0.0:"$PG_PORT" connect=tcp:127.0.0.1:"$PG_PORT"

print_message "PostgreSQL LXC setup complete."

sleep 3

# Add TMUX STUFF for benchmark call here
print_message "$hammerDB_IP"

sleep 3

print_message "Detected the following hammerDB-Server IP Adress: $hammerDB_IP"

tmux new-session -d -s BenchmarkSession

tmux split-window -h

tmux select-pane -t 0

print_message "Interruptor Script is Running! 10 minutes left..."

tmux send-keys -t BenchmarkSession:0.0 "sudo bash run_interruptor.sh" Enter

tmux select-pane -t 1

tmux send-keys -t BenchmarkSession:0.1 "ssh -t niklas@$hammerDB_IP \"cd /opt/HammerDB-4.9/scripts/tcl/postgres/tprocc && sudo bash run_benchmark.sh 2>&1 | tee full_benchmark.log\"" Enter

tmux attach-session -t BenchmarkSession

  