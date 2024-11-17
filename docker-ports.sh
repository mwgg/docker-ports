#!/bin/bash

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "Docker is not running. Please start Docker and try again."
    exit 1
fi

SORT_BY_CONTAINER=false
SHOW_UNEXPOSED=false

while getopts ":cu" opt; do
    case "$opt" in
        c) SORT_BY_CONTAINER=true ;;
        u) SHOW_UNEXPOSED=true ;;
        *) 
            echo "Usage: $0 [-c] [-u]"
            echo "  -c  Sort output by container name"
            echo "  -u  Show ports not exposed to the host"
            exit 1
            ;;
    esac
done

# Get the list of running containers
containers=$(docker ps --format "{{.ID}} {{.Names}}")

output=()

while read -r container_id container_name; do
    # Get the compose project if available
    compose_project=$(docker inspect "$container_id" \
        --format '{{ index .Config.Labels "com.docker.compose.project" }}')

    if [[ -n "$compose_project" ]]; then
        compose_file=${compose_project}
    else
        compose_file="N/A"
    fi

    # Get the port mappings
    ports=$(docker inspect "$container_id" \
        --format '{{range $p, $v := .NetworkSettings.Ports}}{{if $v}}{{(index $v 0).HostIp}}:{{(index $v 0).HostPort}}->{{$p}} {{else}}{{$p}} {{end}}{{end}}' \
        | tr -d '[]' | tr ' ' '\n')

    if [[ -n "$ports" ]]; then
        while read -r port; do
            # Skipping if port is not exposed to the host
            if [[ "$port" == *"->"* ]]; then
                host_port=$(echo "$port" | sed -E 's/.*:([0-9]+)->.*/\1/')
                container_port=$(echo "$port" | sed -E 's/.*->([0-9]+)\/.*$/\1/')
                host_ip=$(echo "$port" | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+):.*$/\1/')
                protocol=$(echo "$port" | sed -E 's/.*\/(.*)$/\U\1/')
                output+=("$host_port $container_port $protocol $host_ip $container_name $compose_file")
            elif $SHOW_UNEXPOSED; then
                container_port=$(echo "$port" | sed -E 's/([0-9]+)\/.*$/\1/')
                protocol=$(echo "$port" | sed -E 's/.*\/(.*)$/\U\1/')
                output+=("- $container_port $protocol - $container_name $compose_file")
            fi
        done <<< "$ports"
    fi
done <<< "$containers"

# Sort and display the output
if $SORT_BY_CONTAINER; then 
    sort_columns="-k 5,5 -k 1,1n -k 2,2n"
else
    sort_columns="-k 1,1n"
fi

{
    echo "Host | Container | Protocol | Host IP | Container Name | Compose Project"

    (for entry in "${output[@]}"; do
        IFS=' ' read -r host_port container_port protocol host_ip container_name compose_project <<< "$entry"
        echo "$host_port | $container_port | $protocol | $host_ip | $container_name | $compose_project"
    done) | sort -t '|' $sort_columns
} | column -s '|' -t
