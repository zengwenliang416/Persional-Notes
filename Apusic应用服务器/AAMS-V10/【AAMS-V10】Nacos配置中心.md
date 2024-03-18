# 【AAMS-V10】Nacos配置中心

## 功能需求

- 敏捷版发布相应配置到配置中心
- 从配置中心可以修改敏捷版的配置并更新
- 在配置中心修改配置后持久化配置到本地



```java
/**
     * 环境变量AAMS_CONFIG_CENTER=true或者JVM参数AAMS_CONFIG_CENTER=true为时发布配置并监听
     */
    private void publishConfig() {
        if (SHOULD_PUBLISH) {
            try {
                // 反射获取类和方法只需一次，之后可以被重用
                Class<?> configCenterClass = Class.forName(CONFIG_CENTER_CLASS);
                Method getInstanceMethod = configCenterClass.getMethod("getInstance");
                Object configCenter = getInstanceMethod.invoke(null);

                Method publishMethod = configCenterClass.getMethod("publishApusicConfig");
                publishMethod.invoke(configCenter);

                Method addListenerMethod = configCenterClass.getMethod("addConfigListener");
                addListenerMethod.invoke(configCenter);

            } catch (Exception e) {
                e.printStackTrace();
                log.error("Publishing configuration exception！");
            }
        }
    }

    /**
     * 环境变量AAMS_CONFIG_CENTER=true或者JVM参数AAMS_CONFIG_CENTER=true为时发布配置并监听
     * @return
     */
    private static String getConfigurationFlag() {
        String configCenterEnv = System.getenv(CONFIG_CENTER_ENABLE);
        if (configCenterEnv == null) {
            configCenterEnv = System.getProperty(CONFIG_CENTER_ENABLE);
        }
        return configCenterEnv;
    }
```



