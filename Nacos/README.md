# Nacos 服务部署与使用指南

## 项目简介

Nacos 是阿里巴巴开源的一个更易于构建云原生应用的动态服务发现、配置管理和服务管理平台。本项目提供了在 macOS ARM 架构上快速部署单节点 Nacos 服务的方案，使用内置数据库（Derby）而非 MySQL。

主要功能：

- 服务发现与管理：动态注册和发现服务
- 配置管理：动态配置服务
- 动态 DNS 服务：动态 DNS 服务
- 服务及元数据管理：管理服务的元数据

## 环境要求

- macOS ARM 架构（Apple Silicon）
- Docker Desktop 4.0.0+
- 至少 1GB 可用内存
- 至少 1GB 可用磁盘空间

## 目录结构

```
Nacos/
├── nacos.sh           # 统一管理脚本（启动、停止、状态查询等）
├── conf/              # 配置文件目录（挂载到容器内的/home/nacos/conf）
├── data/              # 数据目录（挂载到容器内的/home/nacos/data）
├── logs/              # 日志目录（挂载到容器内的/home/nacos/logs）
└── README.md          # 项目文档（本文件）
```

## 快速开始

### 1. 设置脚本执行权限

首先赋予管理脚本可执行权限：

```bash
cd Nacos
chmod +x nacos.sh
```

### 2. 启动 Nacos 服务

使用管理脚本启动 Nacos 服务：

```bash
./nacos.sh start
```

服务启动后，可以通过 http://localhost:8848/nacos 访问 Nacos 控制台。
- 默认用户名：nacos
- 默认密码：nacos

### 3. 管理脚本命令详解

Nacos 管理脚本提供了以下命令：

| 命令 | 描述 |
|------|------|
| `start` | 启动 Nacos 服务 |
| `stop` | 停止 Nacos 服务 |
| `restart` | 重启 Nacos 服务 |
| `status` | 查看 Nacos 服务状态 |
| `logs` | 查看 Nacos 服务日志 |

例如，要查看 Nacos 服务状态：

```bash
./nacos.sh status
```

## Nacos 使用指南

### 1. 服务发现

Nacos 可以作为服务注册中心，支持 Spring Cloud、Dubbo 等框架的服务注册与发现。

#### 示例（Spring Cloud）

在 Spring Boot 应用的 `pom.xml` 中添加依赖：

```xml
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
    <version>2021.1</version>
</dependency>
```

在 `application.properties` 中配置 Nacos 服务地址：

```properties
spring.cloud.nacos.discovery.server-addr=127.0.0.1:8848
spring.application.name=your-service-name
```

在启动类上添加 `@EnableDiscoveryClient` 注解：

```java
@SpringBootApplication
@EnableDiscoveryClient
public class YourApplication {
    public static void main(String[] args) {
        SpringApplication.run(YourApplication.class, args);
    }
}
```

### 2. 配置管理

Nacos 可以作为配置中心，实现配置的集中管理和动态更新。

#### 示例（Spring Cloud）

在 `pom.xml` 中添加依赖：

```xml
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
    <version>2021.1</version>
</dependency>
```

创建 `bootstrap.properties` 文件并配置：

```properties
spring.application.name=your-service-name
spring.cloud.nacos.config.server-addr=127.0.0.1:8848
spring.cloud.nacos.config.file-extension=yaml
```

在 Nacos 控制台创建配置：
- Data ID: your-service-name.yaml
- Group: DEFAULT_GROUP
- 配置内容: 你的配置内容（YAML 格式）

在代码中使用 `@Value` 或 `@ConfigurationProperties` 获取配置：

```java
@RestController
@RefreshScope  // 支持配置动态刷新
public class ConfigController {

    @Value("${your.config.property:default-value}")
    private String configProperty;

    @GetMapping("/config")
    public String getConfig() {
        return configProperty;
    }
}
```

## 高级配置

### 1. 修改 Nacos 配置

如果需要修改 Nacos 的配置，可以在 `conf` 目录下添加配置文件，例如 `application.properties`：

```properties
# 开启访问日志
server.tomcat.accesslog.enabled=true

# 修改默认密码 (生产环境建议修改)
nacos.core.auth.plugin.nacos.token.secret.key=SecretKey012345678901234567890123456789012345678901234567890123456789
```

### 2. 资源配置调整

如果需要调整 Nacos 的资源配置，可以修改 `nacos.sh` 脚本中的 JVM 参数：

```bash
-e JVM_XMS=512m \
-e JVM_XMX=512m \
-e JVM_XMN=256m \
```

### 3. 开启认证

默认情况下，本配置的 Nacos 未开启认证。如需开启，修改脚本中的参数：

```bash
-e NACOS_AUTH_ENABLE=true \
```

## 故障排除

### 1. 服务无法启动

检查日志文件（`logs/` 目录下）以获取详细错误信息。常见原因：
- 端口冲突：检查端口 8848、9848 是否被占用
- 内存不足：调整 JVM 参数或增加可用内存
- 权限问题：确保 `data` 和 `logs` 目录有正确的权限

### 2. 无法访问控制台

如果无法访问 Nacos 控制台，请尝试：
- 检查服务状态：运行 `./nacos.sh status`
- 检查日志：运行 `./nacos.sh logs`
- 等待初始化：Nacos 初始化可能需要 10-30 秒
- 检查网络：确保本地网络正常，Docker 网络配置正确

### 3. 性能问题

如果遇到性能问题，可以：
- 增加 JVM 内存分配
- 确保 macOS 有足够的可用资源
- 调整 Docker 资源分配

## 相关资源

- [Nacos 官方文档](https://nacos.io/zh-cn/docs/what-is-nacos.html)
- [Nacos GitHub 仓库](https://github.com/alibaba/nacos)
- [Spring Cloud Alibaba Nacos](https://github.com/alibaba/spring-cloud-alibaba/wiki/Nacos-discovery)
- [Docker Hub: nacos/nacos-server](https://hub.docker.com/r/nacos/nacos-server)

## 注意事项

1. 本配置使用内置的 Derby 数据库，适合开发和测试环境。生产环境建议使用外部 MySQL 数据库。
2. macOS ARM 架构运行 Docker 容器可能性能略低于原生 x86 架构。
3. 默认未开启认证，生产环境建议开启认证并修改默认密码。 