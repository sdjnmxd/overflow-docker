#!/bin/sh

# 设置 Java 内存参数
if [ -z "$JAVA_OPTS" ]; then
    JAVA_OPTS="-Xms512M -Xmx1G"
fi

# 启动 Mirai Console
exec java $JAVA_OPTS \
    -Dmirai.slider.captcha.supported \
    -cp "/app/content/*" \
    net.mamoe.mirai.console.terminal.MiraiConsoleTerminalLoader 