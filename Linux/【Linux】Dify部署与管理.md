# 【Linux】Dify部署与管理指南 🐧🚀

> Dify是一个强大的LLMOps平台，用于构建和管理基于大语言模型的应用。本文档将详细介绍如何在Linux环境下部署和管理Dify服务。

## 目录 📑

- [环境准备](#环境准备)
- [安装流程](#安装流程)
- [配置说明](#配置说明)
- [启动与停止](#启动与停止)
- [日志管理](#日志管理)
- [系统监控](#系统监控)
- [问题排查](#问题排查)
- [性能优化](#性能优化)
- [相关链接](#相关链接)

## 环境准备 🛠️

### 系统要求

- 操作系统：Ubuntu 20.04/22.04, CentOS 7/8, Debian 10/11
- CPU：至少2核心 (推荐4核心以上)
- 内存：至少4GB (推荐8GB以上)
- 存储：至少30GB可用空间
- 网络：稳定的互联网连接

### 安装Docker和Docker Compose

```bash
# 安装必要的系统工具
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# 添加Docker官方GPG密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# 设置Docker仓库
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# 安装Docker CE
sudo apt-get update
sudo apt-get install -y docker-ce

# 安装Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 将当前用户添加到docker组
sudo usermod -aG docker $USER
```

安装完成后，注销并重新登录以应用组更改，或者运行：

```bash
newgrp docker
```

验证安装：

```bash
# 检查Docker版本
docker --version

# 检查Docker Compose版本
docker-compose --version
```

## 安装流程 📥

### 1. 克隆Dify代码仓库

```bash
# 克隆指定版本（此处使用0.15.3版本）
git clone https://github.com/langgenius/dify.git --branch 0.15.3 dify-project
```

### 2. 进入项目并生成Docker Compose配置

```bash
cd dify-project/docker
./generate_docker_compose
```

### 3. 配置环境变量

创建并编辑`.env`文件：

```bash
cp .env.example .env
nano .env  # 或者使用vim、gedit等编辑器
```

关键配置项：

```properties
# 核心服务URL配置
CONSOLE_URL=http://your-server-ip:8080/console
APP_URL=http://your-server-ip:8080

# 数据库配置（默认使用内置PostgreSQL）
DB_USERNAME=postgres
DB_PASSWORD=difyai123456  # 建议修改为强密码
DB_HOST=db
DB_PORT=5432
DB_DATABASE=dify

# Redis配置（默认使用内置Redis）
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=difyai123456  # 建议修改为强密码

# 向量数据库配置（默认使用Weaviate）
VECTOR_STORE=weaviate
WEAVIATE_ENDPOINT=http://weaviate:8080
WEAVIATE_API_KEY=WVF5YThaHlkYwhGUSmCRgsX3tD5ngdN8pkih

# 安全配置
SECRET_KEY=your-secret-key  # 必须修改为随机字符串
```

生成安全密钥：

```bash
# 生成随机密钥
openssl rand -base64 42
```

### 4. 启动服务

```bash
# 启动所有服务
docker-compose up -d
```

## 配置说明 ⚙️

### 重要配置文件

- **docker-compose.yaml**: 主要容器编排配置
- **.env**: 环境变量配置
- **nginx/conf.d/default.conf**: Nginx配置

### 目录结构

```
dify-project/
├── docker/
│   ├── volumes/         # 持久化数据目录
│   │   ├── app/         # 应用数据
│   │   ├── db/          # 数据库数据
│   │   ├── redis/       # Redis数据
│   │   └── weaviate/    # 向量数据库数据
│   ├── nginx/           # Nginx配置
│   ├── ssrf_proxy/      # SSRF代理配置
│   └── .env             # 环境变量
```

### 系统用户和权限

Docker容器内的服务通常以非root用户运行。确保`volumes`目录有适当的权限：

```bash
# 设置适当的权限
sudo chown -R 1000:1000 docker/volumes/
```

## 启动与停止 🔄

### 启动服务

```bash
cd dify-project/docker
docker-compose up -d
```

### 停止服务

```bash
docker-compose down
```

### 重启特定服务

```bash
# 重启API服务
docker-compose restart api

# 重启Web服务
docker-compose restart web
```

### 服务状态检查

```bash
# 查看所有容器状态
docker-compose ps

# 查看容器资源使用情况
docker stats
```

## 日志管理 📋

### 查看服务日志

```bash
# 查看所有服务的日志
docker-compose logs

# 实时查看API服务日志
docker-compose logs -f api

# 查看最近100行Web服务日志
docker-compose logs --tail=100 web
```

### 日志存储位置

日志存储在各个容器内，但也可以配置外部日志收集系统如ELK Stack或Loki。

### 日志轮转

Docker默认使用json-file日志驱动，可以在docker-compose.yaml中配置日志轮转：

```yaml
services:
  api:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"
```

## 系统监控 📊

### 资源监控

使用标准Linux监控工具：

```bash
# 进程和资源监控
htop

# 磁盘使用情况
df -h

# 目录大小
du -sh docker/volumes/*
```

### Docker容器监控

可以使用Docker自带工具或第三方监控解决方案：

```bash
# 容器资源使用
docker stats

# 安装Portainer（Docker可视化管理工具）
docker volume create portainer_data
docker run -d -p 9000:9000 --name=portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data portainer/portainer-ce
```

访问`http://your-server-ip:9000`设置Portainer。

## 问题排查 🔍

### 常见问题及解决方案

1. **数据库连接问题**

   检查数据库容器是否运行，以及连接配置是否正确：

   ```bash
   # 检查数据库容器状态
   docker-compose ps db
   
   # 查看数据库日志
   docker-compose logs db
   ```

2. **API服务无法启动**

   ```bash
   # 检查API日志
   docker-compose logs api
   
   # 检查数据库迁移状态
   docker-compose exec api flask db-migrate-status
   ```

3. **Nginx代理问题**

   检查Nginx配置和日志：

   ```bash
   # 查看Nginx配置
   docker-compose exec nginx cat /etc/nginx/conf.d/default.conf
   
   # 查看Nginx日志
   docker-compose logs nginx
   ```

### 健康检查

为容器添加健康检查，以便自动识别服务异常：

```yaml
services:
  api:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5001/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## 性能优化 ⚡

### 系统层面优化

1. **文件系统优化**

   ```bash
   # 减少inode缓存过期时间
   sudo sysctl -w vm.vfs_cache_pressure=200
   
   # 增加文件句柄限制
   echo "* soft nofile 1048576" | sudo tee -a /etc/security/limits.conf
   echo "* hard nofile 1048576" | sudo tee -a /etc/security/limits.conf
   ```

2. **Docker优化**

   创建或编辑`/etc/docker/daemon.json`：

   ```json
   {
     "log-driver": "json-file",
     "log-opts": {
       "max-size": "10m",
       "max-file": "3"
     },
     "default-ulimits": {
       "nofile": {
         "Name": "nofile",
         "Hard": 1048576,
         "Soft": 1048576
       }
     }
   }
   ```

   重启Docker服务：

   ```bash
   sudo systemctl restart docker
   ```

### 应用层面优化

1. **数据库优化**

   编辑`.env`文件中的PostgreSQL参数：

   ```properties
   POSTGRES_MAX_CONNECTIONS=200
   POSTGRES_SHARED_BUFFERS=256MB
   POSTGRES_WORK_MEM=8MB
   POSTGRES_MAINTENANCE_WORK_MEM=128MB
   POSTGRES_EFFECTIVE_CACHE_SIZE=8192MB
   ```

2. **API服务优化**

   调整API服务的工作进程数：

   ```properties
   SERVER_WORKER_AMOUNT=4  # 设置为CPU核心数量
   SERVER_WORKER_CLASS=gevent
   SERVER_WORKER_CONNECTIONS=1000
   ```

3. **向量数据库优化**

   根据向量数据库的类型进行相应配置，例如Weaviate可以增加查询限制：

   ```properties
   WEAVIATE_QUERY_DEFAULTS_LIMIT=100
   ```

## 相关链接 🔗

- [English Version](en/【Linux】Dify部署与管理.md)
- [Dify官方文档](https://docs.dify.ai/)
- [Dify GitHub仓库](https://github.com/langgenius/dify)
- [Docker官方文档](https://docs.docker.com/)
- [Docker Compose文档](https://docs.docker.com/compose/) 