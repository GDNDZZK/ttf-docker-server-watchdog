#!/bin/bash
set -euo pipefail
onlineServers=""

# 手动指定需要保活的容器名称列表
CONTAINERS=("container1" "container2" "container3")

function main()
{
    offlineList=();
    # 获取在线服务器列表
    onlineServers="$(GetOnlineServerNames)" || { echo "failed to fetch online server names"; exit 1; }

    # 遍历预定义容器列表（不再自动获取）
    for container in "${CONTAINERS[@]}"; do
        echo "检查容器: $container"
        echo "服务名称: $(GetServerName $container)";
        if $(IsServerOnline "$container"); then
            echo "在线状态: $container"
        else
            echo "离线状态: $container"
            offlineList+=("$container")
        fi
    done;

    # 没有离线服务器直接退出
    if [ "${#offlineList[@]}" -eq 0 ]; then
        echo "未检测到离线服务器，退出脚本"
        return
    fi

    # 二次确认等待
    sleep 1m
    onlineServers="$(GetOnlineServerNames)" || { echo "获取在线服务列表失败"; exit 1; }

    # 处理持续离线的容器
    for container in "${offlineList[@]}"; do
        echo "二次验证容器: $container"
        echo "服务名称: $(GetServerName $container)"
        if $(IsServerOnline "$container"); then
            echo "已恢复在线: $container"
        else
            echo "仍处于离线: $container"
            # 清理并重启容器
            sudo docker exec -- "$container" sudo rm -rf /tmp &&
            echo "已清理临时文件: $container"
            sudo docker exec -- "$container" sudo mkdir -m 777 /tmp &&
            echo "已重建临时目录: $container"
            sudo docker restart "$container" &&
            echo "成功重启容器: $container"
        fi
    done
}

function IsServerOnline()
{
    name="$(GetServerName "$1")"
    if grep -Fq "$name" <<< "$onlineServers"; then
        echo true
    else
        echo false
    fi
}

function GetServerName()
{
    config="$(sudo docker inspect "$1")"
    name="$(echo "$config" | jq -r '.[0].Config.Env[] | select(startswith("NS_SERVER_NAME=")) | sub("NS_SERVER_NAME="; "")')"
    echo "$(echo "$name" | ascii2uni -a U -q)"
}

function GetOnlineServerNames()
{
    curl -s https://nscn.wolf109909.top/client/servers | jq -r '.[].name'
}

main
