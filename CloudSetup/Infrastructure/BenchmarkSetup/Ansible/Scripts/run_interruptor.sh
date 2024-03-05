#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

run_interruptor() {
    sleep 300
    go run exhaustor.go
}



main () {
    run_interruptor
}

main