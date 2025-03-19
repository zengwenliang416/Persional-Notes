# Linux安装指南 | Linux Installation Guide

## 目录 | Table of Contents

- [准备工作 | Preparation](#准备工作--preparation)
- [安装方式 | Installation Methods](#安装方式--installation-methods)
- [发行版选择 | Distribution Selection](#发行版选择--distribution-selection)
- [安装步骤 | Installation Steps](#安装步骤--installation-steps)
- [系统分区 | System Partitioning](#系统分区--system-partitioning)
- [安装后配置 | Post-Installation Configuration](#安装后配置--post-installation-configuration)
- [常见问题 | Common Issues](#常见问题--common-issues)
- [参考资源 | References](#参考资源--references)

## 准备工作 | Preparation

在开始安装Linux之前，请确保完成以下准备工作：

Before starting Linux installation, please make sure to complete the following preparations:

1. **备份重要数据** | **Backup Important Data**
   
   无论您打算如何安装Linux，请确保备份所有重要数据。
   
   Regardless of how you plan to install Linux, make sure to backup all important data.

2. **确认硬件兼容性** | **Verify Hardware Compatibility**
   
   检查您的硬件是否与您选择的Linux发行版兼容。
   
   Check if your hardware is compatible with your chosen Linux distribution.

3. **准备安装介质** | **Prepare Installation Media**
   
   下载Linux发行版ISO镜像并创建可启动USB驱动器或DVD。
   
   Download Linux distribution ISO image and create a bootable USB drive or DVD.

4. **为安装腾出空间** | **Make Space for Installation**
   
   如果您打算双系统启动，请为Linux分区腾出空间。
   
   If you plan to dual-boot, make space for Linux partitions.

## 发行版选择 | Distribution Selection

Linux有许多不同的发行版，每个都有其特点：

Linux has many different distributions, each with its own characteristics:

| 发行版 Distribution | 特点 Features | 适合用户 Suitable For |
|-------------------|--------------|---------------------|
| Ubuntu | 用户友好，大型社区支持 User-friendly, large community support | 初学者、桌面用户 Beginners, desktop users |
| Fedora | 最新技术，Red Hat企业版的上游 Latest technology, upstream of Red Hat Enterprise | 开发者、技术爱好者 Developers, tech enthusiasts |
| Debian | 高度稳定，广泛的软件包支持 Highly stable, wide package support | 服务器、稳定性要求高的环境 Servers, stability-demanding environments |
| Arch Linux | 滚动更新，高度可定制 Rolling release, highly customizable | 高级用户、喜欢控制系统的用户 Advanced users, those who like to control their system |
| Linux Mint | 基于Ubuntu，传统桌面体验 Based on Ubuntu, traditional desktop experience | 从Windows迁移的用户 Users migrating from Windows |
| CentOS/Rocky Linux | 企业级稳定性 Enterprise-level stability | 服务器环境 Server environments |

## 安装方式 | Installation Methods

### 1. 单系统安装 | Single System Installation

完全擦除硬盘并仅安装Linux。

Completely erase the hard drive and install only Linux.

### 2. 双系统启动 | Dual Boot

在一台电脑上同时安装Linux和另一个操作系统（如Windows）。

Install Linux and another operating system (like Windows) on the same computer.

### 3. 虚拟化 | Virtualization

在虚拟机中安装Linux，如VirtualBox、VMware或Hyper-V。

Install Linux in a virtual machine like VirtualBox, VMware, or Hyper-V.

### 4. 容器 | Containers

使用Docker或LXC等容器技术运行Linux。

Run Linux using container technologies like Docker or LXC.

### 5. Live USB | Live USB

从USB驱动器运行Linux，无需安装。

Run Linux from a USB drive without installation.

## 安装步骤 | Installation Steps

以下是通用的Linux安装步骤（以Ubuntu为例）：

Here are the general Linux installation steps (using Ubuntu as an example):

1. **引导到安装媒体** | **Boot to Installation Media**
   
   插入USB或DVD并从中启动电脑。
   
   Insert the USB or DVD and boot your computer from it.

2. **选择语言和键盘布局** | **Select Language and Keyboard Layout**
   
   选择您偏好的语言和键盘布局。
   
   Choose your preferred language and keyboard layout.

3. **连接到网络** | **Connect to Network**
   
   如果可能，连接到WiFi或有线网络。
   
   If possible, connect to WiFi or wired network.

4. **选择安装类型** | **Choose Installation Type**
   
   选择是否安装第三方软件和更新。
   
   Choose whether to install third-party software and updates.

5. **配置磁盘分区** | **Configure Disk Partitioning**
   
   自动分区或手动配置分区。
   
   Automatic partitioning or manual configuration.

6. **创建用户账号** | **Create User Account**
   
   设置用户名和密码。
   
   Set up username and password.

7. **等待安装完成** | **Wait for Installation to Complete**
   
   系统会安装必要的软件包。
   
   The system will install necessary packages.

8. **重启电脑** | **Restart Computer**
   
   安装完成后移除安装媒体并重启。
   
   Remove installation media and restart after installation.

## 系统分区 | System Partitioning

推荐的Linux分区方案：

Recommended Linux partitioning scheme:

| 分区 Partition | 挂载点 Mount Point | 大小 Size | 文件系统 File System | 用途 Purpose |
|--------------|------------------|----------|-------------------|------------|
| /boot | /boot | 500MB | ext4 | 引导加载程序文件 Bootloader files |
| / | / | 20-50GB | ext4 | 系统文件 System files |
| /home | /home | 剩余空间 Remaining space | ext4 | 用户文件 User files |
| swap | - | RAM大小的1-2倍 1-2x RAM size | swap | 虚拟内存 Virtual memory |

## 安装后配置 | Post-Installation Configuration

安装Linux后，建议执行以下操作：

After installing Linux, it's recommended to perform the following actions:

1. **更新系统** | **Update System**
   ```bash
   sudo apt update && sudo apt upgrade   # Debian/Ubuntu
   sudo dnf upgrade                      # Fedora/RHEL/CentOS
   sudo pacman -Syu                      # Arch Linux
   ```

2. **安装显卡驱动** | **Install Graphics Drivers**
   ```bash
   # NVIDIA
   sudo apt install nvidia-driver-xxx    # Debian/Ubuntu
   sudo dnf install akmod-nvidia         # Fedora
   ```

3. **安装常用软件** | **Install Common Software**
   ```bash
   sudo apt install vlc gimp libreoffice # 常用应用 Common apps
   ```

4. **配置防火墙** | **Configure Firewall**
   ```bash
   sudo ufw enable                       # Ubuntu
   sudo systemctl start firewalld        # Fedora/RHEL
   ```

5. **设置系统备份** | **Set Up System Backup**
   ```bash
   sudo apt install timeshift            # 系统备份工具 System backup tool
   ```

## 参考资源 | References

- [Ubuntu 官方安装指南](https://ubuntu.com/tutorials/install-ubuntu-desktop) | [Ubuntu Official Installation Guide](https://ubuntu.com/tutorials/install-ubuntu-desktop)
- [Fedora 官方安装指南](https://docs.fedoraproject.org/en-US/fedora/latest/install-guide/) | [Fedora Official Installation Guide](https://docs.fedoraproject.org/en-US/fedora/latest/install-guide/)
- [Arch Linux 安装指南](https://wiki.archlinux.org/title/Installation_guide) | [Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide)
- [Linux Journey](https://linuxjourney.com/) - 初学者学习Linux的优秀资源 | An excellent resource for beginners learning Linux 