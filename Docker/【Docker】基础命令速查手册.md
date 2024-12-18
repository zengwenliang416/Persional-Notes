# 【Docker】基础命令速查手册

## 目录
- [1. 目录](#目录)
- [2. 一、镜像（Image）管理命令](#一镜像image管理命令)
    - [基本操作](#基本操作)
    - [高级操作](#高级操作)
- [3. 二、容器（Container）管理命令](#二容器container管理命令)
    - [生命周期管理](#生命周期管理)
    - [容器运行参数](#容器运行参数)
    - [容器管理操作](#容器管理操作)
- [4. 三、网络（Network）管理命令](#三网络network管理命令)
    - [基本操作](#基本操作)
    - [网络类型](#网络类型)
- [5. 四、数据卷（Volume）管理命令](#四数据卷volume管理命令)
    - [基本操作](#基本操作)
    - [数据卷使用](#数据卷使用)
- [6. 五、Docker Compose 命令](#五docker-compose-命令)
    - [基本操作](#基本操作)
    - [服务管理](#服务管理)
- [7. 六、系统和信息命令](#六系统和信息命令)
    - [系统操作](#系统操作)
    - [监控和统计](#监控和统计)
- [8. 七、实用技巧](#七实用技巧)



## 一、镜像（Image）管理命令

### 基本操作

| 命令 | 说明 | 示例 |
|------|------|------|
| `docker pull <image>` | 拉取镜像 | `docker pull nginx:latest` |
| `docker images` | 列出本地镜像 | `docker images` |
| `docker rmi <image>` | 删除镜像 | `docker rmi nginx` |
| `docker build` | 构建镜像 | `docker build -t myapp:1.0 .` |
| `docker tag` | 标记镜像 | `docker tag nginx mynginx:v1` |
| `docker save` | 导出镜像 | `docker save -o nginx.tar nginx` |
| `docker load` | 导入镜像 | `docker load -i nginx.tar` |

### 高级操作

```bash
# 查看镜像详细信息
docker inspect <image>

# 查看镜像历史
docker history <image>

# 清理未使用的镜像
docker image prune
```

## 二、容器（Container）管理命令

### 生命周期管理

| 命令 | 说明 | 示例 |
|------|------|------|
| `docker run` | 创建并启动容器 | `docker run -d nginx` |
| `docker start` | 启动已停止的容器 | `docker start <container>` |
| `docker stop` | 停止运行的容器 | `docker stop <container>` |
| `docker restart` | 重启容器 | `docker restart <container>` |
| `docker rm` | 删除容器 | `docker rm <container>` |

### 容器运行参数

```bash
# 后台运行
docker run -d <image>

# 指定名称
docker run --name myapp <image>

# 端口映射
docker run -p 8080:80 <image>

# 挂载数据卷
docker run -v /host/path:/container/path <image>

# 环境变量
docker run -e "KEY=value" <image>

# 资源限制
docker run --memory="512m" --cpus="2" <image>
```

### 容器管理操作

```bash
# 查看容器日志
docker logs -f <container>

# 进入容器
docker exec -it <container> bash

# 从容器复制文件到主机
docker cp <container>:/path/file /host/path

# 查看容器资源使用
docker stats <container>
```

## 三、网络（Network）管理命令

### 基本操作

| 命令 | 说明 | 示例 |
|------|------|------|
| `docker network ls` | 列出网络 | `docker network ls` |
| `docker network create` | 创建网络 | `docker network create mynet` |
| `docker network rm` | 删除网络 | `docker network rm mynet` |
| `docker network connect` | 连接容器到网络 | `docker network connect mynet container1` |
| `docker network disconnect` | 断开网络连接 | `docker network disconnect mynet container1` |

### 网络类型

1. **bridge**: 默认网络驱动程序
2. **host**: 容器使用主机网络
3. **none**: 禁用所有网络
4. **overlay**: Swarm 服务网络
5. **macvlan**: 允许分配 MAC 地址

## 四、数据卷（Volume）管理命令

### 基本操作

| 命令 | 说明 | 示例 |
|------|------|------|
| `docker volume ls` | 列出数据卷 | `docker volume ls` |
| `docker volume create` | 创建数据卷 | `docker volume create mydata` |
| `docker volume rm` | 删除数据卷 | `docker volume rm mydata` |
| `docker volume inspect` | 查看数据卷详情 | `docker volume inspect mydata` |

### 数据卷使用

```bash
# 创建具名数据卷
docker volume create mydata

# 使用数据卷
docker run -v mydata:/data nginx

# 使用只读数据卷
docker run -v mydata:/data:ro nginx

# 使用临时数据卷
docker run -v /data nginx
```

## 五、Docker Compose 命令

### 基本操作

| 命令 | 说明 | 示例 |
|------|------|------|
| `docker-compose up` | 创建并启动服务 | `docker-compose up -d` |
| `docker-compose down` | 停止并删除服务 | `docker-compose down` |
| `docker-compose ps` | 列出服务状态 | `docker-compose ps` |
| `docker-compose logs` | 查看服务日志 | `docker-compose logs -f` |

### 服务管理

```bash
# 构建服务
docker-compose build

# 启动指定服务
docker-compose up -d web

# 查看服务日志
docker-compose logs -f web

# 进入服务容器
docker-compose exec web bash
```

## 六、系统和信息命令

### 系统操作

| 命令 | 说明 | 示例 |
|------|------|------|
| `docker info` | 显示系统信息 | `docker info` |
| `docker version` | 显示版本信息 | `docker version` |
| `docker system df` | 显示磁盘使用 | `docker system df` |
| `docker system prune` | 清理系统 | `docker system prune -a` |

### 监控和统计

```bash
# 查看容器资源使用
docker stats

# 查看事件流
docker events

# 查看端口映射
docker port <container>
```

## 七、实用技巧

1. **批量操作**：
```bash
# 停止所有容器
docker stop $(docker ps -a -q)

# 删除所有容器
docker rm $(docker ps -a -q)

# 删除所有镜像
docker rmi $(docker images -q)
```

2. **日志管理**：
```bash
# 限制日志大小
docker run --log-opt max-size=10m --log-opt max-file=3 nginx

# 使用不同日志驱动
docker run --log-driver=syslog nginx
```

3. **调试技巧**：
```bash
# 查看容器变化
docker diff <container>

# 查看端口映射
docker port <container>

# 查看容器进程
docker top <container>
