#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

run_interruptor() {
    print_message "Running the interruptor application..."
    ./exhaustor.go
}

start_resource_monitor() {
    print_message "Starting the resource monitor script..."
    ./ressource_monitor.sh &
    RESOURCE_MONITOR_PID=$!
}

stop_resource_monitor() {
    if [ -n "$RESOURCE_MONITOR_PID" ]; then
        print_message "Stopping the resource monitor script..."
        kill "$RESOURCE_MONITOR_PID"
    fi
}

main() {
    PORT=5432

    print_message "Listening on port $PORT for incoming database traffic..."

    traffic_detected=false

    while true; do
        # Check if port 5432 is open for connections
        local ip_address=$(nc -zv localhost $PORT 2>&1 | awk '/open/ {print $5}')
        if [ ! -z "$ip_address" ]; then
            if ! $traffic_detected; then
                print_message "Incoming database traffic detected from IP: $ip_address"
                start_resource_monitor
                traffic_detected=true
            fi
        else
            if $traffic_detected; then
                print_message "No database traffic detected on port $PORT. Stopping the resource monitor."
                stop_resource_monitor
                traffic_detected=false
            fi
        fi
        sleep 10
    done
}

main