```java
import com.alibaba.nacos.api.NacosFactory;
import com.alibaba.nacos.api.config.ConfigService;
import com.alibaba.nacos.api.config.listener.Listener;
import com.apusic.config.utils.ConfigCenterUtils;

import org.w3c.dom.Document;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Properties;
import java.util.concurrent.Executor;
import java.util.logging.Logger;


public class ConfigCenter {
    private static final Logger logger = Logger.getLogger(ConfigCenterUtils.class.getName());
    private static ConfigCenter instance; // 单例模式的实例变量
    String configCenterAddr = null;
    String dataId = null;
    String group = null;
    long timeoutMs = 5000;
    String configsFileName = null;

    Listener listener = null;
    // 私有构造方法
    private ConfigCenter() {
        init();
    }

    private void init() {
        logger.info("配置中心设置正在进行初始化...");
        // 从环境变量或JVM参数获取配置
        configCenterAddr = System.getenv("CONFIG_CENTER_ADDR");
        if (configCenterAddr == null) {
            configCenterAddr = System.getProperty("serverAddr", "127.0.0.1:8848");
        }

        dataId = System.getenv("DATA_ID");
        if (dataId == null) {
            dataId = System.getProperty("com.apusic.ams.startup.ConfigCenter.dataId", "configs.xml");
        }

        group = System.getenv("GROUP");
        if (group == null) {
            group = System.getProperty("com.apusic.ams.startup.ConfigCenter.group", "DEFAULT_GROUP");
        }

        String timeout = System.getenv("TIMEOUT_MS");
        if (timeout == null) {
            timeout = System.getProperty("com.apusic.ams.startup.ConfigCenter.timeoutMs", "5000");
        }
        timeoutMs = Long.parseLong(timeout);

        configsFileName = System.getenv("CONFIGS_FILE_NAME");
        if (configsFileName == null) {
            configsFileName = System.getProperty("com.apusic.ams.startup.ConfigCenter.configsFileName", "configs.xml");
        }
        listener = new Listener() {
            @Override
            public void receiveConfigInfo(String configInfo) {
                updateApusicConfigs(configInfo);
            }

            @Override
            public Executor getExecutor() {
                return null;
            }
        };
    }
    // 公共的静态方法，用于获取单例
    public static synchronized ConfigCenter getInstance() {
        if (instance == null) {
            instance = new ConfigCenter();
        }
        return instance;
    }

    /**
     * 更新配置
     *
     * @param content
     */
    public void updateApusicConfigs(String content) {
        ConfigCenterUtils.saveConfigs(content, configsFileName);
    }

    /**
     * 从xml文件中获取配置信息（字符串形式）
     *
     * @return
     */
    public String getXMLConfig() {
        // 获取configs.xml的文件路径
        String filePath = ConfigCenterUtils.getFilePath("conf", configsFileName);
        // 判断文件是否存在
        if (!Files.exists(Paths.get(filePath))) {
            logger.warning("The file " + filePath + " does not exist.");
        } else {
            try {
                File apusicConf = new File(filePath);

                DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
                // 禁用外部实体 - 防御XXE攻击
                factory.setAttribute(XMLConstants.ACCESS_EXTERNAL_DTD, "");
                factory.setAttribute(XMLConstants.ACCESS_EXTERNAL_SCHEMA, "");
                DocumentBuilder builder = factory.newDocumentBuilder();
                // 解析 XML 文件获取 Document 对象
                Document document = builder.parse(apusicConf);
                // 标准化 XML 结构
                document.getDocumentElement().normalize();
                return ConfigCenterUtils.convertXMLDocumentToString(document);
            } catch (Exception e) {
                logger.warning("xml文件解析失败！");
                e.printStackTrace();
            }
        }
        return null;
    }
    public boolean publishApusicConfig(){
        return publishApusicConfig(dataId, group);
    }

    /**
     * 发布AAMS配置
     * @param dataId 配置ID
     * @param group 配置所在组
     * @return
     * @throws Exception
     */
    private boolean publishApusicConfig(String dataId, String group){
        try {
            Properties properties = new Properties();
            properties.put("serverAddr", configCenterAddr);
            ConfigService configService = NacosFactory.createConfigService(properties);
            String content = getXMLConfig();
            boolean isPublishOk = configService.publishConfig(dataId, group, content);
            return isPublishOk;
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            return false;
        }
    }
    public void addConfigListener() throws Exception {
        addConfigListener(dataId, group, listener);
    }
    private void addConfigListener(String dataId, String group, Listener listener) throws Exception {
        Properties properties = new Properties();
        properties.put("serverAddr", configCenterAddr);
        ConfigService configService = NacosFactory.createConfigService(properties);
        String content = configService.getConfig(dataId, group, 5000);
        logger.info("正在监听配置......");
        configService.addListener(dataId, group, listener);
    }


}
```

