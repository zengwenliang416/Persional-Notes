# 【Dify】Docker Compose Setup Process Explained 🔧

> This document details the complete process of configuring and deploying the Dify platform's Docker Compose environment, helping you understand the purpose of each step and best practices.

## Table of Contents 📑

- [Prerequisites](#prerequisites)
- [Configuration File Generation Process](#configuration-file-generation-process)
- [Environment Variable Configuration](#environment-variable-configuration)
- [Service Component Orchestration](#service-component-orchestration)
- [Network Configuration Strategy](#network-configuration-strategy)
- [Data Persistence](#data-persistence)
- [Security Considerations](#security-considerations)
- [Startup and Validation](#startup-and-validation)
- [Common Issues and Solutions](#common-issues-and-solutions)

## Prerequisites ✅

Before starting to set up Dify's Docker Compose environment, ensure your system meets the following requirements:

### System Requirements

- Operating System: Linux (Ubuntu/Debian/CentOS), macOS, or Windows
- Docker Version: 20.10.0 or higher
- Docker Compose Version: 2.0.0 or higher
- Minimum Configuration: 2 CPU cores, 4GB memory, 30GB storage space
- Recommended Configuration: 4 CPU cores, 8GB memory, 50GB storage space

### Pre-installation Check

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version

# Check Docker service status
systemctl status docker  # Linux
docker info  # All platforms
```

## Configuration File Generation Process 🔄

### 1. Obtain Code and Configuration Template

```bash
# Clone a specific version of the repository
git clone https://github.com/langgenius/dify.git --branch 0.15.3 dify-project
cd dify-project/docker
```

### 2. Generate docker-compose.yaml

Dify provides a script to automatically generate the docker-compose.yaml, which dynamically creates the final configuration based on a template:

```bash
# Execute the generation script
./generate_docker_compose
```

How the script works:
- Reads `docker-compose-template.yaml` as a base template
- Processes conditional logic and environment variable substitution
- Generates the complete docker-compose.yaml file

### 3. Configuration File Structure

The generated docker-compose.yaml file consists mainly of the following parts:

- **Shared Environment Variable Block**: Defines shared configurations using YAML anchors
- **Core Service Definitions**: API, Worker, Web frontend, and other core components
- **Infrastructure Services**: Database, cache, vector storage, etc.
- **Network Definitions**: Network isolation and connection strategies between services
- **Volume Definitions**: Data persistence storage configuration

## Environment Variable Configuration 🔐

### 1. Create Environment Variable File

```bash
# Copy the example environment configuration
cp .env.example .env

# Edit the environment configuration
nano .env  # Or use another editor
```

### 2. Key Environment Variables Explained

Dify's environment variable configuration is divided into several functional groups:

#### Core Service Configuration

```properties
# Application access address configuration
CONSOLE_URL=http://localhost:8080/console
APP_URL=http://localhost:8080
API_URL=http://localhost:8080/api

# Security key (must be changed to a random string)
SECRET_KEY=your-secret-key-here

# Service mode configuration
DEPLOY_ENV=PRODUCTION
```

#### Database Configuration

```properties
# PostgreSQL database configuration
DB_USERNAME=postgres
DB_PASSWORD=difyai123456
DB_HOST=db
DB_PORT=5432
DB_DATABASE=dify

# Performance-related parameters
POSTGRES_MAX_CONNECTIONS=100
POSTGRES_SHARED_BUFFERS=128MB
```

#### Cache and Message Queue

```properties
# Redis configuration
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=difyai123456
REDIS_DB=0

# Celery message queue
CELERY_BROKER_URL=redis://:difyai123456@redis:6379/1
```

#### Vector Database Configuration

```properties
# Default is Weaviate
VECTOR_STORE=weaviate
WEAVIATE_ENDPOINT=http://weaviate:8080
WEAVIATE_API_KEY=WVF5YThaHlkYwhGUSmCRgsX3tD5ngdN8pkih

# Optional alternative vector database configuration
# VECTOR_STORE=qdrant
# QDRANT_URL=http://qdrant:6333
```

### 3. Environment Variable Injection Mechanism

docker-compose.yaml uses two methods to inject environment variables:

1. **Shared Variable Block Reference**:
   ```yaml
   api:
     environment:
       <<: *shared-api-worker-env
       MODE: api
   ```

2. **Default Value Setting**:
   ```yaml
   # Format is ${VARIABLE:-default_value}
   DB_USERNAME: ${DB_USERNAME:-postgres}
   ```

This design achieves:
- Centralized variable management, reducing duplicate configuration
- Providing reasonable default values, simplifying initial configuration
- Maintaining configuration consistency across multiple services

## Service Component Orchestration 🧩

### 1. Core Service Configuration Analysis

#### API Service

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

Key points:
- Uses official image with specific version number
- Starts in API mode
- Mounts storage volume for data persistence
- Connects to multiple networks for function isolation and communication

#### Worker Service

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

Key points:
- Uses the same image as the API service
- Starts in Worker mode to handle asynchronous tasks
- Shares the API service's storage space

#### Web Frontend

```yaml
web:
  image: langgenius/dify-web:0.15.3
  restart: always
  environment:
    CONSOLE_API_URL: ${CONSOLE_API_URL:-}
    APP_API_URL: ${APP_API_URL:-}
```

Key points:
- Uses dedicated frontend image
- Only configures API address variables needed by the frontend

### 2. Infrastructure Service Configuration

#### Database Service

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

Key points:
- Uses lightweight Alpine version to reduce resource consumption
- Optimizes database performance through command line parameters
- Persists data to local volume

#### Redis Cache

```yaml
redis:
  image: redis:6-alpine
  restart: always
  command: redis-server --requirepass ${REDIS_PASSWORD:-difyai123456}
  volumes:
    - ./volumes/redis/data:/data
```

Key points:
- Uses lightweight Alpine version
- Sets password protection
- Persists data to local volume

#### Vector Database (Weaviate)

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

Key points:
- Activated by default (empty profile)
- Enables API key authentication
- Persists data to local volume

### 3. Security Service Configuration

#### Sandbox Service

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

Key points:
- Dedicated security sandbox image
- API key authentication
- Controls network access through proxy
- Uses isolated network

#### SSRF Proxy

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

Key points:
- Implements SSRF protection based on Squid proxy
- Uses configuration template
- Acts as a bridge for network isolation

### 4. Gateway Configuration

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

Key points:
- Uses configuration templates for dynamic configuration
- Maps ports to expose services
- Provides HTTPS support options

## Network Configuration Strategy 🔒

### 1. Network Architecture Design

```yaml
networks:
  ssrf_proxy_network:
    driver: bridge
    internal: true  # Cannot access external network
  milvus:
    driver: bridge
  opensearch-net:
    driver: bridge
    internal: true
  default:
    driver: bridge  # Default network
```

Dify adopts a multi-network architecture:

- **Internal Security Network** (ssrf_proxy_network):
  - Connects sandbox and proxy services
  - Cannot directly access external networks
  - Provides a security isolation layer for code execution

- **Vector Database Networks**:
  - Provides independent networks for each vector database
  - Limits unnecessary communication between services

- **Default Network**:
  - Connects main application components
  - Provides basic communication path

### 2. Service Network Allocation

```yaml
api:
  networks:
    - ssrf_proxy_network  # For secure sandbox calls
    - default  # For basic component communication

worker:
  networks:
    - ssrf_proxy_network
    - default

ssrf_proxy:
  networks:
    - ssrf_proxy_network  # Internal network
    - default  # Bridge to external
```

This network separation mechanism provides multi-layer security protection:

1. Core components can communicate with each other through the default network
2. Security-sensitive services are isolated through the internal network
3. Proxy is used as a security gateway to control external access

## Data Persistence 💾

### 1. Volume Mapping Strategy

Dify adopts consistent volume naming and mapping conventions:

```yaml
volumes:
  # Named volumes
  oradata:  # Oracle database volume
  dify_es01_data:  # Elasticsearch data volume
  
  # Bind mounts
  - ./volumes/app/storage:/app/api/storage  # Application storage
  - ./volumes/db/data:/var/lib/postgresql/data  # Database storage
  - ./volumes/redis/data:/data  # Redis data
  - ./volumes/weaviate:/var/lib/weaviate  # Vector database
```

### 2. Data Directory Structure

The generated data directory structure is as follows:

```
docker/
└── volumes/
    ├── app/
    │   └── storage/  # User uploads, temporary files, etc.
    ├── db/
    │   └── data/     # PostgreSQL data files
    ├── redis/
    │   └── data/     # Redis persistent data
    ├── weaviate/     # Vector database storage
    ├── sandbox/
    │   └── dependencies/  # Sandbox dependencies
    └── certbot/      # SSL certificates (optional)
```

### 3. Persistence Best Practices

- All persistent data is centrally stored in the volumes directory
- Each service has an independent data directory
- Relative path mapping simplifies deployment and migration
- When backup is needed, only the volumes directory needs to be backed up

## Security Considerations 🛡️

### 1. Password and Credential Management

```yaml
# Security configuration in .env file
SECRET_KEY=your-secret-key-here  # Application key
DB_PASSWORD=strong-password  # Database password
REDIS_PASSWORD=strong-password  # Redis password
WEAVIATE_API_KEY=custom-api-key  # Vector database key
SANDBOX_API_KEY=custom-sandbox-key  # Sandbox service key
```

Security recommendations:
- Modify all default passwords in production environment
- Use randomly generated strong passwords
- Use different passwords for different services
- Store keys in .env file rather than docker-compose.yaml

### 2. Network Security Strategy

- Use internal networks to isolate critical services
- Control external network access through SSRF proxy
- Restrict code execution in sandbox environment
- Configure external access rules in Nginx

## Startup and Validation 🚀

### 1. Start Services

```bash
# Start basic services
docker-compose up -d

# Start services including specific vector database
docker-compose --profile qdrant up -d
```

### 2. Startup Sequence Control

Docker Compose controls the startup sequence based on dependencies:

1. Infrastructure services (db, redis, vector database)
2. Security services (ssrf_proxy, sandbox)
3. Core services (api, worker)
4. Gateway (nginx) and frontend (web)

### 3. Service Health Checks

Multiple services are configured with health checks to ensure they are running properly:

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

### 4. Validate Deployment

After completing the deployment, you can validate it through the following methods:

```bash
# Check the status of all containers
docker-compose ps

# View service logs
docker-compose logs api

# Access the Web interface
open http://localhost:8080/install
```

## Common Issues and Solutions ❓

### 1. Database Connection Issues

**Problem**: API service cannot connect to the database

**Solution**:
- Check if the database container is running `docker-compose ps db`
- Verify database credentials `docker-compose exec db psql -U postgres -c "SELECT 1"`
- Check if DB_HOST is configured as "db", not "localhost"

### 2. Port Conflicts

**Problem**: Startup fails, showing port is already in use

**Solution**:
- Edit the .env file to modify EXPOSE_NGINX_PORT
- Check and close other services using the same port
- Check firewall settings

### 3. Vector Database Initialization Failure

**Problem**: Vector database starts but application cannot connect

**Solution**:
- Check vector database logs `docker-compose logs weaviate`
- Verify that the VECTOR_STORE environment variable is set correctly
- Confirm that security credentials are configured correctly

### 4. Storage Permission Issues

**Problem**: File upload fails or cannot create files

**Solution**:
- Ensure the volumes directory has the correct permissions
  ```bash
  chmod -R 755 volumes/
  chown -R 1000:1000 volumes/app/
  ```
- Check if directory mounting is correct `docker-compose exec api ls -la /app/api/storage`

---

## Related Links 🔗

- [中文版本](../【Dify】Docker-Compose搭建过程详解.md)
- [Dify Official Documentation](https://docs.dify.ai/)
- [Docker Compose Official Documentation](https://docs.docker.com/compose/)
- [Dify GitHub Repository](https://github.com/langgenius/dify) 