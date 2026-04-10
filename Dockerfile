# -----------------------------------------------------------------------------
# 阶段 1：warmup — 下载依赖并预热（含构建期工具，体积较大，默认不单独发布）
# 调试该阶段：docker build --target warmup -t overflow:warmup .
# -----------------------------------------------------------------------------
FROM eclipse-temurin:17-jdk-jammy AS warmup

ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8" \
    LANG=C.UTF-8

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    procps \
    unzip \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p overflow/content \
    overflow/plugins \
    overflow/config/net.mamoe.mirai-api-http \
    overflow/plugin-libraries \
    overflow/plugin-shared-libraries \
    overflow/bots \
    overflow/data \
    overflow/logs

COPY config/net.mamoe.mirai-api-http/setting.yml.tmpl overflow/config/net.mamoe.mirai-api-http/
COPY overflow.json.tmpl overflow/overflow.json.tmpl
COPY README.md LICENSE ./
COPY start.sh overflow/
COPY scripts/docker-warmup.sh overflow/docker-warmup.sh

WORKDIR /app/overflow
RUN chmod +x start.sh

# 构建参数
#ARG MAVEN_REPO
#ARG OVERFLOW_VERSION
#ARG BOUNCYCASTLE_VERSION

# for debug
ARG MAVEN_REPO=https://mirrors.huaweicloud.com/repository/maven
ARG OVERFLOW_VERSION=1.1.0
ARG BOUNCYCASTLE_VERSION=1.64
# Mirai Console 固定为 2.16.0（上游已长期无新版本）
# mirai-api-http 插件固定 release（上游已长期无新版本）
ARG MIRAI_API_HTTP_TAG=v2.10.0
ARG MIRAI_API_HTTP_VER=2.10.0

# 下载核心依赖
RUN cd content \
    && echo "下载 overflow-core-all-${OVERFLOW_VERSION}-all.jar..." \
    && wget --no-check-certificate --progress=bar:force:noscroll \
       "${MAVEN_REPO}/top/mrxiaom/mirai/overflow-core-all/${OVERFLOW_VERSION}/overflow-core-all-${OVERFLOW_VERSION}-all.jar" \
    && echo "下载 bcprov-jdk15on-${BOUNCYCASTLE_VERSION}.jar..." \
    && wget --no-check-certificate --progress=bar:force:noscroll \
       "${MAVEN_REPO}/org/bouncycastle/bcprov-jdk15on/${BOUNCYCASTLE_VERSION}/bcprov-jdk15on-${BOUNCYCASTLE_VERSION}.jar" \
    && echo "下载 mirai-console-2.16.0-all.jar..." \
    && wget --no-check-certificate --progress=bar:force:noscroll \
       "${MAVEN_REPO}/net/mamoe/mirai-console/2.16.0/mirai-console-2.16.0-all.jar" \
    && echo "下载 mirai-console-terminal-2.16.0-all.jar..." \
    && wget --no-check-certificate --progress=bar:force:noscroll \
       "${MAVEN_REPO}/net/mamoe/mirai-console-terminal/2.16.0/mirai-console-terminal-2.16.0-all.jar"

RUN cd plugins \
    && echo "下载 mirai-api-http (${MIRAI_API_HTTP_TAG})..." \
    && wget --no-check-certificate --progress=bar:force:noscroll \
       "https://github.com/project-mirai/mirai-api-http/releases/download/${MIRAI_API_HTTP_TAG}/mirai-api-http-${MIRAI_API_HTTP_VER}.mirai2.jar"

# 预热依赖（脚本见 scripts/docker-warmup.sh；构建完成后删除，不进入 runtime 镜像）
RUN chmod +x docker-warmup.sh && ./docker-warmup.sh && rm -f docker-warmup.sh

# -----------------------------------------------------------------------------
# 阶段 2：runtime — 最终运行镜像（无 wget/curl 等构建工具，仅 jq + dockerize + JDK）
# -----------------------------------------------------------------------------
FROM eclipse-temurin:17-jdk-jammy AS runtime

LABEL maintainer="sdjnmxd <sdjnmxd@users.noreply.github.com>"
LABEL org.opencontainers.image.title="Overflow Docker"
LABEL org.opencontainers.image.description="Overflow 的 Docker 容器化部署版本"
LABEL org.opencontainers.image.version="latest"
LABEL org.opencontainers.image.authors="sdjnmxd"
LABEL org.opencontainers.image.url="https://github.com/sdjnmxd/overflow-docker"
LABEL org.opencontainers.image.source="https://github.com/sdjnmxd/overflow-docker"
LABEL org.opencontainers.image.documentation="https://github.com/sdjnmxd/overflow-docker#readme"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.vendor="sdjnmxd"
LABEL org.opencontainers.image.base.name="eclipse-temurin:17-jdk-jammy"

ENV DOCKERIZE_VERSION="v0.7.0" \
    JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8" \
    LANG=C.UTF-8

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/* \
    && wget -q "https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz" \
    && tar -C /usr/local/bin -xzf "dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz" \
    && rm -f "dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz"

COPY --from=warmup /app/overflow /app/overflow
COPY --from=warmup /app/README.md /app/README.md
COPY --from=warmup /app/LICENSE /app/LICENSE

WORKDIR /app/overflow
RUN chmod +x start.sh

VOLUME ["/app/overflow/bots", "/app/overflow/config", "/app/overflow/data", "/app/overflow/logs"]
EXPOSE 7827

CMD ["./start.sh"]
