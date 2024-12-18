# Zipkin 快速开始指南

## 目录
- [1. 目录](#目录)
- [2. 安装方式](#安装方式)
    - [Docker 安装（推荐）](#docker-安装推荐)
        - [单容器运行](#单容器运行)
        - [使用 Docker Compose](#使用-docker-compose)
    - [Java 安装](#java-安装)
    - [Homebrew 安装 (macOS)](#homebrew-安装-macos)
    - [从源码运行](#从源码运行)
- [3. 配置说明](#配置说明)
    - [存储配置](#存储配置)
    - [采样率配置](#采样率配置)
    - [端口配置](#端口配置)
- [4. 验证安装](#验证安装)
- [5. 常见问题排查](#常见问题排查)
- [6. 下一步](#下一步)
- [7. 参考资源](#参考资源)



## 安装方式

### Docker 安装（推荐）

使用 [Docker Zipkin](https://github.com/openzipkin/docker-zipkin) 是最简单的方式。你可以使用预构建的镜像或通过 `docker-compose.yml` 启动完整的环境。

#### 单容器运行
```bash
docker run -d -p 9411:9411 openzipkin/zipkin
```

#### 使用 Docker Compose
```yaml
version: '3'
services:
  zipkin:
    image: openzipkin/zipkin
    ports:
      - "9411:9411"
    environment:
      - STORAGE_TYPE=elasticsearch
    networks:
      - zipkin-network

  elasticsearch:
    image: elasticsearch:7.17.9
    ports:
      - "9200:9200"
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    networks:
      - zipkin-network

networks:
  zipkin-network:
```

### Java 安装

要求 Java 17 或更高版本。

```bash
# 下载最新版本
curl -sSL https://zipkin.io/quickstart.sh | bash -s

# 运行服务器
java -jar zipkin.jar
```

配置选项：
```bash
# 使用内存存储
STORAGE_TYPE=mem java -jar zipkin.jar

# 使用 MySQL 存储
STORAGE_TYPE=mysql MYSQL_HOST=localhost java -jar zipkin.jar

# 使用 Elasticsearch 存储
STORAGE_TYPE=elasticsearch ES_HOSTS=http://localhost:9200 java -jar zipkin.jar
```

### Homebrew 安装 (macOS)

使用 [Homebrew](https://brew.sh/) 包管理器安装：

```bash
# 安装
brew install zipkin

# 前台运行
zipkin

# 后台运行
brew services start zipkin

# 停止服务
brew services stop zipkin
```

### 从源码运行

适合开发新功能或自定义 Zipkin：

```bash
# 克隆源码
git clone https://github.com/openzipkin/zipkin
cd zipkin

# 构建服务器及其依赖
./mvnw -T1C -q --batch-mode -DskipTests --also-make -pl zipkin-server clean package

# 运行完整版服务器
java -jar ./zipkin-server/target/zipkin-server-*exec.jar

# 或运行精简版服务器
java -jar ./zipkin-server/target/zipkin-server-*slim.jar
```

## 配置说明

### 存储配置

Zipkin 支持多种存储后端：

- **内存存储**：默认选项，重启后数据丢失
- **MySQL**：持久化存储，适合小规模部署
- **Elasticsearch**：推荐用于生产环境，支持大规模数据和复杂查询
- **Cassandra**：适合超大规模部署

### 采样率配置

```bash
# 设置采样率（0.0-1.0）
SAMPLING_RATE=0.1 java -jar zipkin.jar
```

### 端口配置

```bash
# 修改默认端口（9411）
QUERY_PORT=9412 java -jar zipkin.jar
```

## 验证安装

1. 启动后访问 Web UI：
   ```
   http://localhost:9411/zipkin/
   ```

2. 检查健康状态：
   ```bash
   curl -v http://localhost:9411/health
   ```

3. 查看 API 文档：
   ```
   http://localhost:9411/swagger-ui/
   ```

## 常见问题排查

1. **无法访问 UI**
   - 检查端口是否被占用
   - 确认防火墙设置
   - 验证服务是否正常运行

2. **数据存储问题**
   - 检查存储配置是否正确
   - 验证存储服务是否可访问
   - 查看存储空间是否充足

3. **性能问题**
   - 调整采样率
   - 优化存储配置
   - 检查系统资源使用情况

## 下一步

1. 集成到您的应用：
   - Spring Boot 应用集成
   - 其他框架集成
   - 自定义采样策略

2. 监控和告警：
   - 设置性能基准
   - 配置告警规则
   - 集成监控系统

## 参考资源

- [Zipkin 官方文档](https://zipkin.io/)
- [Zipkin GitHub](https://github.com/openzipkin/zipkin)
- [Zipkin 示例项目](https://github.com/openzipkin/zipkin/tree/master/zipkin-example)