# ttf-docker-server-watchdog

一个泰坦掉了俩docker服务器的保活脚本

# 原理

获取容器env中的`NS_SERVER_NAME`所对应的值，再通过uni2ascii解码Unicode

获取JSON格式的北极星CN服务器列表，寻找服务器名，未找到判断服务器失联，等待一分钟后重试

一分钟后重试依旧失联，重启服务器（防止毙掉正在开启的容器）

# 遇到问题？

如果确认依赖项安装正常的情况下遇到一些问题（比如服务器无限重启，或者根本不重启（当然后者不太可能（当然也有可能比如说ns的列表查询炸了）））

1.确认是否正确的写入crontab

2.确认文件是否在他应该在的位置，并且没有损坏，也没有内容更改

3.检查容器名是否加入了watchdog字样

4.确认nscn主服务器状态

5.确认服务器名是否全部都为unicode而不是unicode混英文字符

6.服务器名是否重复或被其他服务器名所包含

7.若以上都无问题，请挨个删除服务器名中的特殊字符来排错

如果还没修好那我是真没头绪了

# 食用方法

## Step 1

### 下载依赖

uni2ascii（用来解码Unicode）

请查看[这里](https://www.billposer.org/Software/uni2ascii.html#downloads)获得更多信息

jq（用来解码json）

请查看[这里](https://jqlang.github.io/jq/download/)获得更多信息

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

关掉你的ssh然后就可以安心的去吃麦当当了
