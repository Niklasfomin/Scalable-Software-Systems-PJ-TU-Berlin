#!/bin/bash

docker_stats_file="docker_container_stats.csv"
firecracker_stats_file="firecracker_stats.csv"
lxc_stats_file="lxc_container_stats.csv"

monitor_docker() {
    local container_id=$1
    echo "Monitoring Docker container $container_id."

    echo "Time,Container ID,CPU Usage (%),Memory Usage / Limit,Memory Usage (%)" > "$docker_stats_file"

    while true; do
        local current_time=$(date "+%Y-%m-%d %H:%M:%S")
        local stats=$(docker stats --no-stream --format "{{.ID}},{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}}" $container_id)
        echo "$current_time,$stats" >> "$docker_stats_file"
        sleep 2  
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

monitor_firecracker() {
    echo "Time,CPU Usage (%),Memory Usage (KB),Memory Usage (%)" > "$firecracker_stats_file"
    echo "Monitoring system resources."
    while true; do
        local current_time=$(date "+%Y-%m-%d %H:%M:%S")
        local cpu_usage=$(top -b -n 2 -d 1 | grep "Cpu(s)" | tail -n 1 | awk '{print 100 - $8}')
        local mem_usage=$(free | grep Mem | awk '{print $3}')
        local mem_total=$(free | grep Mem | awk '{print $2}')
        local mem_usage_perc=$(awk "BEGIN {print ($mem_usage/$mem_total)*100}")
        
        echo "$current_time,$cpu_usage,$mem_usage,$mem_usage_perc" >> "$resource_stats_file"
        sleep 2  
    done
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

    echo "No Docker or LXD containers detected, so Firecracker must be running."
    monitor_firecracker
}

detect_and_monitor