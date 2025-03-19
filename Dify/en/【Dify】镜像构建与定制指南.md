# 【Dify】Docker Image Building and Customization Guide 🐳

> This document details how to build, optimize, and customize Docker images for Dify from source code to meet specific deployment requirements. By building your own images, you can add custom features, optimize performance, or adapt to specific hardware architectures.

## Table of Contents 📑

- [Prerequisites](#prerequisites)
- [Source Code Acquisition and Preparation](#source-code-acquisition-and-preparation)
- [Backend Service Image Building](#backend-service-image-building)
- [Web Frontend Image Building](#web-frontend-image-building)
- [Other Component Images](#other-component-images)
- [Multi-architecture Support](#multi-architecture-support)
- [Image Optimization](#image-optimization)
- [Image Publishing and Management](#image-publishing-and-management)
- [Integration and Validation](#integration-and-validation)
- [Common Issues](#common-issues)

## Prerequisites ✅

Before starting to build Dify images, ensure your environment meets the following requirements:

### System Requirements

- Linux/Unix operating system (Ubuntu 20.04/22.04 or Debian 11 recommended)
- At least 4GB of memory
- At least 30GB of available disk space
- Good internet connection

### Software Requirements

1. **Install Docker and Docker Buildx**

   ```bash
   # Install Docker
   curl -fsSL https://get.docker.com | sh
   
   # Enable Buildx functionality
   docker buildx install
   
   # Create and use a new builder instance
   docker buildx create --name dify-builder --use
   ```

2. **Install Necessary Tools**

   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install -y git make curl python3-pip nodejs npm
   
   # Install the latest version of Node.js
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

## Source Code Acquisition and Preparation 📥

### 1. Clone the Dify Repository

```bash
# Clone a specific version (using 0.15.3 as an example)
git clone https://github.com/langgenius/dify.git --branch 0.15.3 dify-source
cd dify-source
```

### 2. Project Structure

The Dify project mainly consists of the following parts:

- `api/` - Backend API service and Worker service source code
- `web/` - Web frontend source code
- `docker/` - Docker configuration files

## Backend Service Image Building 🛠️

Dify's backend includes API service and Worker service, which share the same image but start in different modes.

### 1. Build the API/Worker Base Image

Navigate to the API directory and start building:

```bash
cd api

# Build the base image
docker build -t langgenius/dify-api:0.15.3 -f ./Dockerfile .
```

The build process includes:
- Installing Python dependencies
- Configuring the service environment
- Setting up the application entry point

### 2. Customize the Backend Image

If you need to customize the backend image, you can create your own `Dockerfile`:

```Dockerfile
# Based on the official image
FROM langgenius/dify-api:0.15.3

# Install additional Python packages
COPY requirements-custom.txt /app/
RUN pip install --no-cache-dir -r /app/requirements-custom.txt

# Add custom scripts or configurations
COPY custom-scripts/ /app/custom-scripts/
RUN chmod +x /app/custom-scripts/*.sh

# Custom environment variables
ENV CUSTOM_SETTING="value"
```

### 3. Multi-stage Build Optimization

To optimize image size, you can use multi-stage builds:

```Dockerfile
# Build stage
FROM python:3.10-slim as builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Final stage
FROM python:3.10-slim

WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .

ENV PATH=/root/.local/bin:$PATH
ENV PYTHONPATH=$PYTHONPATH:/app

CMD ["gunicorn", "app:app"]
```

## Web Frontend Image Building 🖥️

### 1. Build the Frontend Image

Navigate to the Web directory and start building:

```bash
cd web

# Build the frontend image
docker build -t langgenius/dify-web:0.15.3 -f ./Dockerfile .
```

The build process includes:
- Installing Node.js dependencies
- Building static assets
- Configuring the Next.js application

### 2. Customize the Frontend Image

To customize the frontend image, you can create a custom `Dockerfile`:

```Dockerfile
# Build stage
FROM node:18-alpine as builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Runtime stage
FROM node:18-alpine

WORKDIR /app
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules

# Custom environment variables (e.g., change default language)
ENV NEXT_PUBLIC_DEFAULT_LOCALE="en-US"

CMD ["npm", "start"]
```

## Other Component Images 🧩

Dify relies on multiple components, and you may need to build or customize images for these components:

### 1. Dify Sandbox Image

The Sandbox service is used for secure code execution, you can build it like this:

```bash
cd sandbox
docker build -t langgenius/dify-sandbox:0.2.10 .
```

### 2. SSRF Proxy Image

You can build a custom SSRF proxy based on the official image:

```Dockerfile
FROM ubuntu/squid:latest

COPY custom-squid.conf /etc/squid/squid.conf
```

## Multi-architecture Support 🏗️

To support multiple CPU architectures (such as x86_64 and ARM64), use Docker Buildx:

```bash
# API service multi-architecture build
cd api
docker buildx build --platform linux/amd64,linux/arm64 \
  -t yourusername/dify-api:0.15.3 \
  --push .

# Web frontend multi-architecture build
cd ../web
docker buildx build --platform linux/amd64,linux/arm64 \
  -t yourusername/dify-web:0.15.3 \
  --push .
```

## Image Optimization ⚡

### 1. Reduce Image Size

- Use multi-stage builds
- Remove unnecessary dependencies and caches
- Use Alpine base images

```Dockerfile
# API service optimization example
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

### 2. Security Optimization

- Run containers as non-root user
- Remove sensitive information

```Dockerfile
# Create and use a non-root user
RUN addgroup -S dify && adduser -S dify -G dify
USER dify

# Remove sensitive information
RUN rm -rf .git* tests/ docs/
```

## Image Publishing and Management 📦

### 1. Push to Docker Hub or Private Registry

```bash
# Log in to Docker Hub
docker login

# Push images
docker push yourusername/dify-api:0.15.3
docker push yourusername/dify-web:0.15.3
```

### 2. Use GitHub Actions for Automated Building

Create `.github/workflows/build-images.yml`:

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

## Integration and Validation 🧪

After building all images, validate them using a custom `docker-compose.yaml` file:

```yaml
services:
  api:
    image: yourusername/dify-api:0.15.3
    # Rest of the configuration same as the original docker-compose file
  
  worker:
    image: yourusername/dify-api:0.15.3
    # Rest of the configuration same as the original docker-compose file
  
  web:
    image: yourusername/dify-web:0.15.3
    # Rest of the configuration same as the original docker-compose file
  
  # Other service configurations...
```

Start the services for validation:

```bash
docker-compose up -d
```

## Common Issues ❓

### Dependency Issues During Build

**Problem**: Python or Node.js dependency installation fails during build

**Solution**:
1. Ensure you're using the correct base image version
2. Add necessary system dependencies
3. Configure domestic mirrors for pip or npm

```Dockerfile
# Python dependency problem solution
RUN pip config set global.index-url https://pypi.org/simple

# Node.js dependency problem solution
RUN npm config set registry https://registry.npmjs.org
```

### Multi-architecture Build Failure

**Problem**: Failure when building multi-architecture images

**Solution**:
1. Ensure Docker version is at least 20.10.0
2. Install and configure the correct QEMU emulator

```bash
docker run --privileged --rm tonistiigi/binfmt --install all
```

### Image Size Too Large

**Problem**: Built images are too large

**Solution**:
1. Use multi-stage builds
2. Combine multiple commands in the same RUN instruction
3. Delete unnecessary files and caches

```Dockerfile
RUN pip install --no-cache-dir -r requirements.txt \
    && rm -rf /root/.cache \
    && find /usr/local -name '*.pyc' -delete
```

---

## Related Links 🔗

- [中文版本](../【Dify】镜像构建与定制指南.md)
- [Dify Official Documentation](https://docs.dify.ai/)
- [Docker Official Documentation](https://docs.docker.com/build/)
- [Docker Compose Official Documentation](https://docs.docker.com/compose/) 