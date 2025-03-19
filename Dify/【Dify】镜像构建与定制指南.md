# 【Dify】Docker 镜像构建与定制指南 🐳

> 本文档详细介绍了如何从源码构建、优化和定制 Dify 的 Docker 镜像，以满足特定部署需求。通过自行构建镜像，您可以添加自定义功能、优化性能或适配特定硬件架构。

## 目录 📑

- [前置准备](#前置准备)
- [源码获取与准备](#源码获取与准备)
- [后端服务镜像构建](#后端服务镜像构建)
- [Web前端镜像构建](#web前端镜像构建)
- [其他组件镜像](#其他组件镜像)
- [多架构支持](#多架构支持)
- [镜像优化](#镜像优化)
- [镜像发布与管理](#镜像发布与管理)
- [整合与验证](#整合与验证)
- [常见问题](#常见问题)

## 前置准备 ✅

在开始构建 Dify 镜像之前，请确保您的环境满足以下要求：

### 系统要求

- Linux/Unix 操作系统（推荐 Ubuntu 20.04/22.04 或 Debian 11）
- 至少 4GB 内存
- 至少 30GB 可用磁盘空间
- 良好的互联网连接

### 软件要求

1. **安装 Docker 与 Docker Buildx**

   ```bash
   # 安装 Docker
   curl -fsSL https://get.docker.com | sh
   
   # 启用 Buildx 功能
   docker buildx install
   
   # 创建并使用新的构建器实例
   docker buildx create --name dify-builder --use
   ```

2. **安装必要工具**

   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install -y git make curl python3-pip nodejs npm
   
   # 安装最新版本的 Node.js
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

## 源码获取与准备 📥

### 1. 克隆 Dify 仓库

```bash
# 克隆特定版本（此处以 0.15.3 为例）
git clone https://github.com/langgenius/dify.git --branch 0.15.3 dify-source
cd dify-source
```

### 2. 项目结构

Dify 项目主要包含以下部分：

- `api/` - 后端 API 服务和 Worker 服务的源码
- `web/` - Web 前端源码
- `docker/` - Docker 配置文件

## 后端服务镜像构建 🛠️

Dify 的后端包含 API 服务和 Worker 服务，它们共用同一个镜像但以不同模式启动。

### 1. 构建 API/Worker 基础镜像

导航到 API 目录并开始构建：

```bash
cd api

# 构建基础镜像
docker build -t langgenius/dify-api:0.15.3 -f ./Dockerfile .
```

构建过程包括：
- 安装 Python 依赖
- 配置服务环境
- 设置应用入口

### 2. 定制后端镜像

如果需要定制后端镜像，可以创建自己的 `Dockerfile`：

```Dockerfile
# 基于官方镜像
FROM langgenius/dify-api:0.15.3

# 安装额外的 Python 包
COPY requirements-custom.txt /app/
RUN pip install --no-cache-dir -r /app/requirements-custom.txt

# 添加自定义脚本或配置
COPY custom-scripts/ /app/custom-scripts/
RUN chmod +x /app/custom-scripts/*.sh

# 自定义环境变量
ENV CUSTOM_SETTING="value"
```

### 3. 多阶段构建优化

为优化镜像大小，可以使用多阶段构建：

```Dockerfile
# 构建阶段
FROM python:3.10-slim as builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# 最终阶段
FROM python:3.10-slim

WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .

ENV PATH=/root/.local/bin:$PATH
ENV PYTHONPATH=$PYTHONPATH:/app

CMD ["gunicorn", "app:app"]
```

## Web前端镜像构建 🖥️

### 1. 构建前端镜像

导航到 Web 目录并开始构建：

```bash
cd web

# 构建前端镜像
docker build -t langgenius/dify-web:0.15.3 -f ./Dockerfile .
```

构建过程包括：
- 安装 Node.js 依赖
- 构建静态资源
- 配置 Next.js 应用

### 2. 定制前端镜像

要定制前端镜像，可以创建自定义 `Dockerfile`：

```Dockerfile
# 构建阶段
FROM node:18-alpine as builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# 运行阶段
FROM node:18-alpine

WORKDIR /app
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules

# 自定义环境变量（例如更改默认语言）
ENV NEXT_PUBLIC_DEFAULT_LOCALE="zh-Hans"

CMD ["npm", "start"]
```

## 其他组件镜像 🧩

Dify 依赖多个组件，您可能需要构建或自定义这些组件的镜像：

### 1. Dify Sandbox 镜像

Sandbox 服务用于安全执行代码，您可以这样构建：

```bash
cd sandbox
docker build -t langgenius/dify-sandbox:0.2.10 .
```

### 2. SSRF Proxy 镜像

可以基于官方镜像构建自定义的 SSRF 代理：

```Dockerfile
FROM ubuntu/squid:latest

COPY custom-squid.conf /etc/squid/squid.conf
```

## 多架构支持 🏗️

要支持多种 CPU 架构（如 x86_64 和 ARM64），使用 Docker Buildx：

```bash
# API 服务多架构构建
cd api
docker buildx build --platform linux/amd64,linux/arm64 \
  -t yourusername/dify-api:0.15.3 \
  --push .

# Web 前端多架构构建
cd ../web
docker buildx build --platform linux/amd64,linux/arm64 \
  -t yourusername/dify-web:0.15.3 \
  --push .
```

## 镜像优化 ⚡

### 1. 减小镜像大小

- 使用多阶段构建
- 删除不必要的依赖和缓存
- 使用 Alpine 基础镜像

```Dockerfile
# API 服务优化示例
FROM python:3.10-alpine as builder

WORKDIR /app
COPY requirements.txt .
RUN apk add --no-cache gcc musl-dev libffi-dev \
    && pip install --no-cache-dir --user -r requirements.txt \
    && apk del gcc musl-dev libffi-dev

FROM python:3.10-alpine

WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .

ENV PATH=/root/.local/bin:$PATH
RUN rm -rf tests/ *.md .git*

CMD ["gunicorn", "app:app"]
```

### 2. 安全性优化

- 使用非 root 用户运行容器
- 移除敏感信息

```Dockerfile
# 创建并使用非 root 用户
RUN addgroup -S dify && adduser -S dify -G dify
USER dify

# 移除敏感信息
RUN rm -rf .git* tests/ docs/
```

## 镜像发布与管理 📦

### 1. 推送到 Docker Hub 或私有仓库

```bash
# 登录到 Docker Hub
docker login

# 推送镜像
docker push yourusername/dify-api:0.15.3
docker push yourusername/dify-web:0.15.3
```

### 2. 使用 GitHub Actions 自动构建

创建 `.github/workflows/build-images.yml`：

```yaml
name: Build and Push Docker Images

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to DockerHub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Build and push API image
        uses: docker/build-push-action@v4
        with:
          context: ./api
          platforms: linux/amd64,linux/arm64
          push: true
          tags: yourusername/dify-api:${{ github.ref_name }}
      
      - name: Build and push Web image
        uses: docker/build-push-action@v4
        with:
          context: ./web
          platforms: linux/amd64,linux/arm64
          push: true
          tags: yourusername/dify-web:${{ github.ref_name }}
```

## 整合与验证 🧪

构建完所有镜像后，使用自定义 `docker-compose.yaml` 文件验证它们：

```yaml
services:
  api:
    image: yourusername/dify-api:0.15.3
    # 其余配置与原始 docker-compose 文件相同
  
  worker:
    image: yourusername/dify-api:0.15.3
    # 其余配置与原始 docker-compose 文件相同
  
  web:
    image: yourusername/dify-web:0.15.3
    # 其余配置与原始 docker-compose 文件相同
  
  # 其他服务配置...
```

启动服务进行验证：

```bash
docker-compose up -d
```

## 常见问题 ❓

### 构建过程中的依赖问题

**问题**: 构建时出现 Python 或 Node.js 依赖安装失败

**解决方案**:
1. 确保使用正确的基础镜像版本
2. 添加必要的系统依赖
3. 为 pip 或 npm 配置国内镜像源

```Dockerfile
# Python 依赖问题解决
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# Node.js 依赖问题解决
RUN npm config set registry https://registry.npmmirror.com
```

### 多架构构建失败

**问题**: 构建多架构镜像时失败

**解决方案**:
1. 确保 Docker 版本至少为 20.10.0
2. 安装并配置正确的 QEMU 模拟器

```bash
docker run --privileged --rm tonistiigi/binfmt --install all
```

### 镜像大小过大

**问题**: 构建的镜像体积过大

**解决方案**:
1. 使用多阶段构建
2. 在同一 RUN 指令中合并多个命令
3. 删除不必要的文件和缓存

```Dockerfile
RUN pip install --no-cache-dir -r requirements.txt \
    && rm -rf /root/.cache \
    && find /usr/local -name '*.pyc' -delete
```

---

## 相关链接 🔗

- [English Version](en/【Dify】镜像构建与定制指南.md)
- [Dify 官方文档](https://docs.dify.ai/)
- [Docker 官方文档](https://docs.docker.com/build/)
- [Docker Compose 官方文档](https://docs.docker.com/compose/) 