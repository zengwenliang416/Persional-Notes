# 【Ruoyi-Plus】项目学习

## 新建模块



## yml文件配置

Spring boot一定加载application.yml以及激活的application-xxx.yml等形式的文件，Spring boot首先会加载application.yml，然后再加载我们激活的application-xxx.yml，如果两个同时激活，后加载的会覆盖掉前面加载的

如果不符合这种命名规范的话就不会被自动加载，此时可以在类上加上注解加载该配置文件：

```
@PropertySource(value = {"classpath:generator.yml"}, encoding = "UTF-8")
```

### security配置

```
security:
  # 排除路径
  excludes:
    # 静态资源
    - /*.html
    - /**/*.html
    - /**/*.css
    - /**/*.js
    # 公共路径
    - /favicon.ico
    - /error
    # swagger 文档配置
    - /*/api-docs
    - /*/api-docs/**
    # actuator 监控配置
    - /actuator
    - /actuator/**
```

对应代码：

```
package com.ruoyi.framework.config.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Security 配置属性
 * @Data
 * @author Lion Li
 */
@Data
@Component
@ConfigurationProperties(prefix = "security")
public class SecurityProperties {

    /**
     * 排除路径
     */
    private String[] excludes;

} 
```

在配置文件中，排除路径是一个数组，数组的配置的话会在前面加一个-和一个空格

连字符-可以实现驼峰转换，比如：

```
jwt-secret-key: abcdefghijklmnopqrstuvwxyz
```

在代码中是这样的：

```
private String jwtSecretKey;
```

三个连字符---可以将一个文档分成多个文档以实现配置文件的隔离



指定运行的配置文件

```
java -jar xxx.jar --spring.config.name=application-xxx
或者
java -jar xxx.jar --spring.profiles.active=xxx
```

## Jackson配置

### 前置知识

客户端向服务端发送请求数据主要包含三个部分：URL、Body（一般的GET方法没有）和Header。



后端如何接受前端发送过来的参数？后端处理之后返回给前端，前端又怎么去接收这些数据？前端向后端发送请求的过程中，参数可以放在哪个部分？ 



#### 参数位置

url、body

因此，后端的接受方式总共有三种：路径变量传参、拼接后注解传参和body传参



这种body传递参数和查看后端响应就是Jackson的反序列化和序列化，接口接收到接口字符串并转为body对象的这个过程就是反序列化，而经过处理之后再返回数据的过程就是序列化



#### 序列化

将数据结构或者对象转换为可以被存储或传输的一系列字节的过程

#### jackson配置

```yml
# jackson相关配置
jackson: 
  # 日期格式化
  date-format: yyyy-MM-dd HH:mm:ss
  serialization:
    # 格式化输出
    indent_output: false
    # 忽略无法转换的对象
    fail_on_empty_beans: false
  deserialization:
    # 允许对象忽略json中不存在的属性
    fail_on_unknown_properties: false
```

#### 代码配置

```java
@Slf4j
@Configuration
public class JacksonConfig {

    @Bean
    public Jackson2ObjectMapperBuilderCustomizer customizer() {
        // builder 是一个Lambda表达式的参数，它代表的是 Jackson2ObjectMapperBuilder 类型的对象。
        // 在这个Lambda表达式中，builder 是一个自动传入的参数，
        // 当Spring框架执行这个 customizer 方法并调用
        // Jackson2ObjectMapperBuilderCustomizer 接口的 customize 方法时，
        // Spring会向这个方法提供一个已经存在的 Jackson2ObjectMapperBuilder 实例。
        // 通过这个 builder 实例，你可以调用各种方法来设置 ObjectMapper 的行为，
        // 比如在这段代码中，它设置了日期时间模块(JavaTimeModule)的特定序列化和反序列化器，并设置了时区(timeZone)。
        //  这些自定义设置最终会影响到Spring Boot应用中的JSON序列化/反序列化行为。
        // options + enter能将lambda变为类
        return builder -> {
            // 全局配置序列化返回 JSON 处理
            JavaTimeModule javaTimeModule = new JavaTimeModule();// Jackson的一个模块，用于处理Java 8日期和时间API。
            // BigNumberSerializer: 是一个自定义的序列化器，用于处理大数字值，避免在前端JS中失去精度。
            javaTimeModule.addSerializer(Long.class, BigNumberSerializer.INSTANCE);
            javaTimeModule.addSerializer(Long.TYPE, BigNumberSerializer.INSTANCE);
            javaTimeModule.addSerializer(BigInteger.class, BigNumberSerializer.INSTANCE);
            // ToStringSerializer: 是Jackson提供的标准序列化器，将数值转换为其字符串形式。
            javaTimeModule.addSerializer(BigDecimal.class, ToStringSerializer.instance);
            // 对LocalDateTime对象自定义了序列化和反序列化的格式，使用一个指定的日期时间格式"yyyy-MM-dd HH:mm:ss"。
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            javaTimeModule.addSerializer(LocalDateTime.class, new LocalDateTimeSerializer(formatter));
            javaTimeModule.addDeserializer(LocalDateTime.class, new LocalDateTimeDeserializer(formatter));
            builder.modules(javaTimeModule);
            // 设置了Jackson的默认时区为系统默认时区
            builder.timeZone(TimeZone.getDefault());
            log.info("初始化 jackson 配置");
        };
    }

}
```

通过实现Jackson2ObjectMapperBuilderCustomizer的customize就可以从代码去配置Jackson

```java
@FunctionalInterface
public interface Jackson2ObjectMapperBuilderCustomizer {

	/**
	 * Jacason构建定制器，通过实现customize方法就可以实现Jackson配置
	 * @param jacksonObjectMapperBuilder the JacksonObjectMapperBuilder to customize
	 */
	void customize(Jackson2ObjectMapperBuilder jacksonObjectMapperBuilder);

}
```

进入这个方法，就跳到了JacksonAutoConfiguration，这个类负责Jackson的自动装配，其中有一个内部类。

```java
	@Configuration(proxyBeanMethods = false)
	@ConditionalOnClass(Jackson2ObjectMapperBuilder.class)
	static class JacksonObjectMapperBuilderConfiguration {
    /**
    * 该方法通过返回一个builder注册为bean，这个过程中通过new一个Jackson2ObjectMapperBuilder将其实例化
    * 然后使用customize将容器里面的customizers和builder作为参数传入customize方法
    **/
		@Bean
		@Scope("prototype")
		@ConditionalOnMissingBean
		Jackson2ObjectMapperBuilder jacksonObjectMapperBuilder(ApplicationContext applicationContext,
				List<Jackson2ObjectMapperBuilderCustomizer> customizers) {
			Jackson2ObjectMapperBuilder builder = new Jackson2ObjectMapperBuilder();
			builder.applicationContext(applicationContext);
			customize(builder, customizers);
			return builder;
		}
		/**
		* 这个customize就实现了自定义配置
		**/
		private void customize(Jackson2ObjectMapperBuilder builder,
				List<Jackson2ObjectMapperBuilderCustomizer> customizers) {
			for (Jackson2ObjectMapperBuilderCustomizer customizer : customizers) {
				customizer.customize(builder);
			}
		}

	}
```

#### jackson注解

@JsonIgnore：序列化和反序列化过程中忽略该属性

@JsonInclude：当属性符合某个条件时才进行序列化和反序列化

@JsonSerialize(using = TranslationHandler.class)：指定对应序列化类来执行序列化

@JsonProperty：增加别名

@JsonFormat(pattern = "yyyy-MM-dd")：时间格式化

#### JsonUtils

