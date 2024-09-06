#!/bin/bash
set -e;
onlineServers="";

function main()
{
    # array is not work very well, so we use string, IFS will help us
    offlineList="";
    # refresh online server list
    onlineServers=$(GetOnlineServerNames)
    for container in $(docker ps -a --format "{{.Names}}" --filter name=watchdog); do
        if $(IsServerOnline $container); then
            echo "server online: "$container;
            continue
        else
            echo "server offline: "$container;
            offlineList+=$container" "
        fi
    done;

    # no server offline, return here
    if [ "$offlineList" == "" ]; then
        echo "found no server offline, quit the script";
        return
    fi;

    sleep 1m;
    # refresh again (cuz we do a double check here)
    onlineServers=$(GetOnlineServerNames);
    for container in $offlineList; do
        if $(IsServerOnline $container); then
            echo "server is back to online: "$container;
            continue
        else
            echo "server still offline: "$container;
            # idk why, but the container doesnt automatically clean up `/tmp` on quit or start
            # `/tmp` will continue to grow until there is no space left ( you definitely dont want to know what took over 800GB of space on my server )
            docker exec $container sudo rm -rf /tmp &&
            echo "cleaned tmp file: "$container;
            docker exec $container sudo mkdir -m 777 /tmp &&
            echo "create tmp file: "$container;
            docker restart $container &&
            echo "successes restarted: "$container
        fi
    done
}

function IsServerOnline()
{
    name=$(GetServerName "$1");
	# when server name start with "[" will bugged at grep, so we add a "\" before the "[" to fix the problem
    if [ ${name:0:1} == "[" ]; then
        name="\\$name"
    fi;
    OIFS=$IFS;
    IFS="";
    if $(echo "$onlineServers" | grep -q "$name"); then
        echo true
    else
        echo false
    fi;
    IFS=$OIFS;
    unset OIFS
}

function GetServerName()
{
    envs=$(docker inspect "$1");
    name=${envs#*NS_SERVER_NAME=};
    name=${name%%"\","*};
    # i really dont konw why FS="\\\\\\" not FS="\\\\", but is worked, so i dont care
    name=$(echo "$name" | awk 'BEGIN {FS="\\\\\\"; OFS="\\"} {$1=$1; print $0}');
    echo $(echo "$name" | ascii2uni -a U -q)
}

function GetOnlineServerNames()
{
    srvlist=$(curl -s https://nscn.wolf109909.top/client/servers);
    kvlist=$(echo "$srvlist" | awk 'BEGIN {FS=",\""; OFS=",\n\""} {$1=$1; print $0}' | awk 'BEGIN {FS="},{"; OFS="},\n{"} {$1=$1; print $0}');
    validname="";
    OIFS=$IFS;
    IFS=$'\n';
    for name in "$kvlist"; do
        name1=$(echo "$name" | awk 'BEGIN {FS="\"name\":\""; OFS=""} {$1=$1; print $0}');
        if [ "$name1" == "$name" ]; then
            continue
        fi;
        validname+="$name1"
    done;
    IFS=$OIFS;
    unset OIFS;
    validname=$(echo "$validname" | awk 'BEGIN {FS="\","; OFS="\n"} {$1=$1; print $0}');
    echo "$validname"
}

main
