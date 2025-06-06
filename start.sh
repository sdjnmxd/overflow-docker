#!/bin/bash

dockerize -template /app/overflow/overflow.json.tmpl:/app/overflow/overflow.json

# 显示最终配置
echo "当前配置:"
jq . /app/overflow/overflow.json

# 启动程序
cd /app/overflow
java -cp "./content/*" net.mamoe.mirai.console.terminal.MiraiConsoleTerminalLoader