```java
import com.alibaba.nacos.api.NacosFactory;
import com.alibaba.nacos.api.config.ConfigService;
import com.alibaba.nacos.api.config.listener.Listener;
import com.apusic.config.utils.ConfigCenterUtils;

import org.w3c.dom.Document;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Properties;
import java.util.concurrent.Executor;
import java.util.logging.Logger;

public class ConfigCenter {
    private static final Logger logger = Logger.getLogger(ConfigCenter.class.getName());
    private final String configCenterAddr;
    private final String dataId;
    private final String group;
    private final long timeoutMs;
    private final String configsFileName;
    private final Listener listener;

    // Static inner class for thread-safe singleton initialization
    private static class Holder {
        private static final ConfigCenter INSTANCE = new ConfigCenter();
    }

    public static ConfigCenter getInstance() {
        return Holder.INSTANCE;
    }

    private ConfigCenter() {
        this.configCenterAddr = getConfigValue("CONFIG_CENTER_ADDR", "serverAddr", "127.0.0.1:8848");
        this.dataId = getConfigValue("DATA_ID", "com.apusic.ams.startup.ConfigCenter.dataId", "configs.xml");
        this.group = getConfigValue("GROUP", "com.apusic.ams.startup.ConfigCenter.group", "DEFAULT_GROUP");
        this.timeoutMs = Long.parseLong(getConfigValue("TIMEOUT_MS", "com.apusic.ams.startup.ConfigCenter.timeoutMs", "5000"));
        this.configsFileName = getConfigValue("CONFIGS_FILE_NAME", "com.apusic.ams.startup.ConfigCenter.configsFileName", "configs.xml");
        this.listener = new Listener() {
            @Override
            public void receiveConfigInfo(String configInfo) {
                updateApusicConfigs(configInfo);
            }

            @Override
            public Executor getExecutor() {
                return null; // Optionally provide an executor for asynchronous processing
            }
        };
        logger.info("ConfigCenter client has been initialized.");
    }

    // Unified method to get configuration values
    private String getConfigValue(String envKey, String sysPropKey, String defaultValue) {
        String value = System.getenv(envKey);
        return value != null ? value : System.getProperty(sysPropKey, defaultValue);
    }

    // ... omitted unchanged methods ...

    public String getXMLConfig() {
        String filePath = ConfigCenterUtils.getFilePath("conf", configsFileName);
        if (!Files.exists(Paths.get(filePath))) {
            logger.warning("Configuration file " + filePath + " does not exist.");
            return null;
        }
        try {
            File configXML = new File(filePath);
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setAttribute(XMLConstants.ACCESS_EXTERNAL_DTD, "");
            factory.setAttribute(XMLConstants.ACCESS_EXTERNAL_SCHEMA, "");
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document document = builder.parse(configXML);
            document.getDocumentElement().normalize();
            return ConfigCenterUtils.convertXMLDocumentToString(document);
        } catch (Exception e) {
            logger.warning("Failed to parse the XML configuration file: " + e.getMessage());
            return null;
        }
    }

    public boolean publishApusicConfig(String dataId, String group) {
        try {
            Properties properties = new Properties();
            properties.put("serverAddr", configCenterAddr);
            ConfigService configService = NacosFactory.createConfigService(properties);
            String content = getXMLConfig();
            if (content == null) {
                logger.warning("The content to be published is null.");
                return false;
            }
            return configService.publishConfig(dataId, group, content);
        } catch (Exception e) {
            logger.severe("Failed to publish configuration to ConfigCenter: " + e.getMessage());
            return false;
        }
    }

    // ... omitted unchanged methods ...
}
```

