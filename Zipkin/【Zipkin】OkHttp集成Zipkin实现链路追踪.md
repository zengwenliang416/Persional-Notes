# 【Zipkin】OkHttp集成Zipkin实现链路追踪

## 目录
- [1. 目录](#目录)
- [2. 概述](#概述)
    - [背景介绍](#背景介绍)
    - [问题描述](#问题描述)
    - [解决方案概览](#解决方案概览)
- [3. 环境准备](#环境准备)
    - [依赖配置](#依赖配置)
    - [配置文件](#配置文件)
- [4. 实现步骤](#实现步骤)
    - [定义追踪拦截器](#定义追踪拦截器)
    - [注册拦截器](#注册拦截器)
- [5. 验证与测试](#验证与测试)
    - [测试步骤](#测试步骤)
    - [验证要点](#验证要点)
    - [常见问题及解决方案](#常见问题及解决方案)
- [6. 最佳实践](#最佳实践)
    - [性能优化](#性能优化)
    - [安全考虑](#安全考虑)
    - [监控与告警](#监控与告警)
    - [开发建议](#开发建议)
- [7. 参考资料](#参考资料)



## 概述

### 背景介绍

在微服务架构中，服务间调用链的复杂性使得问题定位变得困难。Zipkin作为分布式追踪系统，能够帮助我们追踪和分析服务调用链路，快速定位问题。

### 问题描述
在使用Zuul作为API网关时，如果从Apache HttpClient切换到OkHttp，可能会遇到以下问题：
- 链路追踪信息（traceid、spanid、parentspanid）无法正确传递
- 下游服务会生成新的traceid，导致调用链断裂
- 无法从网关开始追踪完整的服务调用链路

### 解决方案概览
通过自定义OkHttp Interceptor，我们可以：
1. 在请求头中注入追踪信息
2. 确保链路追踪的连续性
3. 实现从网关到最终服务的完整链路追踪

## 环境准备

### 依赖配置

```xml
<dependencies>
    <!-- Spring Cloud Starter Zipkin -->
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-zipkin</artifactId>
    </dependency>
    
    <!-- OkHttp -->
    <dependency>
        <groupId>com.squareup.okhttp3</groupId>
        <artifactId>okhttp</artifactId>
        <version>4.9.3</version>  <!-- 推荐使用稳定版本 -->
    </dependency>

    <!-- Brave OkHttp -->
    <dependency>
        <groupId>io.zipkin.brave</groupId>
        <artifactId>brave-instrumentation-okhttp3</artifactId>
        <version>5.13.9</version>  <!-- 使用与Spring Cloud版本兼容的版本 -->
    </dependency>
</dependencies>
```

### 配置文件
```yaml
spring:
  application:
    name: your-service-name
  zipkin:
    base-url: http://your-zipkin-server:9411
    sender:
      type: web
  sleuth:
    sampler:
      probability: 1.0  # 开发环境可设置为1.0，生产环境建议0.1
    web:
      client:
        enabled: true
    async:
      enabled: true    # 启用异步跟踪

# OkHttp配置
ribbon:
  http:
    client:
      enabled: false
  okhttp:
    enabled: true
  ConnectTimeout: 3000
  ReadTimeout: 5000
```

## 实现步骤

### 定义追踪拦截器
创建 `TracingInterceptor.java`：
```java
@Component
public class TracingInterceptor implements Interceptor {
    private static final Logger LOGGER = LoggerFactory.getLogger(TracingInterceptor.class);
    
    // B3 追踪头
    private static final String TRACE_ID_NAME = "X-B3-TraceId";
    private static final String SPAN_ID_NAME = "X-B3-SpanId";
    private static final String PARENT_SPAN_ID_NAME = "X-B3-ParentSpanId";
    private static final String SAMPLED_NAME = "X-B3-Sampled";
    private static final String FLAGS_NAME = "X-B3-Flags";
    private static final String SPAN_NAME = "X-Span-Name";

    @Autowired
    private Tracer tracer;

    @Override
    public Response intercept(Chain chain) throws IOException {
        Request request = chain.request();
        Span span = tracer.currentSpan();
        
        if (span == null) {
            return chain.proceed(request);
        }

        TraceContext traceContext = span.context();
        String spanName = request.method() + " " + request.url().encodedPath();

        // 构建追踪头
        Headers.Builder headersBuilder = request.headers().newBuilder()
            .add(TRACE_ID_NAME, traceContext.traceIdString())
            .add(SPAN_ID_NAME, HexCodec.toLowerHex(generateNextId()))
            .add(PARENT_SPAN_ID_NAME, getParentId(traceContext))
            .add(SAMPLED_NAME, "1")
            .add(SPAN_NAME, spanName);

        if (traceContext.debug()) {
            headersBuilder.add(FLAGS_NAME, "1");
        }

        // 创建新请求
        Request tracedRequest = request.newBuilder()
            .headers(headersBuilder.build())
            .build();

        // 记录请求信息
        LOGGER.debug("Sending request: method={}, url={}, traceId={}", 
            request.method(), request.url(), traceContext.traceIdString());

        // 执行请求并记录响应
        Response response = null;
        try {
            response = chain.proceed(tracedRequest);
            LOGGER.debug("Received response: code={}, traceId={}", 
                response.code(), traceContext.traceIdString());
            return response;
        } catch (Exception e) {
            LOGGER.error("Request failed: traceId={}, error={}", 
                traceContext.traceIdString(), e.getMessage());
            throw e;
        }
    }

    private String getParentId(TraceContext context) {
        return context.parentIdString() != null ? 
               context.parentIdString() : 
               HexCodec.toLowerHex(context.spanId());
    }

    private long generateNextId() {
        long nextId;
        do {
            nextId = Platform.get().randomLong();
        } while (nextId == 0L);
        return nextId;
    }
}
```

### 注册拦截器
创建 `HttpClientConfiguration.java`：
```java
@Configuration
public class HttpClientConfiguration {
    
    @Bean
    public TracingInterceptor tracingInterceptor() {
        return new TracingInterceptor();
    }

    @Bean
    @ConditionalOnMissingBean(OkHttpClient.class)
    public OkHttpClient okHttpClient(TracingInterceptor tracingInterceptor) {
        return new OkHttpClient.Builder()
            .addInterceptor(tracingInterceptor)
            .addInterceptor(new HttpLoggingInterceptor()  // 添加日志拦截器
                .setLevel(HttpLoggingInterceptor.Level.BASIC))
            .connectTimeout(2, TimeUnit.SECONDS)
            .readTimeout(3, TimeUnit.SECONDS)
            .writeTimeout(3, TimeUnit.SECONDS)
            .retryOnConnectionFailure(true)
            .connectionPool(new ConnectionPool(20, 10L, TimeUnit.MINUTES))  // 增加连接池保持时间
            .build();
    }

    @Bean
    public HttpLoggingInterceptor loggingInterceptor() {
        return new HttpLoggingInterceptor()
            .setLevel(HttpLoggingInterceptor.Level.BASIC);
    }
}
```

## 验证与测试

### 测试步骤
1. 启动Zipkin服务器
   ```bash
   docker run -d -p 9411:9411 openzipkin/zipkin
   ```

2. 启动包含OkHttp配置的服务
   ```bash
   ./mvnw spring-boot:run
   ```

3. 通过网关发送测试请求
   ```bash
   curl -v http://your-gateway-url/api/test
   ```

4. 在Zipkin UI中查看追踪结果
   - 访问 http://localhost:9411
   - 使用服务名和TraceID进行查询

### 验证要点
- 检查traceid是否在整个调用链中保持一致
- 确认spanid的父子关系是否正确
- 验证服务调用的时序是否符合预期
- 检查请求和响应的时间戳是否准确
- 确认所有相关的元数据（如HTTP方法、URL）是否正确记录

### 常见问题及解决方案
1. **追踪信息丢失**
   - 检查拦截器是否正确注册
   - 确认追踪头的名称是否正确
   - 验证Sleuth配置是否生效
   ```yaml
   logging.level.org.springframework.cloud.sleuth: DEBUG
   ```
   
2. **新traceid生成**
   - 验证parentId的传递是否正确
   - 检查Sleuth配置是否正确
   - 确保所有服务使用相同版本的Sleuth

3. **链路不完整**
   - 确保所有服务都配置了Zipkin
   - 检查采样率配置
   - 验证网络连接是否正常
   ```bash
   curl -v http://your-zipkin-server:9411/api/v2/services
   ```

4. **性能问题**
   - 检查连接池配置
   - 监控请求延迟
   - 分析Zipkin UI中的时间分布

## 最佳实践

### 性能优化
- 合理配置连接池参数
  ```java
  new ConnectionPool(
      20,  // 最大空闲连接数
      10L, // 保持时间
      TimeUnit.MINUTES
  )
  ```
- 设置适当的超时时间
  ```java
  .connectTimeout(2, TimeUnit.SECONDS)
  .readTimeout(3, TimeUnit.SECONDS)
  .writeTimeout(3, TimeUnit.SECONDS)
  ```
- 启用请求重试
  ```java
  .retryOnConnectionFailure(true)
  ```

### 安全考虑

- 在生产环境中使用合适的采样率（建议0.1-0.3）
- 配置敏感信息过滤
  ```java
  @Bean
  public SleuthSkipPatternProvider skipPatternProvider() {
      return () -> Pattern.compile("/api/health|/api/metrics");
  }
  ```
- 实现追踪信息加密
- 控制日志级别，避免敏感信息泄露

### 监控与告警
- 配置Zipkin指标监控
- 设置关键指标告警阈值
- 定期检查追踪数据质量

### 开发建议
- 使用有意义的span名称
- 添加自定义标签记录业务信息
- 保持追踪粒度的合理性
- 定期更新依赖版本

## 参考资料

- [Zipkin官方文档](https://zipkin.io/)
- [Spring Cloud Sleuth文档](https://docs.spring.io/spring-cloud-sleuth/docs/current/reference/html/)
- [OkHttp官方文档](https://square.github.io/okhttp/)
- [Brave文档](https://github.com/openzipkin/brave)
