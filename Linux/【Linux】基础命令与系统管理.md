# Linux基础命令与系统管理 | Linux Basic Commands and System Management

![Linux](imgs/linux-logo.png)

## 目录 | Table of Contents

- [基本介绍 | Basic Introduction](#基本介绍--basic-introduction)
- [常用命令 | Common Commands](#常用命令--common-commands)
- [系统管理 | System Management](#系统管理--system-management)
- [文件管理 | File Management](#文件管理--file-management)
- [用户管理 | User Management](#用户管理--user-management)
- [网络工具 | Network Tools](#网络工具--network-tools)
- [进程管理 | Process Management](#进程管理--process-management)
- [文本处理 | Text Processing](#文本处理--text-processing)
- [权限管理 | Permission Management](#权限管理--permission-management)
- [软件包管理 | Package Management](#软件包管理--package-management)
- [参考资源 | References](#参考资源--references)

## 基本介绍 | Basic Introduction

Linux是一种开源操作系统，基于UNIX设计，由Linus Torvalds于1991年首次发布。它以高度的稳定性、安全性和灵活性而闻名，广泛应用于服务器、桌面计算机、嵌入式系统等。

Linux is an open-source operating system based on UNIX design, first released by Linus Torvalds in 1991. It is known for its high stability, security, and flexibility, and is widely used in servers, desktop computers, embedded systems, and more.

## 常用命令 | Common Commands

### 系统信息 | System Information

| 命令 Command | 描述 Description | 示例 Example |
|------------|----------------|-------------|
| `uname -a` | 显示系统信息 Display system information | `uname -a` |
| `cat /etc/os-release` | 显示Linux发行版信息 Display Linux distribution information | `cat /etc/os-release` |
| `uptime` | 显示系统运行时间 Display system uptime | `uptime` |
| `hostname` | 显示主机名 Display hostname | `hostname` |
| `free -h` | 显示内存使用情况 Display memory usage | `free -h` |
| `df -h` | 显示磁盘使用情况 Display disk usage | `df -h` |
| `top` | 显示系统进程 Display system processes | `top` |

### 文件操作 | File Operations

| 命令 Command | 描述 Description | 示例 Example |
|------------|----------------|-------------|
| `ls` | 列出目录内容 List directory contents | `ls -la` |
| `cd` | 更改目录 Change directory | `cd /home/user` |
| `pwd` | 显示当前工作目录 Display current working directory | `pwd` |
| `mkdir` | 创建目录 Create directory | `mkdir test` |
| `rm` | 删除文件或目录 Remove files or directories | `rm file.txt` `rm -rf dir` |
| `cp` | 复制文件或目录 Copy files or directories | `cp file.txt /tmp/` |
| `mv` | 移动或重命名文件 Move or rename files | `mv file.txt newname.txt` |
| `touch` | 创建空文件或更新时间戳 Create empty file or update timestamp | `touch newfile.txt` |
| `cat` | 查看文件内容 View file contents | `cat file.txt` |
| `more/less` | 分页查看文件内容 View file contents page by page | `less file.txt` |
| `head/tail` | 查看文件开头/结尾 View beginning/end of file | `head -n 10 file.txt` |
| `find` | 查找文件 Find files | `find / -name "*.txt"` |
| `grep` | 文本搜索 Text search | `grep "pattern" file.txt` |

## 系统管理 | System Management

### 进程管理 | Process Management

| 命令 Command | 描述 Description | 示例 Example |
|------------|----------------|-------------|
| `ps` | 显示进程状态 Display process status | `ps aux` |
| `kill` | 终止进程 Terminate process | `kill -9 1234` |
| `killall` | 按名称终止进程 Kill processes by name | `killall firefox` |
| `pgrep` | 查找进程ID Find process ID | `pgrep firefox` |
| `pkill` | 按名称终止进程 Kill processes by name | `pkill firefox` |
| `htop` | 交互式进程查看器 Interactive process viewer | `htop` |

### 用户管理 | User Management

| 命令 Command | 描述 Description | 示例 Example |
|------------|----------------|-------------|
| `useradd` | 创建用户 Create user | `useradd john` |
| `usermod` | 修改用户 Modify user | `usermod -G wheel john` |
| `userdel` | 删除用户 Delete user | `userdel john` |
| `passwd` | 更改密码 Change password | `passwd john` |
| `who` | 显示登录用户 Show logged-in users | `who` |
| `id` | 显示用户和组信息 Display user and group information | `id john` |
| `su` | 切换用户 Switch user | `su - john` |
| `sudo` | 以其他用户身份执行命令 Execute command as another user | `sudo apt update` |

## 参考资源 | References

- [Linux Documentation Project](https://tldp.org/)
- [Linux Command Library](https://linuxcommandlibrary.com/)
- [Linux Journey](https://linuxjourney.com/)
- [Man Pages](https://www.kernel.org/doc/man-pages/) 