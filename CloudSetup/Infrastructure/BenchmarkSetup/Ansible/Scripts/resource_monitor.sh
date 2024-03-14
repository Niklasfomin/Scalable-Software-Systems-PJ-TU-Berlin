#!/bin/bash

docker_stats_file="docker_container_stats.csv"
lxc_stats_file="lxc_container_stats.csv"

monitor_docker() {
    local container_id=$1
    echo "Monitoring Docker container $container_id."

    echo "Time,Container ID,CPU Usage (%),Memory Usage" > "$docker_stats_file"

    while true; do
        local start_time=$(date +%s)
        local current_time=$(date "+%Y-%m-%d %H:%M:%S")
        
        local stats=$(docker stats --no-stream --format "{{.ID}},{{.CPUPerc}},{{.MemUsage}}" $container_id | awk -F, '{gsub(/[\r\n]+$/, "", $3); print $1","$2","$3}')
        
        echo "$current_time,$stats" >> "$docker_stats_file"
        
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local sleep_duration=$((2 - duration > 0 ? 2 - duration : 0))
        sleep $sleep_duration
    done
}



monitor_lxd() {
    local container_name=$1

    echo "Time,Container Name,CPU Usage (seconds),Memory Usage (current),Memory Usage (peak)" > "$lxc_stats_file"

    echo "Monitoring LXD container $container_name."
    while true; do
        
        local info=$(lxc info "$container_name" --resources)
        local cpu_usage=$(echo "$info" | grep 'CPU usage (in seconds)' | awk '{print $5}')
        local memory_current=$(echo "$info" | grep 'Memory (current)' | awk '{print $3 $4}')
        local memory_peak=$(echo "$info" | grep 'Memory (peak)' | awk '{print $3 $4}')
        local current_time=$(date "+%Y-%m-%d %H:%M:%S")

        echo "$current_time,$container_name,$cpu_usage,$memory_current,$memory_peak" >> "$lxc_stats_file"
        
        sleep 2  
    done
}


lxd_container_name=$(lxc list -c ns --format csv | grep ",RUNNING" | cut -d',' -f1 | head -n 1)

if [[ ! -z "$lxd_container_name" ]]; then
    echo "LXD container detected: $lxd_container_name"
    monitor_lxd "$lxd_container_name"
else
    echo "No LXD containers detected."
fi


detect_lxd() {
    lxc list -c ns --format csv | grep ",RUNNING" | cut -d',' -f1 | head -n 1
}


detect_and_monitor() {
    local docker_container_id=$(docker ps -q)
    if [[ ! -z "$docker_container_id" ]]; then
        echo "Docker container detected: $docker_container_id"
        monitor_docker "$docker_container_id"
        return
    fi

    local lxd_container_name=$(detect_lxd)
    if [[ ! -z "$lxd_container_name" ]]; then
        echo "LXD container detected: $lxd_container_name"
        monitor_lxd "$lxd_container_name"
        return
    fi

    echo "No Docker or LXD containers detected."
}

detect_and_monitor