```java
package com.apusic.config.utils;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.*;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ConfigCenterUtils {
    private static final Logger logger = Logger.getLogger(ConfigCenterUtils.class.getName());
    /**
     * xml文件内容转为字符串
     *
     * @param doc
     * @return
     */
    public static String convertXMLDocumentToString(Document doc) {
        try {
            TransformerFactory tf = TransformerFactory.newInstance();
            Transformer transformer = tf.newTransformer();

            // 设置不要standalone="no"
            transformer.setOutputProperty(OutputKeys.METHOD, "xml");
            transformer.setOutputProperty(OutputKeys.INDENT, "no");
            transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
            transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes"); // 忽略自动生成的XML声明
            String xmlDeclaration = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";

            StringWriter writer = new StringWriter();
            transformer.transform(new DOMSource(doc), new StreamResult(writer));

            // 获取转换后的字符串
            String output = writer.getBuffer().toString();
            return xmlDeclaration + output;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    /**
     * 从apusicConfig标签中获取配置文件名
     *
     * @param config
     * @return
     */
    public static String getSaveConfigFile(String config) {
        // 正则表达式匹配config标签的name属性
        Pattern pattern = Pattern.compile("config\\s+name=\"([^\"]+)\"");
        // 创建一个Matcher对象
        Matcher matcher = pattern.matcher(config);
        String fileName = null;
        // 遍历所有匹配项
        while (matcher.find()) {
            // 获取匹配到的文件名
            fileName = matcher.group(1);
        }
        return fileName;
    }

    public static String getFilePath(String root, String name) {
        if (root == null) {
            root = System.getProperty("user.dir");
        }
        if (File.separatorChar != '/') {
            name = name.replace('/', File.separatorChar);
            root = root.replace('/', File.separatorChar);
        }
        String path = System.getProperty("apusic.home");

        if (path == null) {
            throw new RuntimeException("Did not set system property 'apusic.home'");
        }

        return path + File.separatorChar + root + File.separatorChar + name;
    }
    /**
     * 分离每个apusicConfig标签中的配置
     *
     * @param config
     */
    public static void saveConfigs(String config, String configsFileName) {
        // 更新configs.xml
        writeXMLFile(getFilePath("conf", configsFileName), config);
        // 正则表达式匹配<config >标签的内容
        Pattern pattern = Pattern.compile("<config [^>]*>(.*?)</config>", Pattern.DOTALL);
        Matcher matcher = pattern.matcher(config);

        while (matcher.find()) {
            String apusicConfigItem = matcher.group();
            String fileName = getSaveConfigFile(apusicConfigItem);
            String configItem = matcher.group(1);
            if ("apusic.conf".equals(fileName)) {
                saveApusicConfig(apusicConfigItem, getFilePath("conf", fileName));
            } else if (!fileName.endsWith("properties")) {
                configItem = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + configItem;
                writeXMLFile(getFilePath("conf", fileName), configItem);
                logger.info("File is saved in " + getFilePath("conf", fileName));

            } else {
                writeXMLFile(getFilePath("conf", fileName), configItem);
                logger.info("File is saved in " + getFilePath("conf", fileName));
            }
        }
    }

    /**
     * 存储配置到相应路径
     *
     * @param filePath
     * @param content
     */
    private static void writeXMLFile(String filePath, String content) {
        File file = new File(filePath);
        try (FileWriter writer = new FileWriter(file)) {
            writer.write(content);
            writer.flush();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    /**
     * 处理apysic.conf文件的保存
     *
     * @param apusicConfig
     * @param filePath
     */
    private static void saveApusicConfig(String apusicConfig, String filePath) {
        try {
            // 创建 DocumentBuilderFactory
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();

            // 解析 XML 字符串
            Document document = builder.parse(new ByteArrayInputStream(apusicConfig.getBytes("UTF-8")));

            // 手动创建不包含 standalone 的 XML 声明
            String xmlDeclaration = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";

            // 初始化 StringBuilder 用于构建最终的 XML 内容
            StringBuilder xmlContentBuilder = new StringBuilder(xmlDeclaration);

            // 查找所有的 config 元素
            NodeList configList = document.getElementsByTagName("config");
            for (int i = 0; i < configList.getLength(); i++) {
                Element config = (Element) configList.item(i);
                // 移除 'config' 元素中的 'name' 属性
                document.getDocumentElement().normalize(); // 标准化文档结构
                document.getElementsByTagName("config").item(0).getAttributes().removeNamedItem("name");
                // 创建新的 Document 来保存需要的 XML 内容
                Document newDocument = builder.newDocument();
                Node importedConfig = newDocument.importNode(config, true);
                newDocument.appendChild(importedConfig);

                // 使用 Transformer 将 Node 对象转换为字符串
                StringWriter writer = new StringWriter();
                Transformer transformer = TransformerFactory.newInstance().newTransformer();
                transformer.setOutputProperty(OutputKeys.INDENT, "no");
                transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
                transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes"); // 忽略自动生成的声明

                transformer.transform(new DOMSource(newDocument), new StreamResult(writer));

                // 将转换后的字符串添加到最终的 XML 内容中
                xmlContentBuilder.append(writer.toString());
            }

            // 将最终的 XML 内容写入到文件
            try (FileWriter fileWriter = new FileWriter(new File(filePath))) {
                fileWriter.write(xmlContentBuilder.toString());
                fileWriter.flush();
            }
            logger.info("File is saved in " + filePath);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

