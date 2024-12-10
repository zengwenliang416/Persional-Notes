好的，这里是更详细的步骤和解释：

### Dockerfile

```dockerfile
# 使用Solr官方轻量级基础镜像
FROM solr:8.11.1

# 切换到root用户以便进行文件操作
USER root

# 创建数据目录以保存Solr核心和配置文件
RUN mkdir -p /var/solr/data/itsp

# 复制鉴权文件到指定目录
COPY security.json /var/solr/data/security.json

# 从默认配置集中复制配置文件到新的核心目录
RUN cp -r /opt/solr/server/solr/configsets/_default/conf /var/solr/data/itsp/conf

# 修改目录权限以确保Solr用户可以访问和操作
RUN chown -R solr:solr /var/solr/data/itsp

# 切换回Solr用户
USER solr

# 暴露Solr的默认端口
EXPOSE 8983

# 启动Solr，以前台模式运行
CMD ["solr-foreground"]
```

### 构建镜像

在有Dockerfile的目录中，运行以下命令以构建Docker镜像：

```bash
sudo docker build -t solr:8.11.1 .
```

### 鉴权文件 `security.json`

确保将以下JSON内容保存为 `security.json` 文件：

```json
{
    "authentication": {
        "blockUnknown": true,
        "class": "solr.BasicAuthPlugin",
        "credentials": {
            "admin": "D2rmpIs+KyLRhRZnvx1sjXXkTras3S4eOTeSCOzAIAs= iw4JtZcZD5rhtsmu7M+WtEF9ce5aIPcWkIhcOO/74u4="
        },
        "realm": "My Solr users",
        "forwardCredentials": false
    },
    "authorization": {
        "class": "solr.RuleBasedAuthorizationPlugin",
        "permissions": [
            {
                "name": "all",
                "role": [
                    "admin"
                ]
            }
        ],
        "user-role": {
            "admin": [
                "admin"
            ]
        }
    }
}
```

### 重要路径和配置

- **Solr核心位置**: `/var/solr/data/itsp` - 这里存储Solr的核心数据和配置。
- **Solr默认配置复制**: 复制位于`/opt/solr/server/solr/configsets/_default/conf`的默认配置到新的核心目录。
- **权限设置**: 使用`chown`命令确保目录对Solr用户是可读写的。

### 运行容器

使用以下命令运行构建好的Solr容器：

```bash
sudo docker run -d -p 8983:8983 solr:8.11.1
```

### 验证Solr服务

运行容器后，可以通过浏览器访问`http://localhost:8983/solr`来验证Solr是否正确启动。

### 进一步配置和说明

- **定制化配置**: 可以根据需要修改`security.json`中的用户和权限设置以适应不同的安全需求。
- **持久化数据**: 如果需要确保数据在重启容器后不丢失，可以使用Docker卷来挂载`/var/solr/data`路径。
- **性能调优**: 通过配置Java堆大小和其他参数，可以优化Solr性能。 

这份指南帮助您快速构建和运行一个安全的Solr实例，并提供基础的配置指导。如果有进一步的需求或问题，可以根据Solr的官方文档进行更深入的学习和配置。