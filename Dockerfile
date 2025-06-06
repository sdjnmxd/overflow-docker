FROM eclipse-temurin:17-jdk-jammy

# 设置环境变量
ENV DOCKERIZE_VERSION="v0.7.0" \
    JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8" \
    LANG=C.UTF-8

WORKDIR /app

# 安装基础工具
RUN apt-get update && apt-get install -y \
    procps \
    unzip \
    wget \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# 创建目录结构
RUN mkdir -p overflow/content \
    overflow/plugins \
    overflow/config/net.mamoe.mirai-api-http \
    overflow/plugin-libraries \
    overflow/plugin-shared-libraries \
    overflow/bots \
    overflow/data \
    overflow/logs

# 复制配置模板和文档
COPY config/net.mamoe.mirai-api-http/setting.yml.tmpl overflow/config/net.mamoe.mirai-api-http/
COPY overflow.json.tmpl overflow/overflow.json.tmpl
COPY README.md LICENSE ./
COPY start.sh overflow/

# 设置工作目录和权限
WORKDIR /app/overflow
RUN chmod +x start.sh

# 构建参数
ARG MAVEN_REPO
ARG OVERFLOW_VERSION
ARG MIRAI_VERSION
ARG BOUNCYCASTLE_VERSION

# for debug
ARG MAVEN_REPO=https://mirrors.huaweicloud.com/repository/maven
ARG OVERFLOW_VERSION=1.0.5
ARG MIRAI_VERSION=2.16.0
ARG BOUNCYCASTLE_VERSION=1.64

# 下载核心依赖
RUN cd content \
    && echo "下载 overflow-core-all-${OVERFLOW_VERSION}-all.jar..." \
    && wget --no-check-certificate --progress=bar:force:noscroll \
       "${MAVEN_REPO}/top/mrxiaom/mirai/overflow-core-all/${OVERFLOW_VERSION}/overflow-core-all-${OVERFLOW_VERSION}-all.jar" \
    && echo "下载 bcprov-jdk15on-${BOUNCYCASTLE_VERSION}.jar..." \
    && wget --no-check-certificate --progress=bar:force:noscroll \
       "${MAVEN_REPO}/org/bouncycastle/bcprov-jdk15on/${BOUNCYCASTLE_VERSION}/bcprov-jdk15on-${BOUNCYCASTLE_VERSION}.jar" \
    && echo "下载 mirai-console-${MIRAI_VERSION}-all.jar..." \
    && wget --no-check-certificate --progress=bar:force:noscroll \
       "${MAVEN_REPO}/net/mamoe/mirai-console/${MIRAI_VERSION}/mirai-console-${MIRAI_VERSION}-all.jar" \
    && echo "下载 mirai-console-terminal-${MIRAI_VERSION}-all.jar..." \
    && wget --no-check-certificate --progress=bar:force:noscroll \
       "${MAVEN_REPO}/net/mamoe/mirai-console-terminal/${MIRAI_VERSION}/mirai-console-terminal-${MIRAI_VERSION}-all.jar"

# 下载插件
RUN cd plugins \
    && LATEST_TAG=$(curl -s https://api.github.com/repos/project-mirai/mirai-api-http/releases/latest | jq -r '.tag_name') \
    && echo "检测到 mirai-api-http 最新版本 tag: ${LATEST_TAG}" \
    && wget --no-check-certificate --progress=bar:force:noscroll \
       "https://github.com/project-mirai/mirai-api-http/releases/download/${LATEST_TAG}/mirai-api-http-${LATEST_TAG#v}.mirai2.jar"

# 预热依赖
RUN java -cp "./content/*" net.mamoe.mirai.console.terminal.MiraiConsoleTerminalLoader 2>&1 | tee /tmp/mirai.log & \
    MIRAI_PID=$! && \
    while true; do \
        if grep -q "正在运行" /tmp/mirai.log; then \
            kill $MIRAI_PID; \
            break; \
        fi; \
        if ! kill -0 $MIRAI_PID 2>/dev/null; then \
            echo "Mirai进程异常退出"; \
            exit 1; \
        fi; \
        sleep 1; \
    done && \
    rm /tmp/mirai.log && \
    echo "依赖预热完成"

# 配置数据卷和端口
VOLUME ["/app/overflow/bots", "/app/overflow/config", "/app/overflow/data", "/app/overflow/logs"]
EXPOSE 7827

CMD ["./start.sh"]