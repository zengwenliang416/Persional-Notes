# 【Zipkin】OkHttp集成Zipkin实现链路追踪

## 1. 概述

### 1.1 背景介绍
在微服务架构中，服务间调用链的复杂性使得问题定位变得困难。Zipkin作为分布式追踪系统，能够帮助我们追踪和分析服务调用链路，快速定位问题。

### 1.2 问题描述
在使用Zuul作为API网关时，如果从Apache HttpClient切换到OkHttp，可能会遇到以下问题：
- 链路追踪信息（traceid、spanid、parentspanid）无法正确传递
- 下游服务会生成新的traceid，导致调用链断裂
- 无法从网关开始追踪完整的服务调用链路

### 1.3 解决方案概览
通过自定义OkHttp Interceptor，我们可以：
1. 在请求头中注入追踪信息
2. 确保链路追踪的连续性
3. 实现从网关到最终服务的完整链路追踪

## 2. 环境准备

### 2.1 依赖配置
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
        <version>4.x.x</version>
    </dependency>
</dependencies>
```

### 2.2 配置文件
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
      probability: 1.0

ribbon:
  http:
    client:
      enabled: false
  okhttp:
    enabled: true
```

## 3. 实现步骤

### 3.1 定义追踪拦截器
创建 `TracingInterceptor.java`：
```java
public class TracingInterceptor implements Interceptor {
    private static final Logger LOGGER = LoggerFactory.getLogger(TracingInterceptor.class);
    
    // B3 追踪头
    private static final String TRACE_ID_NAME = "X-B3-TraceId";
    private static final String SPAN_ID_NAME = "X-B3-SpanId";
    private static final String PARENT_SPAN_ID_NAME = "X-B3-ParentSpanId";
    private static final String SAMPLED_NAME = "X-B3-Sampled";

    @Autowired
    private Tracer tracer;

    @Override
    public Response intercept(Chain chain) throws IOException {
        Request request = chain.request();
        TraceContext traceContext = tracer.currentSpan().context();

        // 构建追踪头
        Headers.Builder headersBuilder = request.headers().newBuilder()
            .add(TRACE_ID_NAME, traceContext.traceIdString())
            .add(SPAN_ID_NAME, HexCodec.toLowerHex(generateNextId()))
            .add(PARENT_SPAN_ID_NAME, getParentId(traceContext))
            .add(SAMPLED_NAME, "1");

        // 创建新请求
        Request tracedRequest = request.newBuilder()
            .headers(headersBuilder.build())
            .build();

        // 执行请求
        return chain.proceed(tracedRequest);
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

### 3.2 注册拦截器
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
            .connectTimeout(2, TimeUnit.SECONDS)
            .readTimeout(3, TimeUnit.SECONDS)
            .writeTimeout(3, TimeUnit.SECONDS)
            .retryOnConnectionFailure(true)
            .connectionPool(new ConnectionPool(20, 10L, TimeUnit.SECONDS))
            .build();
    }
}
```

## 4. 验证与测试

### 4.1 测试步骤
1. 启动Zipkin服务器
2. 启动包含OkHttp配置的服务
3. 通过网关发送测试请求
4. 在Zipkin UI中查看追踪结果

### 4.2 验证要点
- 检查traceid是否在整个调用链中保持一致
- 确认spanid的父子关系是否正确
- 验证服务调用的时序是否符合预期

### 4.3 常见问题
1. **追踪信息丢失**
   - 检查拦截器是否正确注册
   - 确认追踪头的名称是否正确
   
2. **新traceid生成**
   - 验证parentId的传递是否正确
   - 检查Sleuth配置是否正确

3. **链路不完整**
   - 确保所有服务都配置了Zipkin
   - 检查采样率配置

## 5. 最佳实践

1. **性能优化**
   - 合理配置连接池参数
   - 适当调整超时时间
   - 根据实际需求调整采样率

2. **安全考虑**
   - 在生产环境中谨慎配置采样率
   - 注意敏感信息的过滤
   - 考虑添加追踪信息的加密机制

3. **监控建议**
   - 定期检查追踪数据的完整性
   - 设置适当的告警阈值
   - 关注异常链路的分析

## 6. 参考资料
- [Zipkin官方文档](https://zipkin.io/)
- [Spring Cloud Sleuth文档](https://spring.io/projects/spring-cloud-sleuth)
- [OkHttp官方文档](https://square.github.io/okhttp/)
