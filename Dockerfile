FROM openjdk:11-jdk-slim

# 设置工作目录
WORKDIR /app

# 复制README和LICENSE文件
COPY README.md LICENSE ./

# 设置版本参数
ARG OVERFLOW_VERSION
ARG MIRAI_CONSOLE_VERSION
ARG BOUNCY_CASTLE_VERSION=1.64
ARG MAVEN_CENTRAL="https://repo1.maven.org/maven2"

# 安装必要的工具
RUN apk add --no-cache \
    curl \
    procps \
    tzdata

# 创建目录
RUN mkdir -p /app/content /app/data /app/config /app/plugins

# 下载所需的 jar 包
RUN cd /app/content && \
    # 下载 BouncyCastle
    curl -L -o bcprov-jdk15on-${BOUNCY_CASTLE_VERSION}.jar \
    ${MAVEN_CENTRAL}/org/bouncycastle/bcprov-jdk15on/${BOUNCY_CASTLE_VERSION}/bcprov-jdk15on-${BOUNCY_CASTLE_VERSION}.jar && \
    # 下载 Mirai Console
    curl -L -o mirai-console-${MIRAI_CONSOLE_VERSION}-all.jar \
    ${MAVEN_CENTRAL}/net/mamoe/mirai-console/${MIRAI_CONSOLE_VERSION}/mirai-console-${MIRAI_CONSOLE_VERSION}-all.jar && \
    # 下载 Mirai Console Terminal
    curl -L -o mirai-console-terminal-${MIRAI_CONSOLE_VERSION}-all.jar \
    ${MAVEN_CENTRAL}/net/mamoe/mirai-console-terminal/${MIRAI_CONSOLE_VERSION}/mirai-console-terminal-${MIRAI_CONSOLE_VERSION}-all.jar && \
    # 下载 Overflow Core
    curl -L -o overflow-core-all-${OVERFLOW_VERSION}-all.jar \
    https://github.com/MrXiaoM/Overflow/releases/download/v${OVERFLOW_VERSION}/overflow-core-all-${OVERFLOW_VERSION}-all.jar && \
    # 列出下载的文件
    ls -la

# 复制启动脚本和健康检查脚本
COPY healthcheck.sh start.sh /app/
RUN chmod +x /app/start.sh /app/healthcheck.sh

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /app/healthcheck.sh

# 设置数据卷
VOLUME ["/app/data", "/app/config", "/app/plugins"]

# 设置启动命令
CMD ["/app/start.sh"] 