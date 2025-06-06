FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    procps \
    unzip \
    wget \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

COPY README.md LICENSE ./

RUN mkdir -p overflow/content overflow/plugins

ARG MAVEN_REPO
ARG OVERFLOW_VERSION
ARG MIRAI_VERSION
ARG BOUNCYCASTLE_VERSION

# for debug
#ARG MAVEN_REPO=https://mirrors.huaweicloud.com/repository/maven
#ARG OVERFLOW_VERSION=1.0.5
#ARG MIRAI_VERSION=2.16.0
#ARG BOUNCYCASTLE_VERSION=1.64

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
    && LATEST_VERSION=${LATEST_TAG#v} \
    && echo "检测到 mirai-api-http 最新版本: ${LATEST_VERSION}" \
    && echo "下载 mirai-api-http-v${LATEST_VERSION}.mirai2.jar..." \
    && wget --no-check-certificate --progress=bar:force:noscroll \
       "https://github.com/project-mirai/mirai-api-http/releases/download/${LATEST_TAG}/mirai-api-http-v${LATEST_VERSION}.mirai2.jar" \
    && echo "插件下载完成" \
    && ls -l

WORKDIR /app/overflow

COPY start.sh .
RUN chmod +x start.sh

VOLUME ["/app/overflow/data", "/app/overflow/config", "/app/overflow/plugins", "/app/overflow/logs"]

ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"
ENV LANG=C.UTF-8

CMD ["./start.sh"]