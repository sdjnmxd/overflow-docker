FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

RUN apt-get update && apt-get install -y \
    procps \
    unzip \
    wget \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

ENV DOCKERIZE_VERSION v0.7.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY README.md LICENSE ./

RUN mkdir -p overflow/content overflow/plugins overflow/config/net.mamoe.mirai-api-http

ARG MAVEN_REPO
ARG OVERFLOW_VERSION
ARG MIRAI_VERSION
ARG BOUNCYCASTLE_VERSION

# for debug
ARG MAVEN_REPO=https://mirrors.huaweicloud.com/repository/maven
ARG OVERFLOW_VERSION=1.0.5
ARG MIRAI_VERSION=2.16.0
ARG BOUNCYCASTLE_VERSION=1.64

RUN echo "开始下载核心依赖..." \
    && echo "Maven仓库: ${MAVEN_REPO}" \
    && echo "Overflow版本: ${OVERFLOW_VERSION}" \
    && echo "Mirai版本: ${MIRAI_VERSION}" \
    && echo "BouncyCastle版本: ${BOUNCYCASTLE_VERSION}" \
    && cd overflow/content \
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
       "${MAVEN_REPO}/net/mamoe/mirai-console-terminal/${MIRAI_VERSION}/mirai-console-terminal-${MIRAI_VERSION}-all.jar" \
    && echo "核心依赖下载完成" \
    && ls -l

RUN echo "开始下载插件..." \
    && cd overflow/plugins \
    && echo "获取 mirai-api-http 最新版本..." \
    && LATEST_TAG=$(curl -s https://api.github.com/repos/project-mirai/mirai-api-http/releases/latest | jq -r '.tag_name') \
    && echo "检测到 mirai-api-http 最新版本 tag: ${LATEST_TAG}" \
    && echo "下载 mirai-api-http-${LATEST_TAG#v}.mirai2.jar..." \
    && wget --no-check-certificate --progress=bar:force:noscroll \
       "https://github.com/project-mirai/mirai-api-http/releases/download/${LATEST_TAG}/mirai-api-http-${LATEST_TAG#v}.mirai2.jar" \
    && echo "插件下载完成" \
    && ls -l

COPY config/net.mamoe.mirai-api-http/setting.yml overflow/config/net.mamoe.mirai-api-http/
COPY overflow.json.tmpl overflow/overflow.json.tmpl

WORKDIR /app/overflow

COPY start.sh .
RUN chmod +x start.sh

# 预热依赖
RUN cd /app/overflow && \
    mkdir -p plugin-libraries plugin-shared-libraries && \
    java -cp "./content/*" net.mamoe.mirai.console.terminal.MiraiConsoleTerminalLoader 2>&1 | tee /tmp/mirai.log & \
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

VOLUME ["/app/overflow/data", "/app/overflow/config", "/app/overflow/plugins", "/app/overflow/logs"]

ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"
ENV LANG=C.UTF-8

CMD ["./start.sh"]