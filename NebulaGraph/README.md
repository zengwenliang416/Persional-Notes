# NebulaGraph 学习笔记与部署指南

## 项目简介

NebulaGraph 是一个开源的、分布式的、易扩展的原生图数据库，能够承担超大规模的图数据关系查询，在海量数据集上提供毫秒级查询延时。本项目提供了 NebulaGraph 的学习笔记和快速部署方案，帮助用户快速上手并使用 NebulaGraph 图数据库。

主要内容包括：

- 基本概念和架构解析
- Docker 容器化部署方案
- 数据模型设计指南
- 查询语言学习资源
- 性能优化技巧
- 实践案例参考

## 环境要求

- Docker 19.03.0+
- Docker Compose 1.29.0+ (可选，仅使用 Docker Compose 部署时需要)
- 至少 4GB 可用内存
- 至少 10GB 可用磁盘空间

## 目录结构

```
NebulaGraph/
├── nebula.sh           # 统一管理脚本（启动、停止、状态查询等）
├── push-images.sh      # 将官方镜像推送到自定义仓库的脚本
├── update-image-sources.sh # 更新脚本中镜像源的工具
├── docker-compose/     # Docker Compose 部署配置
│   ├── docker-compose.yaml  # NebulaGraph 核心服务配置
│   └── README.md           # Docker Compose 部署说明
├── studio/             # NebulaGraph Studio 可视化界面配置
│   ├── docker-compose.yaml  # Studio 配置文件
│   └── README.md           # Studio 使用说明
├── data/               # 数据存储目录（自动创建，已加入.gitignore）
├── logs/               # 日志存储目录（自动创建，已加入.gitignore）
└── README.md           # 项目主文档（本文件）
```

## 快速开始

### 统一管理脚本（推荐）

本项目提供了统一的管理脚本 `nebula.sh`，可以轻松管理 NebulaGraph 的各项服务。

```bash
# 进入 NebulaGraph 目录
cd NebulaGraph

# 赋予脚本执行权限
chmod +x nebula.sh

# 启动所有服务（核心服务+Studio）
./nebula.sh start

# 查看服务状态
./nebula.sh status

# 连接到 NebulaGraph 控制台
./nebula.sh console

# 停止所有服务
./nebula.sh stop
```

### 脚本命令详解

统一管理脚本 `nebula.sh` 提供了以下命令：

| 命令 | 描述 |
|------|------|
| `start` | 启动所有 NebulaGraph 服务（包括核心服务和 Studio） |
| `stop` | 停止所有 NebulaGraph 服务 |
| `restart` | 重启所有 NebulaGraph 服务 |
| `status` | 查看所有 NebulaGraph 服务的运行状态 |
| `console` | 连接到 NebulaGraph 控制台 |
| `studio` | 仅启动 Studio 管理界面 |
| `core` | 仅启动 NebulaGraph 核心服务 |

### Docker Compose 部署方式

如果您偏好使用 Docker Compose，也可以使用以下命令：

```bash
# 启动 NebulaGraph 核心服务
cd docker-compose
docker compose up -d

# 启动 Studio 可视化界面
cd ../studio
docker compose up -d

# 停止服务
docker compose down
```

## 服务访问

### NebulaGraph 控制台

使用以下方式连接到 NebulaGraph 控制台：

1. 使用统一管理脚本（推荐）：
```bash
./nebula.sh console
```

2. 使用 Docker 命令：
```bash
docker run --rm -it --network=nebula-net vesoft/nebula-console:v3.8.0 -addr graphd -port 9669 -u root -p nebula
```

### NebulaGraph Studio 管理界面

启动 Studio 后，可通过浏览器访问：
- URL: `http://localhost:7001`

连接 NebulaGraph 数据库时使用以下信息：
- 主机: `graphd`（Docker 网络内）或 `localhost`（主机访问）
- 端口: `9669`
- 用户名: `root`
- 密码: `nebula`

## 使用自定义镜像仓库

如果您需要将 NebulaGraph 官方镜像推送到自己的 Docker 仓库（例如在内网环境或镜像加速），可以使用以下工具：

### 1. 推送镜像到自定义仓库

使用 `push-images.sh` 脚本将官方镜像推送到您的仓库：

```bash
# 赋予脚本执行权限
chmod +x push-images.sh

# 推送镜像到您的仓库（例如 docker.io/yourusername）
./push-images.sh docker.io/yourusername
```

