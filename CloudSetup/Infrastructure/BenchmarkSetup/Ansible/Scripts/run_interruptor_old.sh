#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

run_interruptor() {
    sleep 300
    print_message "Running the interruptor application..."
    go run exhaustor.go
}

start_resource_monitor() {
    print_message "Starting the resource monitor script..."
    sudo bash resource_monitor.sh &
    RESOURCE_MONITOR_PID=$!
    sleep 900
    print_message "Stopping the resource monitor script..."
    sudo kill $RESOURCE_MONITOR_PID
}

# stop_resource_monitor() {
#     if [ -n "$RESOURCE_MONITOR_PID" ]; then
#         print_message "Stopping the resource monitor script..."
#         kill "$RESOURCE_MONITOR_PID"
#     fi
# }

listen_for_traffic() {
    PORT=5432

    print_message "Listening on port $PORT for incoming database traffic..."

    while true; do
        sudo tcpdump -i any "tcp port $PORT" -n -c 1 -q >/dev/null 2>&1
        print_message "Incoming traffic detected."
        start_resource_monitor &
        run_interruptor
        break
    done
}

# stop_monitor() {
#     PORT=5432
#     print_message "Monitoring port $PORT for absence of traffic..."

#     while sudo tcpdump -i any "tcp port $PORT" -n -c 1 -q -G 30 >/dev/null 2>&1; do
#         print_message "Traffic detected, continue monitoring..."
#     done

#     print_message "No traffic detected. Benchmark run finished, monitoring stopped."
#     # stop_resource_monitor
#     # kill -SIGTERM $$ 
# }    # Wait for 15 minutes (900 seconds) before killing the resource monitor


main () {
    print_message "Script Running"
    sleep 300
    #start_resource_monitor
    listen_for_traffic
    #stop_monitor
}

main