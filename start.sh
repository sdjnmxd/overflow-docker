#!/bin/bash

if [ -z "$JAVA_OPTS" ]; then
    export JAVA_OPTS="-Xms512M -Xmx1G"
fi

java $JAVA_OPTS -cp "./content/*" net.mamoe.mirai.console.terminal.MiraiConsoleTerminalLoader