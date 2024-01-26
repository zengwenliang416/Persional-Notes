# 【Ruoyi-Plus】项目学习-Jackson

## 前置知识

### 客户端向服务端发送请求数据主要包含哪些部分？

- 三个部分：`URL`、`Body`（一般的`GET`方法没有）和`Header`。

### 后端如何接受前端发送过来的参数？

#### Spring Boot 和Spring MVC

- **@RequestParam**: 用于获取`URL`查询参数或表单数据。

```java
@GetMapping("/search")
public ResponseEntity<String> search(@RequestParam String query) {
    // 业务逻辑处理
    return ResponseEntity.ok("Results for " + query);
}
```

- **@PathVariable**: 用于获取`URL`中的路径变量。

```java
@GetMapping("/users/{id}")
public ResponseEntity<String> getUser(@PathVariable Long id) {
    // 业务逻辑处理
    return ResponseEntity.ok("User with ID: " + id);
}
```

- **@RequestBody**: 用于获取请求体中的数据，通常是`JSON`或`XML`格式。

```java
@PostMapping("/users")
public ResponseEntity<User> createUser(@RequestBody User user) {
    // 业务逻辑处理，如保存用户
    return ResponseEntity.status(HttpStatus.CREATED).body(user);
}
```

- **@RequestHeader**: 用于获取请求头中的特定字段。

```java
@GetMapping("/header-info")
public ResponseEntity<String> getHeaderInfo(@RequestHeader("User-Agent") String userAgent) {
    // 业务逻辑处理
    return ResponseEntity.ok("User-Agent: " + userAgent);
}
```

#### **Java Servlet API**

- **HttpServletRequest.getParameter**: 用于获取查询参数或表单数据。

```java
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String query = request.getParameter("query");
    // 业务逻辑处理
    response.getWriter().write("Results for " + query);
}
```

- **获取路径参数**: 在原生Servlet中没有直接的注解来获取，通常需要解析请求的URL。

```java
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String pathInfo = request.getPathInfo();
    String id = pathInfo.substring(1); // 假设路径是 "/users/{id}"
    // 业务逻辑处理
    response.getWriter().write("User with ID: " + id);
}
```

- **HttpServletRequest.getReader** 或 **getInputStream**: 用于从请求体中读取数据。

```java
protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    StringBuilder sb = new StringBuilder();
    String line;
    BufferedReader reader = request.getReader();
    while ((line = reader.readLine()) != null) {
        sb.append(line);
    }
    String requestBody = sb.toString();
    // 解析requestBody中的数据
    // 业务逻辑处理
    response.getWriter().write("Data received: " + requestBody);
}
```

- **HttpServletRequest.getHeader**: 用于获取请求头信息。

```java
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String userAgent = request.getHeader("User-Agent");
    // 业务逻辑处理
    response.getWriter().write("User-Agent: " + userAgent);
}
```

### 后端处理之后返回给前端，前端又怎么去接收这些数据？

前端接收后端返回的数据通常涉及到发送HTTP请求并处理响应。这个过程可以通过原生`JavaScript`，框架或者库实现，例如用 `XMLHttpRequest`、`Fetch API`、`Axios`、`jQuery`等。以下是这些方法的一些例子：

#### JavaScript

`Fetch API`是现代浏览器提供的原生`JavaScript API`，用于执行网络请求。以下是一个基本的例子：

```javascript
fetch('http://example.com/api/data') // 发送GET请求
  .then(response => {
    if (!response.ok) {
      throw new Error('Network response was not ok ' + response.statusText);
    }
    return response.json(); // 解析JSON格式的响应体
  })
  .then(data => {
    console.log(data); // 处理获取到的数据
  })
  .catch(error => {
    console.error('There has been a problem with your fetch operation:', error);
  });
```

#### Axios

`Axios`是一个流行的基于`Promise`的`HTTP`客户端，它可以在浏览器和`node.js`中使用。以下是一个使用`Axios`的例子：

```javascript
axios.get('http://example.com/api/data')
  .then(response => {
    console.log(response.data); // 处理获取到的数据
  })
  .catch(error => {
    console.error('There was an error!', error);
  });
```

#### jQuery

```javascript
$.ajax({
  url: 'http://example.com/api/data',
  type: 'GET',
  success: function(data) {
    console.log(data); // 处理获取到的数据
  },
  error: function(error) {
    console.error('There was an error!', error);
  }
});
```

#### 前端处理HTTP响应:

不论使用什么方法，处理HTTP响应通常包含以下步骤：

1. **接收响应**: 检查响应状态码来判断请求是否成功。

2. **解析响应体**: 根据响应头的`Content-Type`，可能需要将响应体从`JSON`、`XML`或其他格式转换为`JavaScript`可以处理的对象。

3. **错误处理**: 适当地处理网络错误或后端返回的错误信息。

4. **更新UI**: 使用获取到的数据更新前端的用户界面。

##### 注意事项:

- **同源策略**: 浏览器的同源策略限制了跨域请求，除非后端服务器明确允许（通过`CORS`头部）。

- **安全性**: 应当对从后端获取的数据进行适当的安全处理，以避免例如`XSS`攻击等安全漏洞。

### 前端向后端发送请求的过程中，参数可以放在哪个部分？ 

前端向后端发送请求时，参数可以放在以下几个不同的部分：

1. **URL路径**:
   - 作为路径的一部分，常用于`RESTful API`中。例如，`GET /users/123` 中的 `123` 是一个用户`ID`。
2. **查询字符串**:
   - 放在`URL`的`?`后面，用于`GET`请求的查询参数。例如，`GET /search?query=keyword&page=2`。
