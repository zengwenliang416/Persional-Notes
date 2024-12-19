# 【Docker】Docker 完全指南

## 目录
[1. 目录](#目录)
[2. 一、Docker 概述](#一docker-概述)
    [2.1 Docker 的核心概念](#docker-的核心概念)
[3. 二、Docker 安装与配置](#二docker-安装与配置)
    [3.1 安装 Docker](#安装-docker)
    [3.2 配置 Docker](#配置-docker)
[4. 三、Docker 基本操作](#三docker-基本操作)
    [4.1 镜像管理](#镜像管理)
    [4.2 容器管理](#容器管理)
    [4.3 数据管理](#数据管理)
    [4.4 网络管理](#网络管理)
[5. 四、Dockerfile 最佳实践](#四dockerfile-最佳实践)
    [5.1 基本结构](#基本结构)
    [5.2 优化建议](#优化建议)
[6. 五、Docker Compose 详解](#五docker-compose-详解)
    [6.1 Docker Compose 简介](#docker-compose-简介)
    [6.2 安装 Docker Compose](#安装-docker-compose)
    [6.3 docker-compose.yml 配置详解](#docker-composeyml-配置详解)
    [6.4 重要配置项说明](#重要配置项说明)
    [6.5 常用命令详解](#常用命令详解)
    [6.6 实际应用示例](#实际应用示例)
        [    生产环境部署](#生产环境部署)
    [6.8 最佳实践](#最佳实践)
[7. 六、Docker 安全最佳实践](#六docker-安全最佳实践)
[8. 七、常见问题与解决方案](#七常见问题与解决方案)
[9. 八、参考资源](#八参考资源)



## 一、Docker 概述

Docker 是一个开源的容器化平台，它使开发者能够将应用程序与其依赖项打包到一个可移植的容器中，确保应用程序在任何环境中都能一致地运行。

### Docker 的核心概念

1. **镜像（Image）**：
   - 一个只读的模板，包含创建 Docker 容器的指令
   - 可以理解为一个应用程序的"快照"
   - 基于分层架构，每一层都是只读的

2. **容器（Container）**：
   - 镜像的运行实例
   - 可以被创建、启动、停止、删除和暂停
   - 相互隔离，互不影响

3. **仓库（Repository）**：
   - 用于存储和分发 Docker 镜像
   - Docker Hub 是默认的公共仓库
   - 企业可以搭建私有仓库

## 二、Docker 安装与配置

### 安装 Docker

在 macOS 上安装：
```bash
# 使用 Homebrew 安装
brew install --cask docker

# 启动 Docker Desktop
open /Applications/Docker.app
```

在 Linux 上安装：
```bash
# 安装必要的系统工具
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common

# 添加 Docker 的官方 GPG 密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# 添加 Docker 仓库
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# 安装 Docker
sudo apt-get update
sudo apt-get install docker-ce
```

### 配置 Docker

1. **配置镜像加速**：
```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}
```

2. **配置资源限制**：
   - 设置容器的 CPU 和内存限制
   - 配置存储驱动
   - 设置日志驱动

## 三、Docker 基本操作

### 镜像管理

```bash
# 搜索镜像
docker search nginx

# 拉取镜像
docker pull nginx:latest

# 查看本地镜像
docker images

# 删除镜像
docker rmi nginx:latest

# 构建镜像
docker build -t myapp:1.0 .

# 导出/导入镜像
docker save -o nginx.tar nginx:latest
docker load -i nginx.tar
```

### 容器管理

```bash
# 创建并运行容器
docker run -d --name mynginx -p 80:80 nginx

# 容器操作
docker start mynginx
docker stop mynginx
docker restart mynginx
docker rm mynginx

# 查看容器
docker ps
docker ps -a

# 进入容器
docker exec -it mynginx bash

# 查看日志
docker logs -f mynginx
```

### 数据管理

```bash
# 创建数据卷
docker volume create mydata

# 查看数据卷
docker volume ls

# 删除数据卷
docker volume rm mydata

# 使用数据卷
docker run -v mydata:/data nginx
```

### 网络管理

```bash
# 创建网络
docker network create mynet

# 查看网络
docker network ls

# 连接容器到网络
docker network connect mynet mynginx

# 断开网络连接
docker network disconnect mynet mynginx
```

## 四、Dockerfile 最佳实践

### 基本结构

```dockerfile
# 使用官方基础镜像
FROM node:14-alpine

# 设置工作目录
WORKDIR /app

# 复制依赖文件
COPY package*.json ./

# 安装依赖
RUN npm install

# 复制源代码
COPY . .

# 暴露端口
EXPOSE 3000

# 启动命令
CMD ["npm", "start"]
```

### 优化建议

1. **多阶段构建**：
   - 使用多个 FROM 指令
   - 只复制必要的文件到最终镜像
   - 减小最终镜像大小

2. **层优化**：
   - 合并 RUN 指令
   - 清理不必要的文件
   - 使用 .dockerignore

3. **缓存利用**：
   - 合理排序指令
   - 将易变的指令放在后面
   - 使用 BuildKit 缓存

## 五、Docker Compose 详解

### Docker Compose 简介

Docker Compose 是一个用于定义和运行多容器 Docker 应用程序的工具。使用 YAML 文件来配置应用程序的服务，然后使用单个命令创建和启动所有服务。

### 安装 Docker Compose

```bash
# macOS 和 Windows 的 Docker Desktop 已包含 Docker Compose

# Linux 安装
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker-compose --version
```

### docker-compose.yml 配置详解

```yaml
version: '3.8'  # 指定 Compose 文件版本

services:
  # Web 应用服务
  webapp:
    build: 
      context: ./webapp  # 构建上下文路径
      dockerfile: Dockerfile  # Dockerfile 文件名
    image: webapp:1.0  # 指定镜像名
    container_name: my-webapp  # 容器名称
    ports:
      - "8080:80"  # 端口映射
    environment:  # 环境变量
      - NODE_ENV=production
      - API_KEY=secret
    env_file: .env  # 从文件加载环境变量
    volumes:  # 数据卷
      - ./webapp:/app
      - logs:/var/log
    networks:  # 网络配置
      - frontend
      - backend
    depends_on:  # 依赖关系
      - redis
      - db
    deploy:  # 部署配置
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    restart: unless-stopped  # 重启策略
    healthcheck:  # 健康检查
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Redis 服务
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - backend

  # 数据库服务
  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend

# 定义数据卷
volumes:
  logs:
  redis-data:
  db-data:

# 定义网络
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
```

### 重要配置项说明

1. **version**：
   - 指定 Compose 文件格式版本
   - 建议使用最新的稳定版本
   - 不同版本支持的功能有所不同

2. **services**：
   - build: 构建配置
   - image: 指定使用的镜像
   - container_name: 容器名称
   - ports: 端口映射
   - environment: 环境变量
   - volumes: 数据卷挂载
   - networks: 网络配置
   - depends_on: 服务依赖
   - command: 覆盖默认命令
   - entrypoint: 覆盖默认入口点
   - restart: 重启策略
   - deploy: 部署配置

3. **networks**：
   - driver: 网络驱动类型
   - external: 使用外部网络
   - ipam: IP 地址管理
   - enable_ipv6: 启用 IPv6

4. **volumes**：
   - driver: 存储驱动类型
   - external: 使用外部数据卷
   - labels: 元数据标签

### 常用命令详解

```bash
# 构建服务
docker-compose build [service...]

# 创建和启动服务
docker-compose up [options] [service...]
  -d: 后台运行
  --build: 构建镜像
  --no-deps: 不启动链接的服务
  --scale SERVICE=NUM: 设置服务数量

# 停止和删除服务
docker-compose down [options]
  --volumes: 删除数据卷
  --rmi all: 删除所有镜像
  --remove-orphans: 删除孤立容器

# 服务生命周期管理
docker-compose start [service...]   # 启动服务
docker-compose stop [service...]    # 停止服务
docker-compose restart [service...] # 重启服务
docker-compose pause [service...]   # 暂停服务
docker-compose unpause [service...] # 恢复服务

# 查看服务状态
docker-compose ps [service...]      # 列出服务状态
docker-compose top [service...]     # 查看进程
docker-compose logs [service...]    # 查看日志
  -f: 实时查看
  --tail=n: 显示最后n行

# 执行命令
docker-compose exec [options] service command
  -d: 后台运行
  --user USER: 指定用户
  --workdir DIR: 指定工作目录

# 服务扩缩容
docker-compose scale service=num

# 配置验证
docker-compose config
  --services: 列出服务
  --volumes: 列出数据卷
```

### 实际应用示例

#### Web 应用开发环境

```yaml
version: '3.8'

services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    command: npm run dev

  backend:
    build: ./backend
    ports:
      - "8000:8000"
    volumes:
      - ./backend:/app
    environment:
      - DEBUG=True
      - DB_HOST=db
    depends_on:
      - db

  db:
    image: postgres:13-alpine
    environment:
      - POSTGRES_DB=devdb
      - POSTGRES_USER=devuser
      - POSTGRES_PASSWORD=devpass
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

#### 生产环境部署

```yaml
version: '3.8'

services:
  app:
    image: myapp:${TAG:-latest}
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
    ports:
      - "80:80"
    environment:
      - NODE_ENV=production
    networks:
      - web
      - internal

  redis:
    image: redis:6-alpine
    volumes:
      - redis:/data
    networks:
      - internal

  db:
    image: postgres:13
    volumes:
      - db:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
    secrets:
      - db_password
    networks:
      - internal

networks:
  web:
    external: true
  internal:
    driver: overlay
    internal: true

volumes:
  redis:
  db:

secrets:
  db_password:
    external: true
```

### 最佳实践

1. **环境变量管理**：
   - 使用 .env 文件管理环境变量
   - 不同环境使用不同的 compose 文件
   - 敏感信息使用 secrets 管理

2. **服务依赖处理**：
   - 合理使用 depends_on
   - 实现健康检查
   - 处理启动顺序

3. **数据持久化**：
   - 使用命名卷而不是绑定挂载
   - 备份重要数据
   - 注意权限设置

4. **网络安全**：
   - 内部服务使用内部网络
   - 限制端口暴露
   - 使用 secrets 管理敏感信息

5. **资源管理**：
   - 设置资源限制
   - 监控资源使用
   - 合理设置扩缩容策略

## 六、Docker 安全最佳实践

1. **镜像安全**：
   - 使用官方镜像
   - 定期更新基础镜像
   - 扫描镜像漏洞

2. **容器安全**：
   - 限制容器资源
   - 使用非 root 用户
   - 启用安全选项

3. **网络安全**：
   - 使用用户定义网络
   - 限制端口暴露
   - 配置防火墙规则

## 七、常见问题与解决方案

1. **容器无法启动**：
   - 检查端口冲突
   - 查看错误日志
   - 验证配置文件

2. **镜像构建失败**：
   - 检查 Dockerfile 语法
   - 确认构建上下文
   - 查看构建日志

3. **网络连接问题**：
   - 检查网络配置
   - 验证 DNS 设置
   - 测试容器间通信

## 八、参考资源

1. [Docker 官方文档](https://docs.docker.com/)
2. [Docker Hub](https://hub.docker.com/)
3. [Docker Compose 文档](https://docs.docker.com/compose/)
