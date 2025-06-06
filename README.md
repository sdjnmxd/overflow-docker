# Overflow Docker 部署指南

[![Docker Pulls](https://img.shields.io/docker/pulls/sdjnmxd/overflow)](https://hub.docker.com/r/sdjnmxd/overflow) [![Docker Stars](https://img.shields.io/docker/stars/sdjnmxd/overflow)](https://hub.docker.com/r/sdjnmxd/overflow) [![Docker Image Size](https://img.shields.io/docker/image-size/sdjnmxd/overflow/latest)](https://hub.docker.com/r/sdjnmxd/overflow) [![Docker Image CI/CD](https://github.com/sdjnmxd/overflow-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/sdjnmxd/overflow-docker/actions/workflows/docker-publish.yml) [![GitHub Stars](https://img.shields.io/github/stars/sdjnmxd/overflow-docker.svg?logo=github)](https://github.com/sdjnmxd/overflow-docker) [![GitHub License](https://img.shields.io/github/license/sdjnmxd/overflow-docker)](https://github.com/sdjnmxd/overflow-docker/blob/main/LICENSE) [![GitHub last commit](https://img.shields.io/github/last-commit/sdjnmxd/overflow-docker)](https://github.com/sdjnmxd/overflow-docker/commits/main)

这是 [Overflow](https://github.com/MrXiaoM/Overflow) 的 Docker 部署配置，提供了一个开箱即用的 Mirai Console + Overflow 容器化部署方案。

## 快速开始

1. 创建项目目录：
```bash
mkdir overflow && cd overflow
```

2. 下载配置文件：
```bash
curl -O https://raw.githubusercontent.com/sdjnmxd/overflow-docker/main/docker-compose.yml
```

3. 修改必要配置：
编辑 `docker-compose.yml`，设置以下环境变量：
- `OVERFLOW_WS_HOST`：你的 Onebot 实现的 WebSocket 地址
- `OVERFLOW_TOKEN`：你的 Onebot 实现的访问令牌

4. 启动服务：
```bash
docker-compose up -d
```

就是这么简单！服务启动后，你可以：
- 查看日志：`docker-compose logs -f`
- 停止服务：`docker-compose down`
- 重启服务：`docker-compose restart`

## 目录说明

服务会自动创建以下目录：
- `bots`：机器人账号数据
- `config`：配置文件
- `data`：数据文件
- `logs`：日志文件

## 配置说明

### 必要配置

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| OVERFLOW_WS_HOST | Onebot 实现的 WebSocket 地址 | ws://127.0.0.1:7827 |
| OVERFLOW_TOKEN | Onebot 实现的访问令牌 | StarBot |

### 可选配置

#### 系统配置
| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| TZ | 时区 | Asia/Shanghai |
| JAVA_OPTS | Java 虚拟机参数 | -Xms512M -Xmx1G |

#### Overflow 配置
| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| OVERFLOW_NO_LOG | 关闭日志（开启时不接受漏洞反馈） | false |
| OVERFLOW_WS_HOST | WebSocket 地址 | ws://127.0.0.1:7827 |
| OVERFLOW_REVERSED_WS_PORT | 反向 WebSocket 端口 | -1 |
| OVERFLOW_TOKEN | 访问令牌 | StarBot |
| OVERFLOW_NO_PLATFORM | 是否禁用平台信息 | false |
| OVERFLOW_USE_CQ_CODE | 是否使用 CQ 码 | false |
| OVERFLOW_RETRY_TIMES | 重试次数 | 5 |
| OVERFLOW_RETRY_WAIT_MILLS | 重试等待时间（毫秒） | 5000 |
| OVERFLOW_RETRY_REST_MILLS | 重试休息时间（毫秒） | 60000 |
| OVERFLOW_HEARTBEAT_CHECK_SECONDS | 心跳检查间隔（秒） | 60 |
| OVERFLOW_USE_GROUP_UPLOAD_EVENT | 是否使用群文件上传事件 | false |
| OVERFLOW_RESOURCE_CACHE_ENABLED | 是否启用资源缓存 | false |
| OVERFLOW_RESOURCE_CACHE_DURATION | 资源缓存保留时间（小时） | 168 |
| OVERFLOW_DROP_EVENTS_BEFORE_CONNECTED | 是否丢弃连接前的事件 | true |

#### mirai-api-http 配置
| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| MIRAI_ENABLE_VERIFY | 是否启用验证 | true |
| MIRAI_VERIFY_KEY | 验证密钥 | StarBot |
| MIRAI_HTTP_HOST | HTTP 服务监听地址 | 0.0.0.0 |
| MIRAI_HTTP_PORT | HTTP 服务端口 | 7827 |
| MIRAI_HTTP_CORS | CORS 配置 | * |
| MIRAI_WS_HOST | WebSocket 服务监听地址 | 0.0.0.0 |
| MIRAI_WS_PORT | WebSocket 服务端口 | 7827 |
| MIRAI_HTTP_DEBUG | 是否启用调试模式 | false |
| MIRAI_SINGLE_MODE | 是否启用单例模式 | false |
| MIRAI_WS_SYNC_ID | WebSocket 同步 ID | -1 |

## 本地构建

如果需要本地构建镜像：

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