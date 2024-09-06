#!/bin/bash
set -euo pipefail
onlineServers=""

function main()
{
    offlineList=();
    # fetch online server list
    onlineServers="$(GetOnlineServerNames)" || { echo "failed to fetch online server names"; exit 1; }

    for container in $(docker ps -a --format "{{.Names}}" --filter name=watchdog); do
        echo "server name: $(GetServerName $container)";
        if $(IsServerOnline "$container"); then
            echo "server online: $container"
        else
            echo "server offline: $container"
            offlineList+=("$container")
        fi
    done;

    # no server offline, return here
    if [ "${#offlineList[@]}" -eq 0 ]; then
        echo "found no server offline, quit the script"
        return
    fi

    # sleep for a min and do a double check
    sleep 1m
    # refresh names (cuz we do a double check here)
    onlineServers="$(GetOnlineServerNames)" || { echo "failed to fetch online server names"; exit 1; }

    for container in "${offlineList[@]}"; do
        echo "server name: $(GetServerName $container)"
        if $(IsServerOnline "$container"); then
            echo "server back to online, doing nothing: $container"
        else
            echo "server still offline: $container"
            # idk why, but the container doesnt automatically clean up `/tmp` on quit or start
            # `/tmp` will continue to grow until there is no space left ( you definitely dont want to know what took over 800GB of space on my server )
            docker exec -- "$container" sudo rm -rf /tmp &&
            echo "cleaned tmp file: $container"
            docker exec -- "$container" sudo mkdir -m 777 /tmp &&
            echo "create tmp file: $container"
            docker restart "$container" &&
            echo "successes restarted: $container"
        fi
    done
}

function IsServerOnline()
{
    name="$(GetServerName "$1")"
    if $(echo "$onlineServers" | grep -Fq "$name"); then
        echo true
    else
        echo false
    fi
}

function GetServerName()
{
    config="$(docker inspect "$1")"
    name="$(echo "$config" | jq -r '.[0].Config.Env[] | select(startswith("NS_SERVER_NAME=")) | sub("NS_SERVER_NAME="; "")')"
    echo "$(echo "$name" | ascii2uni -a U -q)"
}

function GetOnlineServerNames()
{
    curl -s https://nscn.wolf109909.top/client/servers | jq -r '.[].name'
}

main
