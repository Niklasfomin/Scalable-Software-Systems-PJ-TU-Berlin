#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Function to get container name by image name
get_container_name() {
   sudo docker ps --format '{{.Names}}' --filter ancestor="$1"
}

# Variables
PG_IMAGE="postgres:latest"
PG_USER="postgres"
PG_PWD="postgres"
DB_NAME="postgres"
DEFAULT_CONTAINER_NAME="pgcontainer"
hammerDB_IP=$(cat hammerDB_server_ip.txt)

print_message "Starting PostgreSQL docker container..."

# Get container name dynamically
CONTAINER_NAME=$(get_container_name "$PG_IMAGE")

if [ -z "$CONTAINER_NAME" ]; then
    print_message "PostgreSQL container not found. Starting a new one..."
    CONTAINER_NAME="$DEFAULT_CONTAINER_NAME"
    sudo docker run -d \
        --name "$CONTAINER_NAME" \
        -e POSTGRES_USER="$PG_USER" \
        -e POSTGRES_PASSWORD="$PG_PWD" \
        -e POSTGRES_DB="$DB_NAME" \
        -p 5432:5432 \
        "$PG_IMAGE"
else
    print_message "Using existing PostgreSQL container: $CONTAINER_NAME"

fi

print_message "Waiting for PostgreSQL to initialize..."
sleep 5

# Setup of benchmark-table
print_message "Setting up TPCC-table for TPROCC-benchmark"
sudo docker exec -i "$CONTAINER_NAME" psql -U "$PG_USER" -d "$DB_NAME" <<EOF

-- SQL commands to setup benchmark-db + user + permissions
CREATE DATABASE tpcc;
CREATE USER tpcc WITH PASSWORD 'tpcc';
GRANT ALL PRIVILEGES ON DATABASE tpcc TO tpcc;
EOF

print_message "PostgreSQL setup complete. Switch to the benchmark server."

# sleep 3

# print_message "$hammerDB_IP"

# sleep 3

# print_message "Detected the following hammerDB-Server IP Adress: $hammerDB_IP"

#tmux new-session -d -s BenchmarkSession

#tmux split-window -h

#tmux select-pane -t 0

# tmux send-keys -t BenchmarkSession:0.0 "sudo bash run_interruptor.sh" Enter

#tmux select-pane -t 1

#tmux send-keys -t BenchmarkSession:0.1 "ssh -t niklas@$hammerDB_IP \"cd /opt/HammerDB-4.9/scripts/tcl/postgres/tprocc && sudo bash run_benchmark.sh 2>&1 | tee full_benchmark.log\"" Enter
#ssh -t niklas@$hammerDB_IP "cd /opt/HammerDB-4.9/scripts/tcl/postgres/tprocc && sudo bash run_benchmark.sh 2>&1 | tee full_benchmark.log"
#tmux attach-session -t BenchmarkSession
