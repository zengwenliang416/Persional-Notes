# 【Dify】Docker Compose 搭建过程详解 🔧

> 本文档详细介绍了 Dify 平台的 Docker Compose 环境从配置到部署的完整过程，帮助您理解每个步骤的目的和最佳实践。

## 目录 📑

- [前置准备](#前置准备)
- [配置文件生成流程](#配置文件生成流程)
- [环境变量配置](#环境变量配置)
- [服务组件编排](#服务组件编排)
- [网络配置策略](#网络配置策略)
- [数据持久化](#数据持久化)
- [安全性考量](#安全性考量)
- [启动与验证](#启动与验证)
- [常见问题与解决](#常见问题与解决)

## 前置准备 ✅

在开始搭建 Dify 的 Docker Compose 环境之前，请确保系统满足以下要求：

### 系统要求

- 操作系统：Linux (Ubuntu/Debian/CentOS)、macOS 或 Windows
- Docker 版本：20.10.0 或更高
- Docker Compose 版本：2.0.0 或更高
- 最小配置：2 CPU 核心，4GB 内存，30GB 存储空间
- 推荐配置：4 CPU 核心，8GB 内存，50GB 存储空间

### 安装前检查

```bash
# 检查 Docker 版本
docker --version

# 检查 Docker Compose 版本
docker-compose --version

# 检查 Docker 服务状态
systemctl status docker  # Linux
docker info  # 所有平台
```

## 配置文件生成流程 🔄

### 1. 获取代码与配置模板

```bash
# 克隆特定版本的代码库
git clone https://github.com/langgenius/dify.git --branch 0.15.3 dify-project
cd dify-project/docker
```

### 2. 生成 docker-compose.yaml

Dify 提供了自动生成 docker-compose.yaml 的脚本，它基于模板文件动态生成最终配置：

```bash
# 执行生成脚本
./generate_docker_compose
```

该脚本的工作原理：
- 读取 `docker-compose-template.yaml` 作为基础模板
- 处理条件逻辑和环境变量替换
- 生成完整的 docker-compose.yaml 文件

### 3. 配置文件结构

生成的 docker-compose.yaml 文件主要由以下部分组成：

- **共享环境变量块**：使用 YAML 锚点定义共享配置
- **核心服务定义**：API、Worker、Web 前端等核心组件
- **基础设施服务**：数据库、缓存、向量存储等
- **网络定义**：各服务间的网络隔离和连接方案
- **卷定义**：数据持久化存储配置

## 环境变量配置 🔐

### 1. 创建环境变量文件

```bash
# 复制示例环境配置
cp .env.example .env

# 编辑环境配置
nano .env  # 或使用其他编辑器
```

### 2. 关键环境变量说明

Dify 的环境变量配置分为多个功能组：

#### 核心服务配置

```properties
# 应用访问地址配置
CONSOLE_URL=http://localhost:8080/console
APP_URL=http://localhost:8080
API_URL=http://localhost:8080/api

# 安全密钥（必须修改为随机字符串）
SECRET_KEY=your-secret-key-here

# 服务模式配置
DEPLOY_ENV=PRODUCTION
```

#### 数据库配置

```properties
# PostgreSQL 数据库配置
DB_USERNAME=postgres
DB_PASSWORD=difyai123456
DB_HOST=db
DB_PORT=5432
DB_DATABASE=dify

# 性能相关参数
POSTGRES_MAX_CONNECTIONS=100
POSTGRES_SHARED_BUFFERS=128MB
```

#### 缓存和消息队列

```properties
# Redis 配置
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=difyai123456
REDIS_DB=0

# Celery 消息队列
CELERY_BROKER_URL=redis://:difyai123456@redis:6379/1
```

#### 向量数据库配置

```properties
# 默认为 Weaviate
VECTOR_STORE=weaviate
WEAVIATE_ENDPOINT=http://weaviate:8080
WEAVIATE_API_KEY=WVF5YThaHlkYwhGUSmCRgsX3tD5ngdN8pkih

# 可选的其他向量库配置
# VECTOR_STORE=qdrant
# QDRANT_URL=http://qdrant:6333
```

### 3. 环境变量注入机制

docker-compose.yaml 使用两种方式注入环境变量：

1. **共享变量块引用**：
   ```yaml
   api:
     environment:
       <<: *shared-api-worker-env
       MODE: api
   ```

2. **默认值设置**：
   ```yaml
   # 形式为 ${VARIABLE:-default_value}
   DB_USERNAME: ${DB_USERNAME:-postgres}
   ```

这种设计实现了：
- 变量集中管理，减少重复配置
- 提供合理默认值，简化初始配置
- 在多个服务间保持配置一致性

## 服务组件编排 🧩

### 1. 核心服务配置解析

#### API 服务

```yaml
api:
  image: langgenius/dify-api:0.15.3
  restart: always
  environment:
    <<: *shared-api-worker-env
    MODE: api
  volumes:
    - ./volumes/app/storage:/app/api/storage
  networks:
    - ssrf_proxy_network
    - default
```

关键点：
- 使用官方镜像及特定版本号
- 以 API 模式启动
- 挂载存储卷实现数据持久化
- 连接到多个网络实现功能隔离和通信

#### Worker 服务

```yaml
worker:
  image: langgenius/dify-api:0.15.3
  restart: always
  environment:
    <<: *shared-api-worker-env
    MODE: worker
  volumes:
    - ./volumes/app/storage:/app/api/storage
  networks:
    - ssrf_proxy_network
    - default
```

关键点：
- 使用与 API 相同的镜像
- 以 Worker 模式启动处理异步任务
- 共享 API 服务的存储空间

#### Web 前端

```yaml
web:
  image: langgenius/dify-web:0.15.3
  restart: always
  environment:
    CONSOLE_API_URL: ${CONSOLE_API_URL:-}
    APP_API_URL: ${APP_API_URL:-}
```

关键点：
- 使用专用前端镜像
- 仅配置前端所需的 API 地址变量

### 2. 基础设施服务配置

#### 数据库服务

```yaml
db:
  image: postgres:15-alpine
  restart: always
  environment:
    PGUSER: ${PGUSER:-postgres}
    POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-difyai123456}
    POSTGRES_DB: ${POSTGRES_DB:-dify}
  command: >
    postgres -c 'max_connections=${POSTGRES_MAX_CONNECTIONS:-100}'
             -c 'shared_buffers=${POSTGRES_SHARED_BUFFERS:-128MB}'
  volumes:
    - ./volumes/db/data:/var/lib/postgresql/data
```

关键点：
- 使用轻量级 Alpine 版本降低资源消耗
- 通过命令行参数调优数据库性能
- 数据持久化到本地卷

#### Redis 缓存

```yaml
redis:
  image: redis:6-alpine
  restart: always
  command: redis-server --requirepass ${REDIS_PASSWORD:-difyai123456}
  volumes:
    - ./volumes/redis/data:/data
```

关键点：
- 使用轻量级 Alpine 版本
- 设置密码保护
- 数据持久化到本地卷

#### 向量数据库 (Weaviate)

```yaml
weaviate:
  image: semitechnologies/weaviate:1.19.0
  profiles:
    - ''
    - weaviate
  volumes:
    - ./volumes/weaviate:/var/lib/weaviate
  environment:
    AUTHENTICATION_APIKEY_ENABLED: ${WEAVIATE_AUTHENTICATION_APIKEY_ENABLED:-true}
    AUTHENTICATION_APIKEY_ALLOWED_KEYS: ${WEAVIATE_AUTHENTICATION_APIKEY_ALLOWED_KEYS:-WVF5YThaHlkYwhGUSmCRgsX3tD5ngdN8pkih}
```

关键点：
- 默认激活 (空 profile)
- 启用 API 密钥认证
- 数据持久化到本地卷

### 3. 安全服务配置

#### 沙箱服务

```yaml
sandbox:
  image: langgenius/dify-sandbox:0.2.10
  restart: always
  environment:
    API_KEY: ${SANDBOX_API_KEY:-dify-sandbox}
    ENABLE_NETWORK: ${SANDBOX_ENABLE_NETWORK:-true}
    HTTP_PROXY: ${SANDBOX_HTTP_PROXY:-http://ssrf_proxy:3128}
  networks:
    - ssrf_proxy_network
```

关键点：
- 专用安全沙箱镜像
- API 密钥认证
- 通过代理控制网络访问
- 使用隔离网络

#### SSRF 代理

```yaml
ssrf_proxy:
  image: ubuntu/squid:latest
  restart: always
  volumes:
    - ./ssrf_proxy/squid.conf.template:/etc/squid/squid.conf.template
  networks:
    - ssrf_proxy_network
    - default
```

关键点：
- 基于 Squid 代理实现 SSRF 防护
- 使用配置模板
- 作为网络隔离的桥梁

### 4. 网关配置

```yaml
nginx:
  image: nginx:latest
  restart: always
  volumes:
    - ./nginx/nginx.conf.template:/etc/nginx/nginx.conf.template
    - ./nginx/conf.d:/etc/nginx/conf.d
  environment:
    NGINX_SERVER_NAME: ${NGINX_SERVER_NAME:-_}
    NGINX_PORT: ${NGINX_PORT:-80}
  ports:
    - '${EXPOSE_NGINX_PORT:-80}:${NGINX_PORT:-80}'
```

关键点：
- 使用配置模板实现动态配置
- 端口映射暴露服务
- 提供 HTTPS 支持选项

## 网络配置策略 🔒

### 1. 网络架构设计

```yaml
networks:
  ssrf_proxy_network:
    driver: bridge
    internal: true  # 无法访问外部网络
  milvus:
    driver: bridge
  opensearch-net:
    driver: bridge
    internal: true
  default:
    driver: bridge  # 默认网络
```

Dify 采用多网络架构：

- **内部安全网络** (ssrf_proxy_network)：
  - 连接沙箱和代理服务
  - 无法直接访问外部网络
  - 提供代码执行的安全隔离层

- **向量数据库网络**：
  - 为每种向量数据库提供独立网络
  - 限制不必要的服务间通信

- **默认网络**：
  - 连接主要应用组件
  - 提供基础通信路径

### 2. 服务网络分配

```yaml
api:
  networks:
    - ssrf_proxy_network  # 用于安全调用沙箱
    - default  # 用于基础组件通信

worker:
  networks:
    - ssrf_proxy_network
    - default

ssrf_proxy:
  networks:
    - ssrf_proxy_network  # 内部网络
    - default  # 桥接到外部
```

这种网络分离机制提供了多层安全保障：

1. 核心组件可通过 default 网络相互通信
2. 安全敏感服务通过内部网络隔离
3. 使用代理作为安全网关控制外部访问

## 数据持久化 💾

### 1. 卷映射策略

Dify 采用一致的卷命名和映射约定：

```yaml
volumes:
  # 命名卷
  oradata:  # Oracle 数据库卷
  dify_es01_data:  # Elasticsearch 数据卷
  
  # 绑定挂载
  - ./volumes/app/storage:/app/api/storage  # 应用存储
  - ./volumes/db/data:/var/lib/postgresql/data  # 数据库存储
  - ./volumes/redis/data:/data  # Redis 数据
  - ./volumes/weaviate:/var/lib/weaviate  # 向量数据库
```

### 2. 数据目录结构

生成的数据目录结构如下：

```
docker/
└── volumes/
    ├── app/
    │   └── storage/  # 用户上传文件、临时文件等
    ├── db/
    │   └── data/     # PostgreSQL 数据文件
    ├── redis/
    │   └── data/     # Redis 持久化数据
    ├── weaviate/     # 向量数据库存储
    ├── sandbox/
    │   └── dependencies/  # 沙箱依赖包
    └── certbot/      # SSL 证书 (可选)
```

### 3. 持久化最佳实践

- 所有持久化数据集中存储在 volumes 目录下
- 每个服务有独立的数据目录
- 使用相对路径映射简化部署和迁移
- 当需要备份时，只需备份 volumes 目录

## 安全性考量 🛡️

### 1. 密码和凭证管理

```yaml
# .env 文件中的安全配置
SECRET_KEY=your-secret-key-here  # 应用密钥
DB_PASSWORD=strong-password  # 数据库密码
REDIS_PASSWORD=strong-password  # Redis 密码
WEAVIATE_API_KEY=custom-api-key  # 向量数据库密钥
SANDBOX_API_KEY=custom-sandbox-key  # 沙箱服务密钥
```

安全建议：
- 生产环境中修改所有默认密码
- 使用随机生成的强密码
- 不同服务使用不同密码
- 密钥保存在 .env 文件而非 docker-compose.yaml

### 2. 网络安全策略

- 使用内部网络隔离关键服务
- SSRF 代理控制外部网络访问
- 沙箱环境限制代码执行
- Nginx 配置外部访问规则

## 启动与验证 🚀

### 1. 启动服务

```bash
# 启动基础服务
docker-compose up -d

# 启动包含特定向量数据库的服务
docker-compose --profile qdrant up -d
```

### 2. 启动顺序控制

Docker Compose 基于依赖关系控制启动顺序：

1. 基础设施服务（db、redis、向量数据库）
2. 安全服务（ssrf_proxy、sandbox）
3. 核心服务（api、worker）
4. 网关（nginx）和前端（web）

### 3. 服务健康检查

多个服务配置了健康检查，确保它们正常运行：

```yaml
db:
  healthcheck:
    test: [ 'CMD', 'pg_isready' ]
    interval: 1s
    timeout: 3s
    retries: 30

redis:
  healthcheck:
    test: [ 'CMD', 'redis-cli', 'ping' ]
```

### 4. 验证部署

完成部署后，可以通过以下方式验证：

```bash
# 检查所有容器状态
docker-compose ps

# 查看服务日志
docker-compose logs api

# 访问 Web 界面
open http://localhost:8080/install
```

## 常见问题与解决 ❓

### 1. 数据库连接问题

**问题**: API 服务无法连接到数据库

**解决**:
- 检查数据库容器是否运行 `docker-compose ps db`
- 验证数据库凭证 `docker-compose exec db psql -U postgres -c "SELECT 1"`
- 检查 DB_HOST 配置是否为 "db"，而非 "localhost"

### 2. 端口冲突

**问题**: 启动失败，提示端口被占用

**解决**:
- 编辑 .env 文件修改 EXPOSE_NGINX_PORT
- 检查并关闭使用相同端口的其他服务
- 检查防火墙设置

### 3. 向量数据库初始化失败

**问题**: 向量数据库启动但应用无法连接

**解决**:
- 检查向量数据库日志 `docker-compose logs weaviate`
- 验证 VECTOR_STORE 环境变量设置正确
- 确认安全凭证配置正确

### 4. 存储权限问题

**问题**: 文件上传失败或无法创建文件

**解决**:
- 确保 volumes 目录有正确的权限
  ```bash
  chmod -R 755 volumes/
  chown -R 1000:1000 volumes/app/
  ```
- 检查目录挂载是否正确 `docker-compose exec api ls -la /app/api/storage`

---

## 相关链接 🔗

- [English Version](en/【Dify】Docker-Compose搭建过程详解.md)
- [Dify 官方文档](https://docs.dify.ai/)
- [Docker Compose 官方文档](https://docs.docker.com/compose/)
- [Dify GitHub 仓库](https://github.com/langgenius/dify) 