# 【Grafana】安装指南

## 一、Grafana 简介

Grafana 是一个开源的数据可视化和监控平台，支持多种数据源（如 Prometheus、MySQL、Elasticsearch 等），可以创建丰富的仪表板和图表。

### 1. 主要特性

1. **多数据源支持**：
   - 时序数据库：Prometheus, InfluxDB
   - 关系型数据库：MySQL, PostgreSQL
   - 文档数据库：Elasticsearch
   - 云服务：CloudWatch, Azure Monitor

2. **可视化功能**：
   - 丰富的图表类型
   - 动态仪表板
   - 自定义面板
   - 告警功能

3. **用户管理**：
   - 多租户支持
   - 细粒度权限控制
   - LDAP/OAuth 集成

## 二、安装方式

### 1. Docker 安装（推荐）

```bash
# 拉取官方镜像
docker pull grafana/grafana:latest

# 创建持久化数据目录
mkdir -p /var/lib/grafana

# 运行容器
docker run -d \
  --name=grafana \
  -p 3000:3000 \
  -v /var/lib/grafana:/var/lib/grafana \
  grafana/grafana:latest

# 使用 Docker Compose
cat > docker-compose.yml << EOF
version: '3'
services:
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana-storage:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
volumes:
  grafana-storage:
EOF

docker-compose up -d
```

### 2. Linux 系统安装

#### Ubuntu/Debian
```bash
# 添加 APT 源
sudo apt-get install -y apt-transport-https software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# 更新并安装
sudo apt-get update
sudo apt-get install grafana

# 启动服务
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

#### CentOS/RHEL
```bash
# 创建 YUM 源
cat > /etc/yum.repos.d/grafana.repo << EOF
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

# 安装
sudo yum install grafana

# 启动服务
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

### 3. macOS 安装

```bash
# 使用 Homebrew 安装
brew update
brew install grafana

# 启动服务
brew services start grafana
```

### 4. Windows 安装

1. 下载安装包：
   - 访问 [Grafana 下载页面](https://grafana.com/grafana/download)
   - 选择 Windows 版本下载

2. 安装步骤：
   - 运行安装程序
   - 按照向导完成安装
   - 安装完成后通过 Windows 服务启动

## 三、基本配置

### 1. 配置文件位置

- Linux: `/etc/grafana/grafana.ini`
- macOS: `/usr/local/etc/grafana/grafana.ini`
- Windows: `<安装目录>/conf/defaults.ini`
- Docker: `/etc/grafana/grafana.ini`

### 2. 重要配置项

```ini
[server]
# HTTP 端口
http_port = 3000
# 域名设置
domain = localhost

[security]
# 管理员密码
admin_password = admin
# 是否允许注册
allow_sign_up = false
# 允许嵌入 iframe
allow_embedding = true

[auth]
# 禁用登录表单
disable_login_form = false
# 匿名访问
enabled = false

[paths]
# 数据存储路径
data = /var/lib/grafana
# 日志路径
logs = /var/log/grafana

[security.allow_embedding]
# 允许从任何域名嵌入
enabled = true
# 允许特定域名嵌入（推荐）
# allowed_domains = ["your-domain.com", "another-domain.com"]
```

### 3. 环境变量配置

Docker 环境可以通过环境变量覆盖配置：

```bash
docker run -d \
  -p 3000:3000 \
  -e "GF_SERVER_ROOT_URL=http://grafana.server.name" \
  -e "GF_SECURITY_ADMIN_PASSWORD=secret" \
  grafana/grafana
```

## 四、初始化设置

### 1. 首次登录

1. 访问 `http://localhost:3000`
2. 默认凭据：
   - 用户名：admin
   - 密码：admin
3. 首次登录后需要修改密码

### 2. 配置数据源

1. 点击 Configuration > Data Sources
2. 选择需要添加的数据源类型
3. 配置连接信息
4. 测试并保存

### 3. 创建仪表板

1. 点击 Create > Dashboard
2. 添加新的面板
3. 选择数据源和可视化类型
4. 配置查询和显示选项
5. 保存仪表板

## 五、安全建议

1. **基本安全设置**：
   - 修改默认管理员密码
   - 禁用注册功能
   - 配置 HTTPS
   - 设置适当的访问控制

2. **身份认证**：
   - 配置 LDAP/OAuth
   - 启用多因素认证
   - 实施密码策略

3. **网络安全**：
   - 使用反向代理
   - 限制访问 IP
   - 配置防火墙规则

## 六、故障排查

1. **常见问题**：
   - 无法启动服务
   - 数据源连接失败
   - 面板加载缓慢
   - 权限问题

2. **日志查看**：
```bash
# Docker 容器日志
docker logs grafana

# 系统服务日志
sudo journalctl -u grafana-server

# 日志文件
tail -f /var/log/grafana/grafana.log
```

3. **健康检查**：
```bash
# 检查服务状态
systemctl status grafana-server

# 检查端口
netstat -tulpn | grep 3000
```

## 七、升级指南

### 1. Docker 升级

```bash
# 拉取新版本
docker pull grafana/grafana:latest

# 停止并删除旧容器
docker stop grafana
docker rm grafana

# 使用新镜像启动
docker run -d \
  --name=grafana \
  -p 3000:3000 \
  -v grafana-storage:/var/lib/grafana \
  grafana/grafana:latest
```

### 2. 系统包升级

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get upgrade grafana

# CentOS/RHEL
sudo yum update grafana

# macOS
brew upgrade grafana
```

## 八、备份和恢复

### 1. 数据备份

```bash
# 备份配置文件
cp /etc/grafana/grafana.ini /backup/

# 备份数据目录
tar -czf grafana-data-backup.tar.gz /var/lib/grafana/

# Docker 数据卷备份
docker run --rm \
  -v grafana-storage:/source:ro \
  -v $(pwd):/backup \
  ubuntu tar -czf /backup/grafana-backup.tar.gz -C /source .
```

### 2. 数据恢复

```bash
# 恢复配置文件
cp /backup/grafana.ini /etc/grafana/

# 恢复数据目录
tar -xzf grafana-data-backup.tar.gz -C /

# Docker 数据卷恢复
docker run --rm \
  -v grafana-storage:/dest \
  -v $(pwd):/backup \
  ubuntu bash -c "cd /dest && tar -xzf /backup/grafana-backup.tar.gz"