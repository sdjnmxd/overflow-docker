#!/bin/bash

# 生成配置文件
dockerize -template /app/overflow/overflow.json.tmpl:/app/overflow/overflow.json \
         -template /app/overflow/config/net.mamoe.mirai-api-http/setting.yml.tmpl:/app/overflow/config/net.mamoe.mirai-api-http/setting.yml

# 显示配置
echo "当前 Overflow 配置:"
jq . /app/overflow/overflow.json

echo -e "\n当前 mirai-api-http 配置:"
cat /app/overflow/config/net.mamoe.mirai-api-http/setting.yml

# 启动程序
cd /app/overflow
java -cp "./content/*" net.mamoe.mirai.console.terminal.MiraiConsoleTerminalLoader