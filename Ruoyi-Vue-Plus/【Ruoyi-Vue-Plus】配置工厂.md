通过实现一个自定义注解可以把一些需要的yml配置文件转换为环境变量，具体流程:[[【Ruoyi-Vue-Plus】配置工厂流程.canvas|【Ruoyi-Vue-Plus】配置工厂流程]]，工厂类如下：

```java
package org.dromara.common.core.factory;  
  
import org.dromara.common.core.utils.StringUtils;  
import org.springframework.beans.factory.config.YamlPropertiesFactoryBean;  
import org.springframework.core.env.PropertiesPropertySource;  
import org.springframework.core.env.PropertySource;  
import org.springframework.core.io.support.DefaultPropertySourceFactory;  
import org.springframework.core.io.support.EncodedResource;  
  
import java.io.IOException;  
  
/**  
 * yml 配置源工厂  
 *  
 * @author Lion Li */public class YmlPropertySourceFactory extends DefaultPropertySourceFactory {  
  
    @Override  
    public PropertySource<?> createPropertySource(String name, EncodedResource resource) throws IOException {  
        String sourceName = resource.getResource().getFilename();  
        if (StringUtils.isNotBlank(sourceName) && StringUtils.endsWithAny(sourceName, ".yml", ".yaml")) {  
            YamlPropertiesFactoryBean factory = new YamlPropertiesFactoryBean();  
            factory.setResources(resource.getResource());  
            factory.afterPropertiesSet();  
            return new PropertiesPropertySource(sourceName, factory.getObject());  
        }  
        return super.createPropertySource(name, resource);  
    }  
  
}
```
具体使用如下：
这里的`@PropertySource(value = "classpath:common-satoken.yml", factory = YmlPropertySourceFactory.class)`注解把resources下的`common-satoken.yml`文件中的配置内容转换成了环境变量。
```java
package org.dromara.common.satoken.config;  
  
import cn.dev33.satoken.dao.SaTokenDao;  
import cn.dev33.satoken.jwt.StpLogicJwtForSimple;  
import cn.dev33.satoken.stp.StpInterface;  
import cn.dev33.satoken.stp.StpLogic;  
import org.dromara.common.core.factory.YmlPropertySourceFactory;  
import org.dromara.common.satoken.core.dao.PlusSaTokenDao;  
import org.dromara.common.satoken.core.service.SaPermissionImpl;  
import org.dromara.common.satoken.handler.SaTokenExceptionHandler;  
import org.springframework.boot.autoconfigure.AutoConfiguration;  
import org.springframework.context.annotation.Bean;  
import org.springframework.context.annotation.PropertySource;  
  
/**  
 * sa-token 配置  
 *  
 * @author Lion Li */@AutoConfiguration  
@PropertySource(value = "classpath:common-satoken.yml", factory = YmlPropertySourceFactory.class)  
public class SaTokenConfig {  
  
    @Bean  
    public StpLogic getStpLogicJwt() {  
        // Sa-Token 整合 jwt (简单模式)  
        return new StpLogicJwtForSimple();  
    }  
  
    /**  
     * 权限接口实现(使用bean注入方便用户替换)  
     */    @Bean  
    public StpInterface stpInterface() {  
        return new SaPermissionImpl();  
    }  
  
    /**  
     * 自定义dao层存储  
     */  
    @Bean  
    public SaTokenDao saTokenDao() {  
        return new PlusSaTokenDao();  
    }  
  
    /**  
     * 异常处理器  
     */  
    @Bean  
    public SaTokenExceptionHandler saTokenExceptionHandler() {  
        return new SaTokenExceptionHandler();  
    }  
  
}
```
