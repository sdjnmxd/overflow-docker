#!/bin/bash

FIFO_FILE="/tmp/mirai_cmd_pipe"
[ -p "$FIFO_FILE" ] || mkfifo "$FIFO_FILE"

# 定义信号处理函数
handle_sigterm() {
    echo "收到 SIGTERM 信号，正在优雅关闭..."
    # 向 Mirai Console 发送 /stop 命令
    echo "/stop" > "$FIFO_FILE"
    # 等待进程退出
    wait $mirai_pid
}

# 注册 SIGTERM 信号处理
trap 'handle_sigterm' SIGTERM

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
cat "$FIFO_FILE" | java -cp "./content/*" net.mamoe.mirai.console.terminal.MiraiConsoleTerminalLoader &
mirai_pid=$!

# 等待程序退出
wait $mirai_pid