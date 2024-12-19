# 【Mac】文件位置

## 目录
- [1. 目录](#目录)
- [2. 系统目录结构](#系统目录结构)
    - [2.1 核心系统目录](#核心系统目录)
    - [2.2 用户目录 (~)](#用户目录)
- [3. 配置文件位置](#配置文件位置)
    - [3.1 系统配置](#系统配置)
    - [3.2 用户配置](#用户配置)
    - [3.3 应用配置](#应用配置)
- [4. 常用命令](#常用命令)
    - [4.1 进程管理](#进程管理)
    - [4.2 文件操作](#文件操作)
    - [4.3 系统维护](#系统维护)
- [5. 注意事项](#注意事项)
- [6. 参考资源](#参考资源)



## 系统目录结构

### 核心系统目录

| 目录           | 描述                                    |
|--------------|---------------------------------------|
| `/`          | 根目录                                   |
| `/System`    | macOS系统文件                             |
| `/Library`   | 系统级库文件、应用支持文件和文档                      |
| `/Users`     | 用户主目录                                 |
| `/Applications` | 应用程序目录                               |
| `/private`   | 系统运行所需的私有文件                           |
| `/etc`       | 系统配置文件（实际是指向 /private/etc 的符号链接）      |
| `/var`       | 系统日志及变量文件（指向 /private/var）            |
| `/tmp`       | 临时文件（指向 /private/tmp）                 |

### 用户目录 (~)

| 目录               | 描述                              |
|------------------|----------------------------------|
| `~/Library`      | 用户级别的库文件                        |
| `~/Documents`    | 文档                              |
| `~/Downloads`    | 下载                              |
| `~/Desktop`      | 桌面                              |
| `~/Applications` | 用户安装的应用程序                       |
| `~/Pictures`     | 图片                              |
| `~/Movies`       | 视频                              |
| `~/Music`        | 音乐                              |

## 配置文件位置

### 系统配置

| 名称                    | 位置                                          | 说明                    |
|-----------------------|---------------------------------------------|------------------------|
| 系统环境变量              | `/etc/paths`                                | 系统级PATH配置            |
| 系统级环境变量目录          | `/etc/paths.d/`                             | 系统PATH配置目录           |
| Hosts文件              | `/etc/hosts`                                | 主机名映射配置              |
| DNS配置                | `/etc/resolv.conf`                          | DNS服务器配置             |
| 系统启动项               | `/Library/LaunchDaemons/`                   | 系统级开机启动项            |
| 用户启动项               | `~/Library/LaunchAgents/`                   | 用户级开机启动项            |

### 用户配置

| 名称                    | 位置                                          | 说明                    |
|-----------------------|---------------------------------------------|------------------------|
| Shell配置文件            | `~/.zshrc`                                  | Zsh配置文件              |
| Bash配置文件             | `~/.bash_profile`, `~/.bashrc`              | Bash配置文件             |
| SSH配置                | `~/.ssh/`                                   | SSH密钥和配置             |
| Git配置                | `~/.gitconfig`                              | Git全局配置              |

### 应用配置

| 名称                    | 位置                                          | 说明                    |
|-----------------------|---------------------------------------------|------------------------|
| Homebrew配置           | `/opt/homebrew/`                            | Homebrew安装目录         |
| Redis配置文件            | `/opt/homebrew/etc/redis.conf`              | Redis配置文件            |
| MySQL配置文件            | `/opt/homebrew/etc/my.cnf`                  | MySQL配置文件            |
| Nginx配置文件            | `/opt/homebrew/etc/nginx/nginx.conf`        | Nginx配置文件            |

## 常用命令

### 进程管理

```bash
# 查看端口占用并杀死进程
lsof -i :8080 -t | xargs kill -15    # 杀死占用8080端口的进程
lsof -i :8080                        # 查看占用8080端口的进程详情

# 查找并杀死特定进程
ps -a | grep jmeter | grep -v grep | awk '{print $1}' | xargs kill -15    # 杀死jmeter进程
ps aux | grep nginx                  # 查看nginx进程
pkill -f nginx                       # 杀死所有nginx进程
```

### 文件操作

```bash
# 查找文件
find ~ -name "*.log"                 # 在用户目录下查找所有.log文件
mdfind -name "filename"              # 使用Spotlight搜索文件

# 查看文件/目录大小
du -sh *                            # 查看当前目录下所有文件/文件夹大小
du -sh ~/Library                    # 查看指定目录大小

# 文件权限
chmod 755 file                      # 修改文件权限
chown user:group file               # 修改文件所有者
```

### 系统维护

```bash
# 清理系统缓存
sudo purge                          # 清理内存和磁盘缓存
rm -rf ~/Library/Caches/*          # 清理用户缓存

# 查看系统信息
system_profiler SPHardwareDataType  # 查看硬件信息
sw_vers                            # 查看系统版本
```

## 注意事项

1. 修改系统文件时需要使用 `sudo` 获取管理员权限
2. 重要文件修改前建议备份
3. 某些系统目录在 macOS Catalina 及以后版本中位于只读系统卷上
4. 使用 `killall` 命令时要谨慎，可能会影响系统稳定性

## 参考资源

- [Apple官方文档：macOS目录结构](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html)
- [Homebrew官方文档](https://docs.brew.sh/)
