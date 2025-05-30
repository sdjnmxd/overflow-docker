#!/bin/sh

# 检查 Java 进程是否运行
if ! pgrep -f "MiraiConsoleTerminalLoader" > /dev/null; then
    echo "Mirai Console process is not running"
    exit 1
fi

echo "Mirai Console is healthy"
exit 0 