3. **请求体** (`Body`):
   - 用于`POST`、`PUT`、`PATCH`等请求，可以包含如`JSON`、`XML`、二进制数据等格式的内容。例如，`POST /users` 请求的body中可能包含一个新用户的`JSON`数据。
4. **请求头** (`Headers`):
   - 包含诸如认证令牌（`Authorization`）、内容类型（`Content-Type`）、接受的回复格式（`Accept`）等元数据。
5. **Cookie**:
   - 通常用于维护会话状态，`Cookie`数据会自动随请求发送。
6. **表单数据**:
   - 当提交一个表单时，可以使用`application/x-www-form-urlencoded`或`multipart/form-data`编码，尤其是在上传文件时。

这种`body`传递参数和查看后端响应就是`Jackson`的反序列化和序列化，接口接收到接口字符串并转为`body`对象的这个过程就是反序列化，而经过处理之后再返回数据的过程就是序列化

## 序列化

将数据结构或者对象转换为可以被存储或传输的一系列字节的过程

## jackson配置

### yaml文件配置

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

### 代码配置

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

通过实现`Jackson2ObjectMapperBuilderCustomizer`的`customize`就可以从代码去配置`Jackson`

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

进入这个方法，就跳到了`JacksonAutoConfiguration`，这个类负责`Jackson`的自动装配，其中有一个内部类。

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

jackson注解

`@JsonIgnore`：序列化和反序列化过程中忽略该属性

`@JsonInclude`：当属性符合某个条件时才进行序列化和反序列化

`@JsonSerialize(using = TranslationHandler.class)`：指定对应序列化类来执行序列化

`@JsonProperty`：增加别名

`@JsonFormat(pattern = "yyyy-MM-dd")`：时间格式化

### JsonUtils

```java
package com.ruoyi.common.utils;

import cn.hutool.core.lang.Dict;
import cn.hutool.core.util.ArrayUtil;
import cn.hutool.core.util.ObjectUtil;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.exc.MismatchedInputException;
import com.ruoyi.common.core.domain.R;
import com.ruoyi.common.utils.spring.SpringUtils;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * JSON 工具类
 *
 * @author 芋道源码
 */
@NoArgsConstructor(access = AccessLevel.PRIVATE) // 生成一个私有的无参构造函数，这样可以保证这个类无法被实例化，只能静态调用类中的属性和方法
public class JsonUtils {
    /**
     * OBJECT_MAPPER在容器初始化时就已经被创建了，这里只是从容器里面拿到它的实例对象
     */
    private static final ObjectMapper OBJECT_MAPPER = SpringUtils.getBean(ObjectMapper.class);

    public static ObjectMapper getObjectMapper() {
        return OBJECT_MAPPER;
    }

    /**
     * 将对象转换为JSON字符串
     *
     * @param object 对象
     * @return JSON字符串
     */
    public static String toJsonString(Object object) {
        if (ObjectUtil.isNull(object)) {
            return null;
        }
        try {
            return OBJECT_MAPPER.writeValueAsString(object);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * 将JSON字符串转换为对象
     *
     * @param text   JSON字符串
     * @param clazz  对象类型
     * @param <T>    对象类型
     * @return 对象
     */
    public static <T> T parseObject(String text, Class<T> clazz) {
        if (StringUtils.isEmpty(text)) {
            return null;
        }
        try {
            return OBJECT_MAPPER.readValue(text, clazz);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * 对字节数组的反序列化
     * @param bytes
     * @param clazz
     * @return
     * @param <T>
     */
    public static <T> T parseObject(byte[] bytes, Class<T> clazz) {
        if (ArrayUtil.isEmpty(bytes)) {
            return null;
        }
        try {
            return OBJECT_MAPPER.readValue(bytes, clazz);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * 复杂字符串的反序列化操作
     * 如果一个字符串具有复杂的泛型类型，那么可以使用这个方法得到我们想要的结果
     * TypeReference是jackson类中的泛型类型，用于反序列化json数据时提供类型信息
     *
     * @param text   JSON字符串
     * @param typeReference 对象类型
     * @param <T>    对象类型
     * @return 对象
     */
    public static <T> T parseObject(String text, TypeReference<T> typeReference) {
        if (StringUtils.isBlank(text)) {
            return null;
        }
        try {
            return OBJECT_MAPPER.readValue(text, typeReference);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
    /**
     * 将JSON字符串转换为Dict对象
     * Dict实际上也是一个hashmap，但是它比hashmap要更加强大
     *
     * @param text JSON字符串
     * @return Dict
     */
    public static Dict parseMap(String text) {
        if (StringUtils.isBlank(text)) {
            return null;
        }
        try {
            return OBJECT_MAPPER.readValue(text, OBJECT_MAPPER.getTypeFactory().constructType(Dict.class));
        } catch (MismatchedInputException e) {
            // 类型不匹配说明不是json
            return null;
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * 将字符串转换为数组字典
     * @param text
     * @return
     */
    public static List<Dict> parseArrayMap(String text) {
        if (StringUtils.isBlank(text)) {
            return null;
        }
        try {
            return OBJECT_MAPPER.readValue(text, OBJECT_MAPPER.getTypeFactory().constructCollectionType(List.class, Dict.class));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * 将字符串转换为数组对象
     * @param text
     * @param clazz
     * @return
     * @param <T>
     */
    public static <T> List<T> parseArray(String text, Class<T> clazz) {
        if (StringUtils.isEmpty(text)) {
            return new ArrayList<>();
        }
        try {
            return OBJECT_MAPPER.readValue(text, OBJECT_MAPPER.getTypeFactory().constructCollectionType(List.class, clazz));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

}
```

