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

print_message "PostgreSQL setup complete."

sleep 3

print_message "Run the benchmark NOW! The Interruptor will be launched in 10 minutes..."

./run_interruptor.sh

