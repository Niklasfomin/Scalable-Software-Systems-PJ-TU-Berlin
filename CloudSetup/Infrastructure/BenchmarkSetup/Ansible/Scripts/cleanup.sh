#!/bin/bash

cleanup_docker() {
    if command -v sudo docker &> /dev/null; then
        echo "Stopping and removing all Docker containers..."
        # Stop all running Docker containers
        sudo docker stop $(docker ps -aq) 2>/dev/null
        # Remove all Docker containers
        sudo docker rm $(docker ps -aq) 2>/dev/null
        echo "All Docker containers have been stopped and removed."
    else
        echo "Docker is not installed."
    fi
}

cleanup_lxc() {
    if command -v lxc &> /dev/null; then
        echo "Stopping and destroying all LXC containers..."
        # Stop all running LXC containers
        lxc list --format csv -c ns | grep RUNNING | cut -d',' -f1 | xargs -I {} lxc stop {} 2>/dev/null
        # Destroy all LXC containers
        lxc list --format csv -c n | cut -d',' -f1 | xargs -I {} lxc delete {} 2>/dev/null
        echo "All LXC containers have been stopped and destroyed."
    else
        echo "LXC is not installed."
    fi
}

main() {
    cleanup_docker
    cleanup_lxc
}


main
