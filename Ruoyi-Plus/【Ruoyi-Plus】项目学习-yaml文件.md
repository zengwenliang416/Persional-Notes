# 【Ruoyi-Plus】项目学习-yml文件

### 定制加载配置

`Spring boot`一定加载`application.yml`以及激活的`application-xxx.yml`等形式的文件，`Spring boot`首先会加载`application.yml`，然后再加载我们激活的`application-xxx.yml`，如果两个同时激活，后加载的会覆盖掉前面加载的。

如果不符合这种命名规范的话就不会被自动加载，此时可以在类上加上注解加载该配置文件：

```java
@PropertySource(value = {"classpath:generator.yml"}, encoding = "UTF-8")
```

### 数组配置

```yaml
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

```java
package com.ruoyi.framework.config.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "security")
public class SecurityProperties {

    private String[] excludes;

} 
```

### 驼峰转换

在配置文件中，排除路径是一个数组，数组的配置的话会在前面加一个`-`和一个空格

连字符`-`可以实现驼峰转换，比如：

```yaml
jwt-secret-key: abcdefghijklmnopqrstuvwxyz
```

在代码中是这样的：

```java
private String jwtSecretKey;
```

### 配置文件隔离

在`Spring Boot`中，使用三个连字符 `---` 在单个 `application.yml` 文件中分隔不同的配置节是一种流行的做法。这可以让开发者在同一个物理文件中区分不同的逻辑或环境配置，而无需创建多个文件。这种方式对于管理和维护多环境配置特别有用。

例如，你可以在同一个 `application.yml` 文件中指定默认配置，开发环境配置，和生产环境配置：

```yaml
# 默认配置
server:
  port: 8080
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    username: sa
    password:

---

# 开发环境配置
spring:
  profiles: dev
  datasource:
    url: jdbc:mysql://localhost/devdb
    username: devuser
    password: devpass

---

# 生产环境配置
spring:
  profiles: prod
  datasource:
    url: jdbc:mysql://localhost/proddb
    username: produser
    password: prodpass
```

在这个例子中，我们定义了三个配置节。第一个是默认配置，它将应用于没有特定指定profile的情况；接着是开发环境的配置，这部分配置在激活 `dev` profile时将覆盖默认配置；最后是生产环境的配置，这部分配置在激活 `prod` profile时将覆盖默认配置。

`Spring Boot`使用 `spring.profiles` 属性来确定哪部分配置是激活状态。启动应用时，你可以通过设置 `spring.profiles.active` 属性来指定活跃的`profile`，如通过命令行参数（`--spring.profiles.active=prod`）、环境变量或其他方法。

使用这种方式可以使配置文件更加模块化和易于管理，尤其是当多个环境或配置组需要维护时，它们都聚合在同一个文件中，方便开发者查看和对比。

### 指定配置文件

```
java -jar xxx.jar --spring.config.name=application-xxx
或者
java -jar xxx.jar --spring.profiles.active=xxx
```
