#!/usr/bin/env bash
# Docker 构建期预热：拉起 Mirai 控制台直至就绪后退出（仅用于 warmup 阶段）
set -euo pipefail

cd "$(dirname "$0")"
LOG=/tmp/mirai.log
rm -f "$LOG"

java -cp "./content/*" net.mamoe.mirai.console.terminal.MiraiConsoleTerminalLoader 2>&1 | tee "$LOG" &
MIRAI_PID=$!

i=0
while true; do
  if grep -q "正在运行" "$LOG" || grep -q "mirai-console started successfully" "$LOG"; then
    kill "$MIRAI_PID"
    break
  fi
  if ! kill -0 "$MIRAI_PID" 2>/dev/null; then
    echo "Mirai进程异常退出"
    tail -80 "$LOG" || true
    exit 1
  fi
  i=$((i + 1))
  if [ "$i" -ge 300 ]; then
    echo "预热超时（300s），最近日志："
    tail -80 "$LOG" || true
    kill "$MIRAI_PID" 2>/dev/null || true
    exit 1
  fi
  sleep 1
done

rm -f "$LOG"
echo "依赖预热完成"
