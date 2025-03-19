# 【Linux】Dify Deployment and Management Guide 🐧🚀

> Dify is a powerful LLMOps platform for building and managing applications based on large language models. This document will detail how to deploy and manage Dify services in a Linux environment.

## Table of Contents 📑

- [Environment Preparation](#environment-preparation)
- [Installation Process](#installation-process)
- [Configuration Details](#configuration-details)
- [Starting and Stopping](#starting-and-stopping)
- [Log Management](#log-management)
- [System Monitoring](#system-monitoring)
- [Troubleshooting](#troubleshooting)
- [Performance Optimization](#performance-optimization)
- [Related Links](#related-links)

## Environment Preparation 🛠️

### System Requirements

- Operating System: Ubuntu 20.04/22.04, CentOS 7/8, Debian 10/11
- CPU: Minimum 2 cores (4+ cores recommended)
- Memory: Minimum 4GB (8GB+ recommended)
- Storage: At least 30GB available space
- Network: Stable internet connection

### Installing Docker and Docker Compose

```bash
# Install necessary system tools
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Set up Docker repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install Docker CE
sudo apt-get update
sudo apt-get install -y docker-ce

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add current user to docker group
sudo usermod -aG docker $USER
```

After installation, log out and log back in to apply group changes, or run:

```bash
newgrp docker
```

Verify installation:

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version
```

## Installation Process 📥

### 1. Clone the Dify Repository

```bash
# Clone a specific version (using version 0.15.3 here)
git clone https://github.com/langgenius/dify.git --branch 0.15.3 dify-project
```

### 2. Enter the Project and Generate Docker Compose Configuration

```bash
cd dify-project/docker
./generate_docker_compose
```

### 3. Configure Environment Variables

Create and edit the `.env` file:

```bash
cp .env.example .env
nano .env  # or use vim, gedit, or another editor
```

Key configuration items:

```properties
# Core service URL configuration
CONSOLE_URL=http://your-server-ip:8080/console
APP_URL=http://your-server-ip:8080

# Database configuration (using built-in PostgreSQL by default)
DB_USERNAME=postgres
DB_PASSWORD=difyai123456  # Recommended to change to a strong password
DB_HOST=db
DB_PORT=5432
DB_DATABASE=dify

# Redis configuration (using built-in Redis by default)
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=difyai123456  # Recommended to change to a strong password

# Vector database configuration (using Weaviate by default)
VECTOR_STORE=weaviate
WEAVIATE_ENDPOINT=http://weaviate:8080
WEAVIATE_API_KEY=WVF5YThaHlkYwhGUSmCRgsX3tD5ngdN8pkih

# Security configuration
SECRET_KEY=your-secret-key  # Must be changed to a random string
```

Generate a secure key:

```bash
# Generate random key
openssl rand -base64 42
```

### 4. Start Services

```bash
# Start all services
docker-compose up -d
```

## Configuration Details ⚙️

### Important Configuration Files

- **docker-compose.yaml**: Main container orchestration configuration
- **.env**: Environment variable configuration
- **nginx/conf.d/default.conf**: Nginx configuration

### Directory Structure

```
dify-project/
├── docker/
│   ├── volumes/         # Persistent data directory
│   │   ├── app/         # Application data
│   │   ├── db/          # Database data
│   │   ├── redis/       # Redis data
│   │   └── weaviate/    # Vector database data
│   ├── nginx/           # Nginx configuration
│   ├── ssrf_proxy/      # SSRF proxy configuration
│   └── .env             # Environment variables
```

### System Users and Permissions

Services in Docker containers typically run as non-root users. Ensure the `volumes` directory has appropriate permissions:

```bash
# Set appropriate permissions
sudo chown -R 1000:1000 docker/volumes/
```

## Starting and Stopping 🔄

### Starting Services

```bash
cd dify-project/docker
docker-compose up -d
```

### Stopping Services

```bash
docker-compose down
```

### Restarting Specific Services

```bash
# Restart API service
docker-compose restart api

# Restart Web service
docker-compose restart web
```

### Service Status Check

```bash
# View status of all containers
docker-compose ps

# View container resource usage
docker stats
```

## Log Management 📋

### Viewing Service Logs

```bash
# View logs of all services
docker-compose logs

# Real-time view of API service logs
docker-compose logs -f api

# View most recent 100 lines of Web service logs
docker-compose logs --tail=100 web
```

### Log Storage Location

Logs are stored within each container, but external log collection systems like ELK Stack or Loki can also be configured.

### Log Rotation

Docker uses the json-file log driver by default. Log rotation can be configured in docker-compose.yaml:

```yaml
services:
  api:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"
```

## System Monitoring 📊

### Resource Monitoring

Use standard Linux monitoring tools:

```bash
# Process and resource monitoring
htop

# Disk usage
df -h

# Directory size
du -sh docker/volumes/*
```

### Docker Container Monitoring

You can use Docker's built-in tools or third-party monitoring solutions:

```bash
# Container resource usage
docker stats

# Install Portainer (Docker visualization management tool)
docker volume create portainer_data
docker run -d -p 9000:9000 --name=portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data portainer/portainer-ce
```

Access `http://your-server-ip:9000` to set up Portainer.

## Troubleshooting 🔍

### Common Issues and Solutions

1. **Database Connection Problems**

   Check if the database container is running and if the connection configuration is correct:

   ```bash
   # Check database container status
   docker-compose ps db
   
   # View database logs
   docker-compose logs db
   ```

2. **API Service Won't Start**

   ```bash
   # Check API logs
   docker-compose logs api
   
   # Check database migration status
   docker-compose exec api flask db-migrate-status
   ```

3. **Nginx Proxy Issues**

   Check Nginx configuration and logs:

   ```bash
   # View Nginx configuration
   docker-compose exec nginx cat /etc/nginx/conf.d/default.conf
   
   # View Nginx logs
   docker-compose logs nginx
   ```

### Health Checks

Add health checks to containers to automatically identify service abnormalities:

```yaml
services:
  api:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5001/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## Performance Optimization ⚡

### System Level Optimization

1. **File System Optimization**

   ```bash
   # Reduce inode cache expiration time
   sudo sysctl -w vm.vfs_cache_pressure=200
   
   # Increase file handle limits
   echo "* soft nofile 1048576" | sudo tee -a /etc/security/limits.conf
   echo "* hard nofile 1048576" | sudo tee -a /etc/security/limits.conf
   ```

2. **Docker Optimization**

   Create or edit `/etc/docker/daemon.json`:

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

   Restart the Docker service:

   ```bash
   sudo systemctl restart docker
   ```

### Application Level Optimization

1. **Database Optimization**

   Edit PostgreSQL parameters in the `.env` file:

   ```properties
   POSTGRES_MAX_CONNECTIONS=200
   POSTGRES_SHARED_BUFFERS=256MB
   POSTGRES_WORK_MEM=8MB
   POSTGRES_MAINTENANCE_WORK_MEM=128MB
   POSTGRES_EFFECTIVE_CACHE_SIZE=8192MB
   ```

2. **API Service Optimization**

   Adjust the number of worker processes for the API service:

   ```properties
   SERVER_WORKER_AMOUNT=4  # Set to the number of CPU cores
   SERVER_WORKER_CLASS=gevent
   SERVER_WORKER_CONNECTIONS=1000
   ```

3. **Vector Database Optimization**

   Configure according to the type of vector database. For example, Weaviate can increase query limits:

   ```properties
   WEAVIATE_QUERY_DEFAULTS_LIMIT=100
   ```

## Related Links 🔗

- [中文版本](../【Linux】Dify部署与管理.md)
- [Dify Official Documentation](https://docs.dify.ai/)
- [Dify GitHub Repository](https://github.com/langgenius/dify)
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/) 