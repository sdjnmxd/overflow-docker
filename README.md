# Overflow Docker 部署指南

[![Docker Pulls](https://img.shields.io/docker/pulls/sdjnmxd/overflow)](https://hub.docker.com/r/sdjnmxd/overflow) [![Docker Stars](https://img.shields.io/docker/stars/sdjnmxd/overflow)](https://hub.docker.com/r/sdjnmxd/overflow) [![Docker Image Size](https://img.shields.io/docker/image-size/sdjnmxd/overflow/latest)](https://hub.docker.com/r/sdjnmxd/overflow) [![Docker Image CI/CD](https://github.com/sdjnmxd/overflow-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/sdjnmxd/overflow-docker/actions/workflows/docker-publish.yml) [![GitHub Stars](https://img.shields.io/github/stars/sdjnmxd/overflow-docker.svg?logo=github)](https://github.com/sdjnmxd/overflow-docker) [![GitHub License](https://img.shields.io/github/license/sdjnmxd/overflow-docker)](https://github.com/sdjnmxd/overflow-docker/blob/main/LICENSE) [![GitHub last commit](https://img.shields.io/github/last-commit/sdjnmxd/overflow-docker)](https://github.com/sdjnmxd/overflow-docker/commits/main)

这是 [Overflow](https://github.com/MrXiaoM/Overflow) 的 Docker 部署配置，提供了一个开箱即用的 Mirai Console + Overflow 容器化部署方案。

## 快速开始

从 Docker Hub 拉取镜像并运行：

```bash
# 方式一：直接使用 docker-compose（推荐）
docker-compose pull
docker-compose up -d

# 方式二：手动拉取镜像
docker pull sdjnmxd/overflow:latest
```

## 环境要求

- Docker
- Docker Compose
- 一个可用的 Onebot 实现（如 go-cqhttp、LLOneBot 等）

## 配置指南

### 配置文件
Overflow 和 Mirai Console 的配置文件存放在以下目录：
- 数据目录：`./data`（存储机器人数据）
- 配置目录：`./config`（存储配置文件）
- 插件目录：`./plugins`（存储插件文件）
- 日志目录：`./logs`（可选，存储日志文件）
- 主配置文件：`overflow.json`

其他目录如 `bots`、`content`、`plugin-libraries` 等会由程序自动生成和管理，无需手动维护。

### 环境变量
本项目支持以下环境变量配置：

```env
# 时区设置
TZ=Asia/Shanghai

# Java 虚拟机参数
JAVA_OPTS=-Xms512M -Xmx1G
```

## 部署流程

1. 准备必要目录：
```bash
mkdir -p data config plugins
```

2. 配置环境变量：
```bash
# 创建环境变量文件
cat > .env << 'EOF'
# 时区设置
TZ=Asia/Shanghai

# Java 虚拟机参数
JAVA_OPTS=-Xms512M -Xmx1G
EOF
```

3. 启动服务：
```bash
docker-compose up -d
```

4. 配置 Overflow：
   - 在 `config` 目录中配置 Overflow 连接到 Onebot 实现
   - 在 Mirai Console 中配置机器人账号
   - 根据需要安装 Mirai 插件

## 本地构建

如果需要本地构建镜像，可以使用以下命令：

```bash
# 使用默认版本构建
docker build -t overflow .

# 指定版本构建
docker build -t overflow \
  --build-arg MAVEN_REPO=https://mirrors.huaweicloud.com/repository/maven \
  --build-arg OVERFLOW_VERSION=1.0.5 \
  --build-arg MIRAI_VERSION=2.16.0 \
  --build-arg BOUNCYCASTLE_VERSION=1.64 .
```

默认参数：
- Maven仓库: https://mirrors.huaweicloud.com/repository/maven
- Overflow: 1.0.5
- Mirai Console: 2.16.0
- BouncyCastle: 1.64

这些参数可以在构建时通过 `--build-arg` 参数覆盖。

## 版本管理

镜像版本说明：
- `latest`: 最新版本，每日自动构建
- `x.y.z-mirai.a.b.c`: 特定版本号，对应 Overflow 和 Mirai Console 的发布版本

当前集成的组件版本：
- Overflow Core: 1.0.5
- Mirai Console: 2.16.0
- BouncyCastle: 1.64

镜像通过 GitHub Actions 自动构建并推送至 [Docker Hub](https://hub.docker.com/r/sdjnmxd/overflow)：
- 每日自动检查 Overflow 和 Mirai Console 更新
- 发现新版本时自动构建并推送镜像

## 支持架构

- linux/amd64

## 常用命令

```bash
# 查看日志
docker-compose logs -f overflow

# 停止服务
docker-compose down

# 更新版本
docker-compose pull
docker-compose up -d

# 重启服务
docker-compose restart
```

## 问题反馈

如果您在使用过程中遇到任何问题或有改进建议，欢迎通过以下方式反馈：

1. [GitHub Issues](../../issues)：
   - 部署相关问题
   - Docker镜像问题
   - 功能建议
   - 文档改进

2. [Overflow 官方仓库](https://github.com/MrXiaoM/Overflow/issues)：
   - Overflow 本身的功能问题
   - 协议实现问题
   - 其他 Bot 相关问题

提交问题时，请尽可能提供：
- 详细的问题描述
- 相关的错误日志
- 复现步骤
- 运行环境信息

## License

本项目采用 MIT License 开源，详细信息请参阅 [LICENSE](LICENSE) 文件。

Overflow Docker 是一个独立项目，仅提供容器化部署方案。上游项目使用以下许可证：
- [Overflow](https://github.com/MrXiaoM/Overflow) 采用 [AGPL-3.0 License](https://github.com/MrXiaoM/Overflow/blob/main/LICENSE)，所有权利归原作者所有
- [Mirai](https://github.com/mamoe/mirai) 采用 [AGPL-3.0 License](https://github.com/mamoe/mirai/blob/dev/LICENSE)，所有权利归原作者所有