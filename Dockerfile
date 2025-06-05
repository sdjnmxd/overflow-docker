FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    procps \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

COPY README.md LICENSE ./

RUN mkdir -p overflow/content

ARG MAVEN_REPO
ARG OVERFLOW_VERSION
ARG MIRAI_VERSION
ARG BOUNCYCASTLE_VERSION
# for debug
ARG MAVEN_REPO=https://mirrors.huaweicloud.com/repository/maven
ARG OVERFLOW_VERSION=1.0.5
ARG MIRAI_VERSION=2.16.0
ARG BOUNCYCASTLE_VERSION=1.64

RUN echo "Using Overflow version: ${OVERFLOW_VERSION}" \
    && echo "Using Mirai version: ${MIRAI_VERSION}" \
    && echo "Using BouncyCastle version: ${BOUNCYCASTLE_VERSION}" \
    && cd overflow/content \
    && wget --no-check-certificate --progress=bar:force:noscroll \
       "${MAVEN_REPO}/top/mrxiaom/mirai/overflow-core-all/${OVERFLOW_VERSION}/overflow-core-all-${OVERFLOW_VERSION}-all.jar" \
       "${MAVEN_REPO}/org/bouncycastle/bcprov-jdk15on/${BOUNCYCASTLE_VERSION}/bcprov-jdk15on-${BOUNCYCASTLE_VERSION}.jar" \
       "${MAVEN_REPO}/net/mamoe/mirai-console/${MIRAI_VERSION}/mirai-console-${MIRAI_VERSION}-all.jar" \
       "${MAVEN_REPO}/net/mamoe/mirai-console-terminal/${MIRAI_VERSION}/mirai-console-terminal-${MIRAI_VERSION}-all.jar"

WORKDIR /app/overflow

COPY start.sh .
RUN chmod +x start.sh

VOLUME ["/app/overflow/data", "/app/overflow/config", "/app/overflow/plugins", "/app/overflow/logs"]

ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"
ENV LANG=C.UTF-8

CMD ["./start.sh"]