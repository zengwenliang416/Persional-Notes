# MySQL 安装指南

## 目录
- [1. 目录](#目录)
- [2. 一、macOS 安装](#一macos-安装)
    - [使用 Homebrew 安装（推荐）](#使用-homebrew-安装推荐)
    - [使用 DMG 安装包](#使用-dmg-安装包)
    - [初始配置（两种方式通用）](#初始配置两种方式通用)
- [3. 二、Windows 安装](#二windows-安装)
    - [使用安装包（推荐）](#使用安装包推荐)
    - [使用压缩包](#使用压缩包)
- [4. 三、Linux 安装](#三linux-安装)
    - [Ubuntu/Debian](#ubuntudebian)
    - [CentOS/RHEL](#centosrhel)
    - [使用 Docker](#使用-docker)
- [5. 四、常见问题解决](#四常见问题解决)
    - [连接问题](#连接问题)
    - [密码重置](#密码重置)
    - [权限问题](#权限问题)
- [6. 五、安装后配置](#五安装后配置)
    - [性能优化](#性能优化)
    - [安全配置](#安全配置)
    - [字符集配置](#字符集配置)
- [7. 六、参考资源](#六参考资源)



## 一、macOS 安装

### 使用 Homebrew 安装（推荐）

```bash
# 安装最新版本
brew install mysql

# 启动 MySQL 服务
brew services start mysql

# 停止 MySQL 服务
brew services stop mysql

# 重启 MySQL 服务
brew services restart mysql

# 查看服务状态
brew services list
```

### 使用 DMG 安装包

1. 访问 [MySQL 下载页面](https://dev.mysql.com/downloads/mysql/)
2. 选择 macOS 版本下载 DMG 安装包
3. 双击安装包并按照向导完成安装
4. 安装过程中会提供临时 root 密码，请务必保存

### 初始配置（两种方式通用）

```bash
# 安全配置向导
mysql_secure_installation

# 登录 MySQL
mysql -u root -p

# 修改 root 密码
ALTER USER 'root'@'localhost' IDENTIFIED BY 'your_new_password';
```

## 二、Windows 安装

### 使用安装包（推荐）

1. 下载 MySQL Installer
   - 访问 [MySQL 下载页面](https://dev.mysql.com/downloads/installer/)
   - 选择 Windows 版本安装包

2. 安装步骤
   ```
   1. 运行安装程序
   2. 选择安装类型（推荐 Developer Default）
   3. 检查依赖项
   4. 安装所需产品
   5. 配置 MySQL Server
      - 选择端口（默认 3306）
      - 设置 root 密码
      - 配置 Windows Service
   ```

3. 验证安装
   ```bash
   # 打开命令提示符
   mysql -u root -p
   ```

### 使用压缩包

1. 下载 ZIP 压缩包
2. 解压到指定目录（如 `C:\mysql`）
3. 配置环境变量
   ```
   1. 系统属性 → 高级 → 环境变量
   2. 系统变量 Path 中添加 MySQL bin 目录
   3. 新建变量 MYSQL_HOME 指向 MySQL 安装目录
   ```

4. 初始化数据库
   ```bash
   # 以管理员身份运行命令提示符
   cd C:\mysql\bin
   mysqld --initialize-insecure
   
   # 安装服务
   mysqld --install
   
   # 启动服务
   net start mysql
   ```

## 三、Linux 安装

### Ubuntu/Debian

```bash
# 更新包列表
sudo apt update

# 安装 MySQL
sudo apt install mysql-server

# 启动服务
sudo systemctl start mysql

# 设置开机启动
sudo systemctl enable mysql

# 检查状态
sudo systemctl status mysql

# 初始配置
sudo mysql_secure_installation
```

### CentOS/RHEL

```bash
# 添加 MySQL 仓库
sudo dnf install mysql-server  # CentOS 8
# 或
sudo yum install mysql-server  # CentOS 7

# 启动服务
sudo systemctl start mysqld

# 设置开机启动
sudo systemctl enable mysqld

# 获取临时密码
sudo grep 'temporary password' /var/log/mysqld.log

# 安全配置
sudo mysql_secure_installation
```

### 使用 Docker

```bash
# 拉取 MySQL 镜像
docker pull mysql:latest

# 运行 MySQL 容器
docker run -d \
  --name mysql \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=your_password \
  -v mysql_data:/var/lib/mysql \
  mysql:latest

# 查看容器状态
docker ps

# 进入容器
docker exec -it mysql mysql -uroot -p
```

## 四、常见问题解决

### 连接问题

```bash
# 检查服务状态
# macOS
brew services list

# Windows
net start mysql

# Linux
systemctl status mysql

# 检查端口占用
# macOS/Linux
lsof -i :3306

# Windows
netstat -ano | findstr :3306
```

### 密码重置

```bash
# 方法一：使用 --skip-grant-tables
# 停止 MySQL 服务
# 使用特权模式启动
mysqld_safe --skip-grant-tables &

# 连接并重置密码
mysql -u root
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;

# 方法二：使用初始化文件
# 创建初始化文件
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';" > mysql-init.txt

# 使用初始化文件启动
mysqld --init-file=mysql-init.txt
```

### 权限问题

```sql
-- 查看用户权限
SHOW GRANTS FOR 'user'@'localhost';

-- 授予权限
GRANT ALL PRIVILEGES ON database_name.* TO 'user'@'localhost';
FLUSH PRIVILEGES;

-- 创建新用户
CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'password';
```

## 五、安装后配置

### 性能优化

```ini
# my.cnf 或 my.ini 配置示例

# 缓冲池大小（根据可用内存调整）
innodb_buffer_pool_size = 4G

# 最大连接数
max_connections = 1000

# 查询缓存大小
query_cache_size = 64M

# 临时表大小
tmp_table_size = 64M
max_heap_table_size = 64M
```

### 安全配置

```sql
-- 删除匿名用户
DELETE FROM mysql.user WHERE User='';

-- 禁止 root 远程登录
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- 删除测试数据库
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- 刷新权限
FLUSH PRIVILEGES;
```

### 字符集配置

```ini
# my.cnf 配置
[client]
default-character-set = utf8mb4

[mysql]
default-character-set = utf8mb4

[mysqld]
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
```

## 六、参考资源

- [MySQL 官方文档](https://dev.mysql.com/doc/)
- [MySQL 社区版下载](https://dev.mysql.com/downloads/)
- [MySQL Docker Hub](https://hub.docker.com/_/mysql)
- [MySQL 配置优化指南](https://dev.mysql.com/doc/refman/8.0/en/optimization.html)
