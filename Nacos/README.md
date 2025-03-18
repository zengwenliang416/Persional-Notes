# Nacos ARM64 部署指南

## 项目简介

本项目提供了 Nacos 在 ARM64 架构平台（如 Apple M1/M2/M3 芯片 macOS）上的部署方案。由于官方 Nacos 镜像暂不支持 ARM64 架构，本方案通过自定义 Dockerfile 构建支持 ARM64 的镜像，实现在 Apple Silicon 芯片的 macOS 系统上运行 Nacos 服务。

## 特性

- 支持 ARM64 架构（Apple Silicon）
- 基于 Nacos 2.2.3 版本
- 提供单机模式和集群模式
- 支持 MySQL 数据持久化存储
- 简单的管理脚本，方便操作

## 部署前提

- Docker & Docker Compose 已安装
- Mac OS 系统（M1/M2/M3 芯片）

## 目录结构

```
Nacos/
├── Dockerfile           # ARM64 架构的 Nacos 镜像构建文件
├── docker-compose.yaml  # 容器编排配置文件
├── nacos.sh             # 管理脚本
├── docker-startup.sh    # 容器内启动脚本
├── custom.properties    # 自定义配置文件
├── conf/                # 配置文件目录（自动创建）
├── data/                # 数据存储目录（自动创建）
└── logs/                # 日志目录（自动创建）
```

## 快速开始

### 1. 构建镜像

```bash
# 赋予脚本执行权限
chmod +x nacos.sh

# 构建ARM架构的Nacos镜像
./nacos.sh build
```

### 2. 启动服务

```bash
# 启动Nacos服务（单机模式）
./nacos.sh start
```

启动后，Nacos 控制台可通过 http://localhost:8848/nacos 访问

默认账号密码：
- 用户名：nacos
- 密码：nacos

### 3. 管理服务

```bash
# 查看服务状态
./nacos.sh status

# 查看日志
./nacos.sh logs

# 停止服务
./nacos.sh stop

# 重启服务
./nacos.sh restart

# 打开Web控制台
./nacos.sh console
```

## 配置说明

### 1. 内存配置

默认配置为较小内存占用，适合开发环境：
- JVM_XMS: 512m
- JVM_XMX: 512m
- JVM_XMN: 256m

可以在 `docker-compose.yaml` 文件中修改这些参数。

### 2. 持久化配置

默认使用嵌入式数据库（Derby）进行配置存储。如需使用 MySQL 存储配置：

```bash
# 启用MySQL配置
./nacos.sh mysql

# 然后重启服务
./nacos.sh restart
```

### 3. 自定义配置

可以通过编辑 `custom.properties` 文件并重启服务来修改配置：

```properties
# 启用权限认证
nacos.core.auth.enabled=true
```

## 集群模式配置

如需配置集群模式，编辑 `docker-compose.yaml` 文件，修改环境变量：

```yaml
environment:
  - MODE=cluster
  - NACOS_SERVERS=ip1:8848,ip2:8848,ip3:8848
```

## 常见问题

### 1. 服务启动失败

检查日志文件（`logs/` 目录）获取详细错误信息。常见原因：
- 端口冲突：检查 8848 端口是否被占用
- 内存不足：减小 JVM 内存配置
- 权限问题：检查 data 和 logs 目录的权限

### 2. 无法访问控制台

可能的解决方案：
- 检查容器状态：`docker-compose ps`
- 查看日志：`./nacos.sh logs`
- 重启服务：`./nacos.sh restart`

### 3. 配置丢失问题

默认使用嵌入式数据库，数据存储在 `data` 目录。如需持久化配置:
- 使用 MySQL 数据库存储（推荐生产环境）
- 保护好 `data` 目录内容

## 相关资源

- [Nacos 官方文档](https://nacos.io/zh-cn/docs/quick-start.html)
- [Nacos GitHub](https://github.com/alibaba/nacos)
- [Docker Hub - MySQL ARM64](https://hub.docker.com/r/arm64v8/mysql)

## 贡献者

- Claude AI

## 许可证

与 Nacos 相同，采用 Apache License 2.0 开源许可。 