FROM eclipse-temurin:17-jdk-jammy

# 设置工作目录
WORKDIR /app

# 复制README和LICENSE文件
COPY README.md LICENSE ./

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    procps \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 复制健康检查脚本
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh

# 创建必要的目录
RUN mkdir -p data config plugins mcl

# 下载并安装MCL
WORKDIR /app/mcl
RUN wget --no-check-certificate --progress=bar:force:noscroll \
    https://ghfast.top/https://github.com/MrXiaoM/mirai-console-loader/releases/download/v2.1.2-patch1/with-overflow.zip \
    -O with-overflow.zip \
    && unzip with-overflow.zip \
    && rm with-overflow.zip \
    && chmod +x mcl

# 返回主工作目录
WORKDIR /app

# 复制启动脚本
COPY start.sh .
RUN chmod +x start.sh

# 设置数据卷
VOLUME ["/app/data", "/app/config", "/app/plugins"]

# 设置环境变量
ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"
ENV LANG=C.UTF-8

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /healthcheck.sh

# 启动命令
CMD ["./start.sh"]