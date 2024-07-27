# ttf-docker-server-watchdog

一个泰坦掉了俩docker服务器的保活脚本

# 使用方法

# Step 1

在shell中输入`crontab -e`

新建行，将以下项目加入

`* * * * * bash 文件所在路径`

例如，我将文件放在了/home

那么，我就可以填入

`* * * * * bash /home/autorestart.sh`

## Step 2

将你要保活的服务器的容器名加上watchdog字样（加哪里都可以反正只要有就行）

## Step 3

关掉你的ssh然后就可以安心的去睡大觉或者吃麦当当了
