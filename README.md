# ttf-docker-server-watchdog

一个泰坦掉了俩docker服务器的保活脚本

# 遇到问题？

如果确认依赖项安装正常的情况下遇到一些问题（比如服务器无限重启，或者根本不重启（当然后者不太可能（当然也有可能比如说ns的列表查询炸了）））

1.确认是否正确的写入crontab

2.确认文件是否在他应该在的位置，并且没有损坏，也没有内容更改

3.检查容器名是否正确的加入了watchdog字符串

4.确认nscn主服务器状态

5.如以上都无问题，请挨个删除服务器名中的特殊字符来排错

> 比如说我偶然发现`[`字符开头的服务器名会导致无限重启（当然针对这个特殊情况已经修复了），当然因为只发现了这一个所以别的特殊情况我是不特别清楚的，已知是大部分特殊字符没问题

6.如果还没修好那我是真没头绪了

# 食用方法

## Step 1

下载依赖项（用来解码Unicode）

如果你是Debian用户，直接在shell输入（如果非root用户请在指令最前加上`sudo `）

`apt-get update`

`apt-get install uni2ascii`

其他版本的Linux请查看[官网](https://www.billposer.org/Software/uni2ascii.html#downloads)并选择自己的版本（因为我跑的是Debian所以我只知道Debian怎么下）

## Step 2

将此仓库中的autorestart.sh放在你喜欢的位置

在shell中输入`crontab -e`

新建行，将以下项目加入

`* * * * * bash 文件所在路径`

例如，我将文件放在了/home

那么，我就可以填入

`* * * * * bash /home/autorestart.sh`

**注意！** 如果编辑crontab的用户不是root用户，你可能需要加上`sudo `在`bash /home/autorestart.sh`前

## Step 3

将你要保活的服务器的容器名加上watchdog字样（加哪里都可以反正只要有就行）

## Step 4

关掉你的ssh然后就可以安心的去睡大觉或者吃麦当当了
