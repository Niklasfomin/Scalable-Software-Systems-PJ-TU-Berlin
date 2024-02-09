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

handle_traffic() {
        print_message "Incoming database traffic is detected."
        print_message "Starting timer for 5 minutes..."
        sleep 300
        print_message "Timer expired. Starting interruptor now."
        run_interruptor
}

main() {
        PORT=5432

        print_message "Listening on port $PORT for incoming database traffic..."
        nc -l -p $PORT -w o && handle_traffic
}

main
