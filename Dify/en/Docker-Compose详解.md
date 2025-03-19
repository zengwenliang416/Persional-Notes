# Dify Docker Compose Documentation 🐳

> Dify is a powerful LLMOps platform for building applications based on large language models. This document provides a detailed analysis of Dify's `docker-compose.yaml` file, helping you understand each service component and its configuration.

## Table of Contents 📑

- [Overall Architecture](#overall-architecture)
- [Shared Environment Variables](#shared-environment-variables)
- [Core Services](#core-services)
- [Infrastructure Services](#infrastructure-services)
- [Security Services](#security-services)
- [Vector Database Options](#vector-database-options)
- [Network Configuration](#network-configuration)
- [Storage Volume Configuration](#storage-volume-configuration)
- [Deployment Recommendations](#deployment-recommendations)

## Overall Architecture 🏗️

Dify's Docker Compose deployment consists of the following main components:

1. **Core Services**: Primary services that handle business logic
2. **Infrastructure Services**: Provide data storage and caching functionality
3. **Security Services**: Provide isolation and protection
4. **Gateway Services**: Handle routing and reverse proxying
5. **Vector Databases**: Provide vector search capabilities (with multiple options)

The overall architecture adopts a microservices design, with components communicating through well-defined APIs and networks.

## Shared Environment Variables 🔄

The `docker-compose.yaml` defines a large number of shared environment variables (`shared-api-worker-env`) for use by both the API and Worker services. These include:

- **Service URL Configuration**: Communication addresses between services
- **Logging Configuration**: Log levels, file paths, formats, etc.
- **Database Connections**: PostgreSQL connection parameters
- **Redis Configuration**: Cache service parameters
- **Storage Configuration**: File storage related parameters
- **Vector Database Configuration**: Connection parameters for various vector databases
- **Security Configuration**: Keys and authentication parameters

These environment variables are shared between multiple services using YAML anchors (`&shared-api-worker-env`) and references (`<<: *shared-api-worker-env`), avoiding duplicate configuration.

## Core Services 🚀

### API Service (api)

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

- **Function**: Provides Dify's core API services, handling user requests and business logic
- **Dependencies**: Database (db) and Redis cache
- **Data Persistence**: User files stored through volume mounting
- **Networks**: Connected to default network and SSRF proxy network

### Worker Service (worker)

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

- **Function**: Celery worker process, handling asynchronous tasks and queues
- **Dependencies**: Same as the API service
- **Feature**: Uses the same image as the API service but with a different startup mode (MODE: worker)

### Web Frontend (web)

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

- **Function**: Provides Dify's web interface
- **Technology**: Frontend application built with NextJS
- **Environment Variables**: Configure API endpoints and performance parameters

## Infrastructure Services ⚙️

### Database (db)

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

- **Function**: PostgreSQL database, storing Dify's business data
- **Configuration**: Database performance optimized through command parameters
- **Health Check**: Ensures service availability

### Redis Cache (redis)

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

- **Function**: Provides caching and message queue services
- **Security**: Configured with password protection
- **Persistence**: Data storage mounted to the host machine

### Nginx Gateway (nginx)

```yaml
nginx:
  image: nginx:latest
  restart: always
  volumes:
    - ./nginx/nginx.conf.template:/etc/nginx/nginx.conf.template
    - ./nginx/proxy.conf.template:/etc/nginx/proxy.conf.template
    - ./nginx/https.conf.template:/etc/nginx/https.conf.template
    # ... more volume mounts
  entrypoint: [ 'sh', '-c', "cp /docker-entrypoint-mount.sh /docker-entrypoint.sh && sed -i 's/\r$$//' /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh && /docker-entrypoint.sh" ]
  environment:
    NGINX_SERVER_NAME: ${NGINX_SERVER_NAME:-_}
    NGINX_HTTPS_ENABLED: ${NGINX_HTTPS_ENABLED:-false}
    # ... more environment variables
  depends_on:
    - api
    - web
  ports:
    - '${EXPOSE_NGINX_PORT:-80}:${NGINX_PORT:-80}'
    - '${EXPOSE_NGINX_SSL_PORT:-443}:${NGINX_SSL_PORT:-443}'
```

- **Function**: Reverse proxy and routing service
- **Configuration**: Flexibly configured through template files and environment variables
- **Port Mapping**: Exposes internal services to the host machine

## Security Services 🔒

### Sandbox (sandbox)

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

- **Function**: Provides an isolated code execution environment
- **Security**: Secured through API keys and network isolation
- **Proxy**: Accesses external resources through SSRF proxy

### SSRF Proxy (ssrf_proxy)

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

- **Function**: Prevents Server-Side Request Forgery (SSRF) attacks
- **Implementation**: Uses Squid proxy server
- **Networks**: Positioned between internal network and default network

## Vector Database Options 🧠

Dify provides multiple vector database options, with Weaviate as the default:

### Weaviate (Default)

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
    # ... more configuration
```

- **Function**: Default vector database, used for semantic search
- **Authentication**: Supports API key authentication

### Other Vector Database Options

The configuration file includes several vector database options, managed using Docker Compose profiles:

- **Qdrant**: Lightweight vector search engine
- **Milvus**: Distributed vector database
- **PGVector**: Vector extension for PostgreSQL
- **Chroma**: Open-source embedded vector database
- **Elasticsearch**: Full-text search engine
- **MyScale**: Vector retrieval solution based on ClickHouse

## Network Configuration 🌐

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

- **ssrf_proxy_network**: Internal network for communication between sandbox, API, and SSRF proxy, cannot access external resources
- **milvus**: Network for Milvus services
- **opensearch-net**: Network for OpenSearch services

## Storage Volume Configuration 💾

```yaml
volumes:
  oradata:
  dify_es01_data:
```

- **Named Volumes**: Used for persistent storage for Oracle and Elasticsearch
- **Bind Mounts**: The `./volumes/` directory is used in multiple places for bind mounting to containers

## Deployment Recommendations 💡

1. **Minimum Required Services**:
   - Core Services: api, worker, web
   - Infrastructure: db, redis
   - Security Services: sandbox, ssrf_proxy
   - Gateway: nginx
   - Vector Database: weaviate (default) or one of the other options

2. **Resource Requirements**:
   - Minimum Configuration: 2 CPU cores, 4GB memory
   - Recommended Configuration: 4 CPU cores, 8GB memory

3. **Security Considerations**:
   - Change default passwords
   - Restrict access ports
   - Configure HTTPS (production environment)

4. **Custom Configuration**:
   - Override default configuration values through the .env file
   - Optimize database parameters for production environments

5. **Choosing a Vector Database**:
   - Based on the volume of data to be processed and query performance requirements
   - Activate the required database through profiles

---

## Related Links 🔗

- [中文文档](../Docker-Compose详解.md)
- [Dify Official Documentation](https://docs.dify.ai/)
- [Dify GitHub Repository](https://github.com/langgenius/dify) 