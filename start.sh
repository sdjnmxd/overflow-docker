#!/bin/sh

# 设置 Java 内存参数
if [ -z "$JAVA_OPTS" ]; then
    JAVA_OPTS="-Xms512M -Xmx1G"
fi

# 设置 JAVA_OPTS 环境变量供 MCL 使用
export JAVA_OPTS

# 启动 Mirai Console Loader
java -cp "$CLASSPATH:/app/libs/*" net.mamoe.mirai.console.terminal.MiraiConsoleTerminalLoader