该脚本会处理以下镜像：
- vesoft/nebula-metad:v3.8.0
- vesoft/nebula-storaged:v3.8.0
- vesoft/nebula-graphd:v3.8.0
- vesoft/nebula-console:v3.8.0
- vesoft/nebula-graph-studio:v3.10.0

### 2. 更新脚本中的镜像源

使用 `update-image-sources.sh` 脚本将 nebula.sh 中的镜像源更新为您的仓库：

```bash
# 赋予脚本执行权限
chmod +x update-image-sources.sh

# 更新镜像源（例如 docker.io/yourusername）
./update-image-sources.sh docker.io/yourusername
```

此脚本会自动备份原始 nebula.sh 文件，并更新所有镜像引用。

## 架构组件

NebulaGraph 集群包含以下核心组件：

1. **Meta 服务 (metad)**
   - 管理用户账号、Schema 信息、集群配置等元数据
   - 处理分布式 ID 分配
   - 提供集群管理功能

2. **存储服务 (storaged)**
   - 存储实际图数据
   - 处理图数据的读写操作
   - 管理数据分片

3. **图计算服务 (graphd)**
   - 处理查询请求
   - 执行查询计划
   - 提供查询语言接口

4. **控制台 (console)**
   - 命令行客户端
   - 执行 nGQL 查询语句
   - 查看和管理数据

5. **Studio**
   - Web 可视化管理界面
   - 图形化操作和查询
   - 查询结果可视化展示

## 基础操作指南

### 1. 创建和使用图空间

```ngql
-- 创建图空间
CREATE SPACE test_space(partition_num=3, replica_factor=1, vid_type=FIXED_STRING(30));

-- 查看所有图空间
SHOW SPACES;

-- 使用图空间
USE test_space;
```

### 2. 创建 Schema

```ngql
-- 创建标签（定义节点类型）
CREATE TAG person(name string, age int);

-- 创建边类型
CREATE EDGE follow(degree int);

-- 查看所有标签
SHOW TAGS;

-- 查看所有边类型
SHOW EDGES;
```

### 3. 插入数据

```ngql
-- 插入节点
INSERT VERTEX person(name, age) VALUES "person1":("张三", 28);
INSERT VERTEX person(name, age) VALUES "person2":("李四", 24);

-- 插入边
INSERT EDGE follow(degree) VALUES "person1"->"person2":(95);
```

### 4. 查询数据

```ngql
-- 查询节点
FETCH PROP ON person "person1";

-- 查询边
FETCH PROP ON follow "person1"->"person2";

-- 查询路径
GO 1 STEPS FROM "person1" OVER follow;
```

## 故障排除

### 1. 服务无法启动
检查日志文件（`logs/` 目录下）以获取详细错误信息。常见原因：
- 端口冲突：检查端口 9669、9559、9779 是否被占用
- 内存不足：确保有足够的可用内存
- Docker 网络问题：尝试重新创建 nebula-net 网络

### 2. 无法连接到数据库
如果遇到连接问题，请尝试：
- 确保所有服务已正常启动：运行 `./nebula.sh status`
- 检查网络设置：确保容器网络 nebula-net 正常
- 等待服务完全启动：通常需要约 30 秒

### 3. 性能问题
如果遇到性能问题，可以：
- 增加容器资源限制
- 优化查询语句
- 调整配置参数（存储、缓存等）

## 高级配置

### 1. 调整内存和 CPU 分配
在 Docker 命令中添加资源限制:
```bash
--memory="4g" --cpus=2
```

### 2. 数据持久化
默认情况下，数据存储在 `./data` 目录中，确保该目录有足够的空间和正确的权限。

### 3. 安全配置
生产环境中建议：
- 修改默认密码
- 配置 SSL/TLS
- 实施网络隔离

## 相关资源

- [NebulaGraph 官方文档](https://docs.nebula-graph.io/)
- [NebulaGraph GitHub](https://github.com/vesoft-inc/nebula)
- [NebulaGraph 论坛](https://discuss.nebula-graph.com.cn/)
- [NebulaGraph 学习路径](https://docs.nebula-graph.io/master/20.appendix/6.eco-tool-version/)

## 许可协议

本项目遵循 [Apache 2.0 许可协议](https://www.apache.org/licenses/LICENSE-2.0)。 