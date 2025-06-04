#!/bin/sh

# 检查MCL进程是否在运行
if ! pgrep -f "mcl" > /dev/null; then
    echo "MCL process not found"
    exit 1
fi

# 检查Java进程是否在运行
if ! pgrep -f "mirai-console" > /dev/null; then
    echo "Mirai Console process not found"
    exit 1
fi

# 检查内存使用情况
mem_usage=$(ps -o rss= -p $(pgrep -f "mirai-console"))
if [ -n "$mem_usage" ] && [ "$mem_usage" -gt 2097152 ]; then  # 2GB = 2097152KB
    echo "Memory usage too high: ${mem_usage}KB"
    exit 1
fi

exit 0 