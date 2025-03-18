# Nacos 服务注册与配置中心

## 项目简介

Nacos (Naming and Configuration Service) 是阿里巴巴开源的一个易于构建云原生应用的动态服务发现、配置管理和服务管理平台。本项目提供了 Nacos 的快速部署方案，帮助用户快速搭建并使用 Nacos 服务。

主要功能：

- **服务发现与服务健康监测**：支持基于DNS和RPC的服务发现，以及服务的健康检查
- **动态配置管理**：动态配置服务允许您在所有环境中以集中和动态的方式管理所有应用程序的配置
- **动态 DNS 服务**：动态DNS服务支持权重路由，使您更容易地实现中间层负载均衡、更灵活的路由策略和流量控制
- **服务及元数据管理**：支持服务元数据的管理和跨区域的服务管理

## 环境要求

- Docker 19.03.0+
- Docker Compose 1.29.0+（可选，使用docker-compose.yml时需要）
- 至少 1GB 可用内存
- 至少 2GB 可用磁盘空间

## 目录结构

```
Nacos/
├── nacos.sh              # 统一管理脚本（启动、停止、状态查询等）
├── docker-compose.yml    # Docker Compose 配置文件
├── conf/                 # 配置文件目录
│   └── application.properties.example  # 配置示例文件
├── data/                 # 数据存储目录（自动创建）
├── logs/                 # 日志存储目录（自动创建）
├── mysql/                # MySQL数据目录（使用Docker Compose时）
└── README.md             # 项目主文档（本文件）
```

## 快速开始

### 使用管理脚本（推荐）

本项目提供了统一的管理脚本 `nacos.sh`，可以方便地管理 Nacos 服务。

```bash
# 进入 Nacos 目录
cd Nacos

# 赋予脚本执行权限
chmod +x nacos.sh

# 启动 Nacos 服务（会自动启动 MySQL）
./nacos.sh start

# 查看服务状态
./nacos.sh status

# 查看 Nacos 日志
./nacos.sh log

# 停止服务
./nacos.sh stop
```

### 使用 Docker Compose

如果您更习惯于使用 Docker Compose，可以按照以下步骤操作：

```bash
# 进入 Nacos 目录
cd Nacos

# 启动服务
docker-compose up -d

# 停止服务
docker-compose down
```

## 服务访问

### Nacos 控制台

启动服务后，可以通过以下地址访问 Nacos 控制台：

- 地址：`http://localhost:8848/nacos`
- 默认用户名：`nacos`
- 默认密码：`nacos`

### Nacos API

Nacos 提供了丰富的 HTTP API，可以通过程序调用：

- 服务注册：`POST /nacos/v1/ns/instance`
- 服务发现：`GET /nacos/v1/ns/instance/list`
- 配置发布：`POST /nacos/v1/cs/configs`
- 配置获取：`GET /nacos/v1/cs/configs`

更多 API 说明请参考 [Nacos Open API 指南](https://nacos.io/zh-cn/docs/open-api.html)。

## 持久化配置

默认情况下，Nacos 使用 MySQL 进行数据持久化。如果您需要修改数据库配置，可以：

1. 复制配置示例文件：
```bash
cp conf/application.properties.example conf/application.properties
```

2. 编辑 `conf/application.properties` 文件，修改数据库连接信息。

3. 重启 Nacos 服务：
```bash
./nacos.sh restart
```

## 常见问题

### 1. Nacos 无法连接到 MySQL

检查 MySQL 容器是否正常运行：
```bash
docker ps | grep nacos-mysql
```

检查 MySQL 连接配置是否正确：
```bash
docker logs nacos-server | grep -i mysql
```

### 2. Nacos 控制台无法访问

检查 Nacos 容器是否正常运行：
```bash
docker ps | grep nacos-server
```

查看 Nacos 日志是否有错误：
```bash
./nacos.sh log
```

### 3. 服务注册失败

确保客户端正确连接到 Nacos 服务：
- 检查连接地址是否正确
- 确认服务名称是否符合规范
- 检查网络连接是否通畅

## 集群部署

本配置默认使用单机模式（standalone）部署 Nacos。如需使用集群模式，请参考 Nacos 官方文档进行配置。

## 相关资源

- [Nacos 官方文档](https://nacos.io/zh-cn/docs/what-is-nacos.html)
- [Nacos GitHub](https://github.com/alibaba/nacos)
- [Spring Cloud Alibaba Nacos](https://github.com/alibaba/spring-cloud-alibaba/wiki/Nacos-config)
- [Nacos Docker](https://github.com/nacos-group/nacos-docker)

## 许可协议

本项目遵循 [Apache 2.0 许可协议](https://www.apache.org/licenses/LICENSE-2.0)。 