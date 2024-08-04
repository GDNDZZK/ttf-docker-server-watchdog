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
    sleep 1m;
    # refresh again (cuz we do a double check here)
    onlineServers=$(GetOnlineServerNames);
    for container in $offlineList; do
        if $(IsServerOnline $container); then
            echo "server back to online: "$container;
            continue
        else
            echo "server still offline: "$container;
            docker restart $container
        fi
    done
}

function IsServerOnline()
{
    name=$(GetServerName $1);
    # when server name start with "[" will bugged at grep, so we add a "\" before the "[" to fix the problem
    if [ ${name:0:1} == "[" ]; then
        name="\\"$name
    fi;
    OIFS=$IFS;
    IFS="";
    if $(echo $onlineServers | grep -q $name); then
        echo true
    else
        echo false
    fi;
    IFS=$OIFS;
    unset OIFS
}

function GetServerName()
{
    envs=$(docker inspect $1);
    name=${envs#*NS_SERVER_NAME=};
    name=${name%%"\","*};
    # i really dont konw why FS="\\\\\\" not FS="\\\\", but is worked, so i dont care
    name=$(echo $name | awk 'BEGIN {FS="\\\\\\"; OFS="\\"} {$1=$1; print $0}');
    echo $(echo $name | ascii2uni -a U -q)
}

function GetOnlineServerNames()
{
    srvlist=`curl -s https://nscn.wolf109909.top/client/servers`;
    kvlist=$(echo $srvlist | awk 'BEGIN {FS=",\""; OFS=",\n\""} {$1=$1; print $0}' | awk 'BEGIN {FS="},{"; OFS="},\n{"} {$1=$1; print $0}');
    validdesc="";
    OIFS=$IFS;
    IFS=$'\n';
    for desc in $kvlist; do
        desc1=$(echo $desc | awk 'BEGIN {FS="\"name\":\""; OFS=""} {$1=$1; print $0}');
        if [ $desc1 == $desc ]; then
            continue
        fi;
        validdesc+=$desc1
    done;
    IFS=$OIFS;
    unset OIFS;
    validdesc=$(echo $validdesc | awk 'BEGIN {FS="\","; OFS="\n"} {$1=$1; print $0}');
    echo $validdesc
}

main
