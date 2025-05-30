FROM eclipse-temurin:17-jdk-jammy

# 设置工作目录
WORKDIR /app

# 复制README和LICENSE文件
COPY README.md LICENSE ./

# 设置版本参数
ARG OVERFLOW_VERSION="1.0.5"
ARG MIRAI_VERSION="2.16.0"

# 安装必要的工具
RUN apt-get update && apt-get install -y \
    curl \
    procps \
    tzdata \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 创建目录
RUN mkdir -p /app/data /app/config /app/plugins

# 下载并安装 MCL
RUN mkdir mcl && \
    cd mcl && \
    wget https://github.com/MrXiaoM/mirai-console-loader/releases/download/v2.1.2-patch1/with-overflow.zip && \
    unzip with-overflow.zip && \
    chmod +x mcl && \
    ./mcl -u --dry-run && \
    ./mcl

# 复制启动脚本和健康检查脚本
COPY healthcheck.sh start.sh /app/
RUN chmod +x /app/start.sh /app/healthcheck.sh

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /app/healthcheck.sh

# 设置数据卷 
VOLUME ["/app/data", "/app/config", "/app/plugins"]

# 设置启动命令
CMD ["/bin/sh"]