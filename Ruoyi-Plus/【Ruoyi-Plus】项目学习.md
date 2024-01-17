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

