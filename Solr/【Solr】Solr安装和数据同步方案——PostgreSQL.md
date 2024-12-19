# 【Solr】Solr安装和数据同步方案——PostgreSQL

## 目录
- [1. 目录](#目录)
- [2. 项目结构](#项目结构)
- [3. 主要功能](#主要功能)
- [4. 配置说明](#配置说明)
    - [4.1 PostgreSQL 配置](#postgresql-配置)
    - [4.2 Solr 配置](#solr-配置)
    - [4.3 Solrconfig 配置](#solrconfig-配置)
    - [4.4 定时任务配置](#定时任务配置)
    - [4.5 数据导入查询配置](#数据导入查询配置)
    - [4.6 Schema 配置](#schema-配置)
    - [4.7 JVM 配置](#jvm-配置)
    - [4.8 日志配置](#日志配置)
- [5. 使用方法](#使用方法)
- [6. 日志查看](#日志查看)
- [7. 注意事项](#注意事项)



## 项目结构

```
solr/
├── Dockerfile              # Docker 构建文件
├── README.md              # 项目文档
├── config/                # Solr 配置文件
│   ├── data-config.xml    # PostgreSQL 数据导入配置
│   ├── managed-schema     # Solr Schema 配置
│   ├── security.json      # Solr 安全配置
│   └── solrconfig.xml     # Solr Core 配置
├── docker/                # Docker 相关文件
│   └── crontab           # 定时任务配置
├── lib/                   # 外部依赖库
│   └── postgresql-42.7.4.jar  # PostgreSQL JDBC 驱动
└── scripts/              # 脚本文件
    ├── setup-solr.sh     # Solr 初始化脚本
    └── solr-import.sh    # 数据导入脚本
```

## 主要功能

- 自动创建和配置 Solr Core
- 支持 PostgreSQL 数据导入
- 配置了定时全量和增量数据导入
- 支持时区配置（默认为 Asia/Shanghai）
- 内置数据导入日志记录

## 配置说明

### PostgreSQL 配置
数据库连接信息在 `config/data-config.xml` 中配置：
```xml
<dataSource name="source1" type="JdbcDataSource"
          driver="org.postgresql.Driver"
          url="jdbc:postgresql://url/datebaseName"
          user="username"
          password="password" />
```
修改方法：
1. 编辑 `config/data-config.xml` 文件
2. 更新 dataSource 标签中的以下属性：
   - url: 修改为你的数据库连接地址
   - user: 修改为你的数据库用户名
   - password: 修改为你的数据库密码

### Solr 配置
1. 安全认证配置（`config/security.json`）：
```json
{
  "authentication": {
    "class": "solr.BasicAuthPlugin",
    "credentials": {
      "username": "password"
    }
  }
}
```
修改方法：
- 编辑 `config/security.json` 文件
- 在 credentials 中修改用户名和密码

2. Core 配置：
- Core 名称修改：
  1. 编辑 `scripts/setup-solr.sh` 中的 `CORE_NAME` 变量
  2. 同步修改 `scripts/solr-import.sh` 中的 URL 路径
  3. 更新 `config/data-config.xml` 中的相关查询

3. 时区配置（Dockerfile）：
```dockerfile
ENV TZ=Asia/Shanghai \
    SOLR_OPTS="-Duser.timezone=Asia/Shanghai"
```
修改方法：
- 编辑 Dockerfile 中的环境变量设置

### Solrconfig 配置
在 `config/solrconfig.xml` 中配置数据导入处理器（DIH）：

```xml
<requestHandler name="/dataimport" class="solr.DataImportHandler"> 
    <lst name="defaults"> 
        <str name="config">data-config.xml</str> 
    </lst> 
</requestHandler>
```

配置步骤：
1. 添加数据导入处理器配置：
   - 在 solrconfig.xml 中添加上述 requestHandler 配置
   - config 参数指向 data-config.xml 的相对路径

2. 移动所需的 jar 包：
   - 将以下文件从 `/opt/solr-8.11.1/dist/` 移动到 `/opt/solr-8.11.1/server/solr-webapp/webapp/WEB-INF/lib/`：
     * solr-dataimporthandler-8.11.1.jar
     * solr-dataimporthandler-extras-8.11.1.jar

3. 配置修改后：
   - 需要重启 Solr 服务
   - 或者通过 Admin UI 重新加载 Core

### 定时任务配置
在 `docker/crontab` 中配置定时任务：
```bash
# 每分钟执行一次全量导入
* * * * * /opt/solr-8.11.1/scripts/solr-import.sh full

# 每分钟执行一次增量导入
* * * * * /opt/solr-8.11.1/scripts/solr-import.sh delta
```
修改方法：
1. 编辑 `docker/crontab` 文件
2. 按照 cron 表达式修改执行时间：
   - 分钟 (0-59)
   - 小时 (0-23)
   - 日期 (1-31)
   - 月份 (1-12)
   - 星期 (0-7)

示例：
```bash
# 每天凌晨2点执行全量导入
0 2 * * * /opt/solr-8.11.1/scripts/solr-import.sh full

# 每小时执行一次增量导入
0 * * * * /opt/solr-8.11.1/scripts/solr-import.sh delta
```

### 数据导入查询配置
在 `config/data-config.xml` 中配置数据查询：
```xml
<entity name="address" pk="id"
        query="SELECT id, name, address, created_at, updated_at FROM your_table">
    <field column="id" name="id"/>
    <field column="name" name="name"/>
    <field column="address" name="address"/>
    <field column="created_at" name="created_at"/>
    <field column="updated_at" name="updated_at"/>
</entity>
```
修改方法：
1. 编辑 `config/data-config.xml` 文件
2. 修改 entity 标签中的查询语句
3. 更新字段映射关系

### Schema 配置
`config/managed-schema` 需要与 `data-config.xml` 中的字段映射保持一致：

```xml
<!-- managed-schema 中的字段定义示例 -->
<field name="id" type="string" indexed="true" stored="true" required="true"/>
<field name="name" type="text_general" indexed="true" stored="true"/>
<field name="address" type="text_general" indexed="true" stored="true"/>
<field name="created_at" type="pdate" indexed="true" stored="true"/>
<field name="updated_at" type="pdate" indexed="true" stored="true"/>

<!-- 复制字段配置示例 -->
<copyField source="name" dest="_text_"/>
<copyField source="address" dest="_text_"/>
```

修改步骤：
1. 在 `data-config.xml` 添加或修改字段映射后：
   - 在 `managed-schema` 中添加对应的 `<field>` 定义
   - 为每个字段选择合适的字段类型（type）
   - 设置是否索引（indexed）和存储（stored）
   - 设置是否必需（required）

2. 常用的字段类型：
   - string：字符串，不分词
   - text_general：文本，会分词
   - pdate：日期时间类型
   - plongs：长整型
   - pdoubles：双精度浮点型
   - boolean：布尔类型

3. 索引优化建议：
   - 需要精确匹配的字段使用 string 类型
   - 需要分词搜索的字段使用 text_general 类型
   - 考虑添加 copyField 来支持全文搜索
   - 不需要展示的字段可以设置 stored="false"
   - 不需要搜索的字段可以设置 indexed="false"

4. 字段修改注意事项：
   - 修改字段类型可能需要重建索引
   - 删除字段前确保没有依赖关系
   - 添加 required="true" 的字段需要确保数据源中有对应的值

### JVM 配置
在 `Dockerfile` 中配置了 JVM 参数：

```dockerfile
ENV SOLR_JAVA_MEM="-Xms2g -Xmx4g" \
    GC_LOG_OPTS="-Xlog:gc*:file=/var/solr/logs/solr_gc.log:time,uptime:filecount=9,filesize=20M"
```

修改方法：
1. JVM 内存配置：
   - `-Xms`: 最小堆内存（建议至少 2GB）
   - `-Xmx`: 最大堆内存（建议至少 4GB）
   - 根据数据量和服务器资源适当调整

2. GC 日志配置：
   - 日志路径：`/var/solr/logs/solr_gc.log`
   - 日志轮转：保留 9 个文件
   - 单个日志大小：20MB

3. 性能优化建议：
   - 如果数据量大，建议增加最大堆内存
   - 监控 GC 日志，根据需要调整内存配置
   - 考虑添加其他 JVM 参数如 `-XX:+UseG1GC`

### 日志配置
- 导入日志路径：`/var/log/cron.log`
- 修改方法：
  1. 编辑 `scripts/solr-import.sh`
  2. 更新 `LOG_FILE` 变量的值

## 使用方法

1. 构建 Docker 镜像：
   ```bash
   docker build -t solr-import .
   ```

2. 运行容器：
   ```bash
   docker run -d -p 8983:8983 solr-import
   ```

3. 访问 Solr 管理界面：
   ```
   http://localhost:8983/solr/
   ```

4. 手动触发数据导入：
   ```bash
   # 全量导入
   curl -s "http://username:password@localhost:8983/solr/address/dataimport?command=full-import&commit=true"
   
   # 增量导入
   curl -s "http://username:password@localhost:8983/solr/address/dataimport?command=delta-import&commit=true"
   ```

## 日志查看

- Solr 日志：容器内的标准输出
- 导入日志：`/var/log/cron.log`

## 注意事项

1. 安全性
   - 建议修改默认的管理员密码
   - 生产环境中应使用环境变量管理敏感信息
   - 确保数据库连接信息的安全性

2. 性能优化
   - 根据数据量调整导入频率
   - 考虑使用增量导入减少服务器负载
   - 适当配置 Solr 的内存参数

3. 维护建议
   - 定期检查导入日志
   - 监控磁盘空间使用情况
   - 根据需要调整导入策略