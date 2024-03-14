#!/bin/bash

cleanup_docker() {
    if command -v docker &> /dev/null; then
        echo "Stopping and removing all Docker containers..."
        sudo docker stop $(sudo docker ps -aq) 2>/dev/null
        sudo docker rm $(sudo docker ps -aq) 2>/dev/null
        sudo docker volume prune -f
        echo "All Docker containers and volumes have been stopped, removed, and pruned."
    else
        echo "Docker is not installed."
    fi
}

cleanup_lxc() {
    if command -v lxc &> /dev/null; then
        echo "Stopping and destroying all LXC containers..."
        lxc list --format csv -c ns | grep RUNNING | cut -d',' -f1 | xargs -r lxc stop
        lxc list --format csv -c n | cut -d',' -f1 | xargs -r lxc delete
        lxc storage volume delete --all
        echo "All LXC containers and storage volumes have been stopped, destroyed, and deleted."
    else
        echo "LXC is not installed."
    fi
}


cleanup_files() {
    local docker_stats_file="docker_container_stats.csv"
    local lxc_stats_file="lxc_container_stats.csv"

    echo "Checking and cleaning up stats files if they exist..."

    [[ -f $docker_stats_file ]] && { echo "Removing $docker_stats_file"; sudo rm -f $docker_stats_file; }
    [[ -f $lxc_stats_file ]] && { echo "Removing $lxc_stats_file"; sudo rm -f $lxc_stats_file; }
}


main() {
    cleanup_files
    cleanup_docker
    cleanup_lxc
}

main
