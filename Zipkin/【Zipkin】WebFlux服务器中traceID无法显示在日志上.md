# WebFlux服务器中traceID无法显示在日志上的解决方案

## 目录
- [1. 目录](#目录)
- [2. 问题描述](#问题描述)
- [3. 解决方案](#解决方案)
    - [添加依赖](#添加依赖)
    - [启用自动上下文传播](#启用自动上下文传播)
    - [配置日志格式](#配置日志格式)
    - [配置Sleuth属性](#配置sleuth属性)
- [4. 原理说明](#原理说明)
- [5. 注意事项](#注意事项)
- [6. 性能考虑](#性能考虑)
- [7. 总结](#总结)



## 问题描述

在Spring WebFlux项目中集成了Zipkin进行分布式追踪时，发现日志中无法正常显示traceID。这是因为WebFlux使用响应式编程模型，与传统的ThreadLocal方式存储上下文信息不同。

## 解决方案

### 添加依赖

在`pom.xml`中添加必要的依赖：

```xml
<dependencies>
    <!-- Spring Cloud Sleuth -->
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-sleuth</artifactId>
    </dependency>
    
    <!-- Zipkin -->
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-sleuth-zipkin</artifactId>
    </dependency>
</dependencies>
```

### 启用自动上下文传播

在应用程序的启动类中添加以下代码：

```java
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        // 启用自动上下文传播
        Hooks.enableAutomaticContextPropagation();
        SpringApplication.run(Application.class, args);
    }
}
```

### 配置日志格式

在`application.yml`或`application.properties`中配置日志格式：

```yaml
logging:
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] [%X{traceId:-},%X{spanId:-}] %-5level %logger{36} - %msg%n"
```

### 配置Sleuth属性

在`application.yml`中添加Sleuth相关配置：

```yaml
spring:
  sleuth:
    sampler:
      probability: 1.0  # 采样比率，1.0表示100%采样
  zipkin:
    base-url: http://your-zipkin-server:9411  # Zipkin服务器地址
```

## 原理说明

`Hooks.enableAutomaticContextPropagation()`的作用是：
1. 自动处理响应式调用链中的上下文传播
2. 确保traceID在异步操作中正确传递
3. 无需手动处理Context的传递

## 注意事项

1. 确保在应用启动最开始就调用`Hooks.enableAutomaticContextPropagation()`
2. 该方法应在任何响应式操作之前调用
3. 这是一个全局设置，会影响所有的响应式操作

## 性能考虑

1. 在生产环境中调整采样率：
```yaml
spring:
  sleuth:
    sampler:
      probability: 0.1  # 10%采样率
```

2. 合理配置日志级别：
```yaml
logging:
  level:
    org.springframework.cloud.sleuth: INFO
```

## 总结

1. WebFlux环境中显示traceID的关键是启用自动上下文传播
2. 使用`Hooks.enableAutomaticContextPropagation()`是最简单有效的解决方案
3. 无需手动处理Context传递
4. 配合合适的日志格式和采样率，可以有效进行分布式追踪