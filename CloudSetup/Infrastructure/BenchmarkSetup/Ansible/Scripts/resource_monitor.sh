#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
output_file="$SCRIPT_DIR/resource_metrics.csv"

touch "$output_file"
sudo chmod 777 "$output_file"

detect_container_type() {
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        echo "docker"
    elif command -v lxc &> /dev/null && lxc info &> /dev/null; then
        echo "lxc"
    else
        echo "unknown"
    fi
}

log_docker_containers() {
    sudo docker ps --format "{{.Names}}" | while read container_name; do
        timestamp=$(date "+%Y-%m-%d %H:%M:%S")
        sudo docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" "$container_name" | tail -n +2 | awk -v ts="$timestamp" '{print ts, $0}' >> "$output_file"
    done
}

log_lxc_containers() {
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    cgtop_output=$(systemd-cgtop --batch --depth=1 -p -n 1 | grep -E 'lxc.payload|machine.slice' | awk '{print $1, $2, $3, $4}')  
    echo "$timestamp, $cgtop_output" >> "$output_file"
}

main() {
    local container_type="$(detect_container_type)"

    echo "Detected container type: $container_type"

    if [ "$container_type" == "unknown" ]; then
        echo "Error: Container type not detected. Make sure Docker or LXC is installed and running."
        exit 1
    fi

    echo "Monitoring resource consumption..."

    while true; do
        if [ "$container_type" == "docker" ]; then
            log_docker_containers
        elif [ "$container_type" == "lxc" ]; then
            log_lxc_containers
        fi
        sleep 60  
    done
}

main
