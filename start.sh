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

echo "============================================================"
echo "🤖 Overflow Docker 容器化部署版本"
echo "============================================================"
echo "📦 项目仓库: https://github.com/sdjnmxd/overflow-docker"
echo "🐛 问题反馈: https://github.com/sdjnmxd/overflow-docker/issues"
echo "📚 使用文档: https://github.com/sdjnmxd/overflow-docker#readme"
echo ""
echo "ℹ️  这是 Overflow 的 Docker 容器化部署版本（镜像与部署由本仓库维护）"
echo "   若遇部署、Docker 镜像或本仓库配置问题，请优先到上述地址提交 Issue"
echo "   Overflow / Mirai 核心功能问题请前往各自上游仓库反馈"
echo "============================================================"
echo ""

# 生成配置文件
dockerize -template /app/overflow/overflow.json.tmpl:/app/overflow/overflow.json \
         -template /app/overflow/config/net.mamoe.mirai-api-http/setting.yml.tmpl:/app/overflow/config/net.mamoe.mirai-api-http/setting.yml

echo ""
echo "------------------------------------------------------------"
echo "当前 Overflow 配置（overflow.json）"
echo "------------------------------------------------------------"
jq . /app/overflow/overflow.json
echo ""

echo "------------------------------------------------------------"
echo "当前 mirai-api-http 配置（setting.yml）"
echo "------------------------------------------------------------"
cat /app/overflow/config/net.mamoe.mirai-api-http/setting.yml
echo ""

echo "------------------------------------------------------------"
echo "🚀 正在启动 Mirai Console + Overflow..."
echo "------------------------------------------------------------"
echo ""
cd /app/overflow
cat "$FIFO_FILE" | java ${JAVA_OPTS:-} -cp "./content/*" net.mamoe.mirai.console.terminal.MiraiConsoleTerminalLoader &
mirai_pid=$!

# 等待程序退出
wait $mirai_pid