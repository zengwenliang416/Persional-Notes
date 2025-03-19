# Dify Docker Compose 详解文档 🐳

> Dify是一个强大的LLMOps平台，用于构建基于大型语言模型的应用程序。本文档详细解析Dify的`docker-compose.yaml`文件，帮助你理解各个服务组件及其配置。

## 目录 📑

- [整体架构](#整体架构)
- [共享环境变量](#共享环境变量)
- [核心服务](#核心服务)
- [基础设施服务](#基础设施服务)
- [安全服务](#安全服务)
- [向量数据库选项](#向量数据库选项)
- [网络配置](#网络配置)
- [存储卷配置](#存储卷配置)
- [部署建议](#部署建议)

## 整体架构 🏗️

Dify的Docker Compose部署由以下几个主要部分组成：

1. **核心服务**：处理业务逻辑的主要服务
2. **基础设施服务**：提供数据存储和缓存功能
3. **安全服务**：提供隔离和保护
4. **网关服务**：处理路由和反向代理
5. **向量数据库**：提供向量搜索能力（有多种选择）

整体架构采用微服务设计，各个组件之间通过定义好的API和网络进行通信。

## 共享环境变量 🔄

`docker-compose.yaml`中定义了大量共享环境变量（`shared-api-worker-env`），供API和Worker服务共用。主要包括：

- **服务URL配置**：各服务间的通信地址
- **日志配置**：日志级别、文件路径、格式等
- **数据库连接**：PostgreSQL连接参数
- **Redis配置**：缓存服务参数
- **存储配置**：文件存储相关参数
- **向量库配置**：各种向量数据库的连接参数
- **安全配置**：密钥和认证参数

这些环境变量通过YAML锚点（`&shared-api-worker-env`）和引用（`<<: *shared-api-worker-env`）技术在多个服务间共享，避免重复配置。

## 核心服务 🚀

### API服务 (api)

```yaml
api:
  image: langgenius/dify-api:0.15.3
  restart: always
  environment:
    <<: *shared-api-worker-env
    MODE: api
    SENTRY_DSN: ${API_SENTRY_DSN:-}
    SENTRY_TRACES_SAMPLE_RATE: ${API_SENTRY_TRACES_SAMPLE_RATE:-1.0}
    SENTRY_PROFILES_SAMPLE_RATE: ${API_SENTRY_PROFILES_SAMPLE_RATE:-1.0}
  depends_on:
    - db
    - redis
  volumes:
    - ./volumes/app/storage:/app/api/storage
  networks:
    - ssrf_proxy_network
    - default
```

- **功能**：提供Dify的核心API服务，处理用户请求和业务逻辑
- **依赖**：数据库(db)和Redis缓存
- **数据持久化**：通过volume挂载存储用户文件
- **网络**：接入默认网络和SSRF代理网络

### Worker服务 (worker)

```yaml
worker:
  image: langgenius/dify-api:0.15.3
  restart: always
  environment:
    <<: *shared-api-worker-env
    MODE: worker
    SENTRY_DSN: ${API_SENTRY_DSN:-}
    SENTRY_TRACES_SAMPLE_RATE: ${API_SENTRY_TRACES_SAMPLE_RATE:-1.0}
    SENTRY_PROFILES_SAMPLE_RATE: ${API_SENTRY_PROFILES_SAMPLE_RATE:-1.0}
  depends_on:
    - db
    - redis
  volumes:
    - ./volumes/app/storage:/app/api/storage
  networks:
    - ssrf_proxy_network
    - default
```

- **功能**：Celery工作进程，处理异步任务和队列
- **依赖**：与API服务相同
- **特点**：与API服务使用同一镜像，但启动模式不同(MODE: worker)

### Web前端 (web)

```yaml
web:
  image: langgenius/dify-web:0.15.3
  restart: always
  environment:
    CONSOLE_API_URL: ${CONSOLE_API_URL:-}
    APP_API_URL: ${APP_API_URL:-}
    SENTRY_DSN: ${WEB_SENTRY_DSN:-}
    NEXT_TELEMETRY_DISABLED: ${NEXT_TELEMETRY_DISABLED:-0}
    TEXT_GENERATION_TIMEOUT_MS: ${TEXT_GENERATION_TIMEOUT_MS:-60000}
    CSP_WHITELIST: ${CSP_WHITELIST:-}
    TOP_K_MAX_VALUE: ${TOP_K_MAX_VALUE:-}
    INDEXING_MAX_SEGMENTATION_TOKENS_LENGTH: ${INDEXING_MAX_SEGMENTATION_TOKENS_LENGTH:-}
```

- **功能**：提供Dify的Web界面
- **技术**：基于NextJS构建的前端应用
- **环境变量**：配置API端点和性能参数

## 基础设施服务 ⚙️

### 数据库 (db)

```yaml
db:
  image: postgres:15-alpine
  restart: always
  environment:
    PGUSER: ${PGUSER:-postgres}
    POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-difyai123456}
    POSTGRES_DB: ${POSTGRES_DB:-dify}
    PGDATA: ${PGDATA:-/var/lib/postgresql/data/pgdata}
  command: >
    postgres -c 'max_connections=${POSTGRES_MAX_CONNECTIONS:-100}'
             -c 'shared_buffers=${POSTGRES_SHARED_BUFFERS:-128MB}'
             -c 'work_mem=${POSTGRES_WORK_MEM:-4MB}'
             -c 'maintenance_work_mem=${POSTGRES_MAINTENANCE_WORK_MEM:-64MB}'
             -c 'effective_cache_size=${POSTGRES_EFFECTIVE_CACHE_SIZE:-4096MB}'
  volumes:
    - ./volumes/db/data:/var/lib/postgresql/data
  healthcheck:
    test: [ 'CMD', 'pg_isready' ]
    interval: 1s
    timeout: 3s
    retries: 30
```

- **功能**：PostgreSQL数据库，存储Dify的业务数据
- **配置**：通过command参数优化数据库性能
- **健康检查**：确保服务可用性

### Redis缓存 (redis)

```yaml
redis:
  image: redis:6-alpine
  restart: always
  environment:
    REDISCLI_AUTH: ${REDIS_PASSWORD:-difyai123456}
  volumes:
    - ./volumes/redis/data:/data
  command: redis-server --requirepass ${REDIS_PASSWORD:-difyai123456}
  healthcheck:
    test: [ 'CMD', 'redis-cli', 'ping' ]
```

- **功能**：提供缓存和消息队列服务
- **安全**：配置密码保护
- **持久化**：数据存储挂载到宿主机

### Nginx网关 (nginx)

```yaml
nginx:
  image: nginx:latest
  restart: always
  volumes:
    - ./nginx/nginx.conf.template:/etc/nginx/nginx.conf.template
    - ./nginx/proxy.conf.template:/etc/nginx/proxy.conf.template
    - ./nginx/https.conf.template:/etc/nginx/https.conf.template
    # ... 更多卷挂载
  entrypoint: [ 'sh', '-c', "cp /docker-entrypoint-mount.sh /docker-entrypoint.sh && sed -i 's/\r$$//' /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh && /docker-entrypoint.sh" ]
  environment:
    NGINX_SERVER_NAME: ${NGINX_SERVER_NAME:-_}
    NGINX_HTTPS_ENABLED: ${NGINX_HTTPS_ENABLED:-false}
    # ... 更多环境变量
  depends_on:
    - api
    - web
  ports:
    - '${EXPOSE_NGINX_PORT:-80}:${NGINX_PORT:-80}'
    - '${EXPOSE_NGINX_SSL_PORT:-443}:${NGINX_SSL_PORT:-443}'
```

- **功能**：反向代理和路由服务
- **配置**：通过模板文件和环境变量灵活配置
- **端口映射**：将内部服务暴露到宿主机

## 安全服务 🔒

### 沙箱 (sandbox)

```yaml
sandbox:
  image: langgenius/dify-sandbox:0.2.10
  restart: always
  environment:
    API_KEY: ${SANDBOX_API_KEY:-dify-sandbox}
    GIN_MODE: ${SANDBOX_GIN_MODE:-release}
    WORKER_TIMEOUT: ${SANDBOX_WORKER_TIMEOUT:-15}
    ENABLE_NETWORK: ${SANDBOX_ENABLE_NETWORK:-true}
    HTTP_PROXY: ${SANDBOX_HTTP_PROXY:-http://ssrf_proxy:3128}
    HTTPS_PROXY: ${SANDBOX_HTTPS_PROXY:-http://ssrf_proxy:3128}
    SANDBOX_PORT: ${SANDBOX_PORT:-8194}
  volumes:
    - ./volumes/sandbox/dependencies:/dependencies
  healthcheck:
    test: [ 'CMD', 'curl', '-f', 'http://localhost:8194/health' ]
  networks:
    - ssrf_proxy_network
```

- **功能**：提供隔离的代码执行环境
- **安全**：通过API密钥和网络隔离提供安全保障
- **代理**：通过SSRF代理访问外部资源

### SSRF代理 (ssrf_proxy)

```yaml
ssrf_proxy:
  image: ubuntu/squid:latest
  restart: always
  volumes:
    - ./ssrf_proxy/squid.conf.template:/etc/squid/squid.conf.template
    - ./ssrf_proxy/docker-entrypoint.sh:/docker-entrypoint-mount.sh
  entrypoint: [ 'sh', '-c', "cp /docker-entrypoint-mount.sh /docker-entrypoint.sh && sed -i 's/\r$$//' /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh && /docker-entrypoint.sh" ]
  environment:
    HTTP_PORT: ${SSRF_HTTP_PORT:-3128}
    COREDUMP_DIR: ${SSRF_COREDUMP_DIR:-/var/spool/squid}
    REVERSE_PROXY_PORT: ${SSRF_REVERSE_PROXY_PORT:-8194}
    SANDBOX_HOST: ${SSRF_SANDBOX_HOST:-sandbox}
    SANDBOX_PORT: ${SANDBOX_PORT:-8194}
  networks:
    - ssrf_proxy_network
    - default
```

- **功能**：防止服务器端请求伪造(SSRF)攻击
- **实现**：使用Squid代理服务器
- **网络**：位于内部网络和默认网络之间

## 向量数据库选项 🧠

Dify提供多种向量数据库选择，默认使用Weaviate：

### Weaviate (默认)

```yaml
weaviate:
  image: semitechnologies/weaviate:1.19.0
  profiles:
    - ''
    - weaviate
  restart: always
  volumes:
    - ./volumes/weaviate:/var/lib/weaviate
  environment:
    PERSISTENCE_DATA_PATH: ${WEAVIATE_PERSISTENCE_DATA_PATH:-/var/lib/weaviate}
    QUERY_DEFAULTS_LIMIT: ${WEAVIATE_QUERY_DEFAULTS_LIMIT:-25}
    # ... 更多配置
```

- **功能**：默认向量数据库，用于语义搜索
- **认证**：支持API密钥认证

### 其他向量数据库选项

配置文件中还包含多种向量数据库选择，使用Docker Compose profiles进行管理：

- **Qdrant**：轻量级向量搜索引擎
- **Milvus**：分布式向量数据库
- **PGVector**：PostgreSQL的向量扩展
- **Chroma**：开源嵌入式向量数据库
- **Elasticsearch**：全文搜索引擎
- **MyScale**：基于ClickHouse的向量检索方案

## 网络配置 🌐

```yaml
networks:
  # create a network between sandbox, api and ssrf_proxy, and can not access outside.
  ssrf_proxy_network:
    driver: bridge
    internal: true
  milvus:
    driver: bridge
  opensearch-net:
    driver: bridge
    internal: true
```

- **ssrf_proxy_network**：内部网络，用于沙箱、API和SSRF代理间通信，不能访问外部
- **milvus**：Milvus服务网络
- **opensearch-net**：OpenSearch服务网络

## 存储卷配置 💾

```yaml
volumes:
  oradata:
  dify_es01_data:
```

- **命名卷**：用于Oracle和Elasticsearch的持久化存储
- **绑定挂载**：多处使用`./volumes/`目录绑定挂载到容器内

## 部署建议 💡

1. **最小必要服务**：
   - 核心服务：api、worker、web
   - 基础设施：db、redis
   - 安全服务：sandbox、ssrf_proxy
   - 网关：nginx
   - 向量数据库：weaviate(默认)或其他选项之一

2. **资源需求**：
   - 最小配置：2 CPU核心，4GB内存
   - 推荐配置：4 CPU核心，8GB内存

3. **安全考虑**：
   - 修改默认密码
   - 限制访问端口
   - 配置HTTPS（生产环境）

4. **自定义配置**：
   - 通过.env文件覆盖默认配置值
   - 针对生产环境优化数据库参数

5. **选择向量数据库**：
   - 基于需要处理的数据量和查询性能需求
   - 通过profiles激活所需数据库

---

## 相关链接 🔗

- [English Documentation](en/Docker-Compose详解.md)
- [Dify官方文档](https://docs.dify.ai/)
- [Dify GitHub仓库](https://github.com/langgenius/dify) 