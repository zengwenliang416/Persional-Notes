# Linux系统架构与内核 | Linux System Architecture and Kernel

## 目录 | Table of Contents

- [Linux系统架构 | Linux System Architecture](#linux系统架构--linux-system-architecture)
- [Linux内核 | Linux Kernel](#linux内核--linux-kernel)
- [内核模块 | Kernel Modules](#内核模块--kernel-modules)
- [系统调用 | System Calls](#系统调用--system-calls)
- [进程管理 | Process Management](#进程管理--process-management)
- [内存管理 | Memory Management](#内存管理--memory-management)
- [文件系统 | File Systems](#文件系统--file-systems)
- [设备驱动 | Device Drivers](#设备驱动--device-drivers)
- [网络栈 | Network Stack](#网络栈--network-stack)
- [参考资源 | References](#参考资源--references)

## Linux系统架构 | Linux System Architecture

Linux系统架构可以分为以下几个主要层次：

The Linux system architecture can be divided into the following main layers:

1. **硬件层 (Hardware Layer)** - 物理设备，如CPU、内存、硬盘、网卡等。
   Physical devices such as CPU, memory, hard disk, network card, etc.

2. **内核层 (Kernel Layer)** - 操作系统的核心，管理硬件资源并提供抽象接口。
   The core of the operating system, managing hardware resources and providing abstract interfaces.

3. **系统调用接口 (System Call Interface)** - 连接用户空间和内核空间的桥梁。
   The bridge connecting user space and kernel space.

4. **库 (Libraries)** - 如glibc，为应用程序提供API。
   Such as glibc, providing APIs for applications.

5. **应用程序 (Applications)** - 用户直接交互的软件。
   Software that users interact with directly.

```
+---------------------------+
|       应用程序            |
|     Applications          |
+---------------------------+
|         库                |
|      Libraries            |
+---------------------------+
|     系统调用接口          |
|  System Call Interface    |
+---------------------------+
|        内核              |
|       Kernel             |
+---------------------------+
|        硬件              |
|      Hardware            |
+---------------------------+
```

## Linux内核 | Linux Kernel

Linux内核是操作系统的核心组件，负责管理系统的资源和为用户程序提供服务。主要组件包括：

The Linux kernel is the core component of the operating system, responsible for managing system resources and providing services to user programs. The main components include:

1. **进程调度器 (Process Scheduler)** - 决定哪个进程在CPU上运行。
   Decides which process runs on the CPU.

2. **内存管理 (Memory Management)** - 管理物理内存和虚拟内存。
   Manages physical and virtual memory.

3. **虚拟文件系统 (Virtual File System)** - 提供统一的文件操作接口。
   Provides a unified interface for file operations.

4. **网络栈 (Network Stack)** - 实现网络协议和接口。
   Implements network protocols and interfaces.

5. **进程间通信 (Inter-Process Communication)** - 允许进程之间交换数据。
   Allows processes to exchange data.

6. **设备驱动程序 (Device Drivers)** - 与硬件设备交互的软件。
   Software that interacts with hardware devices.

## 内核模块 | Kernel Modules

内核模块是可以动态加载和卸载的内核代码片段，允许在不重启系统的情况下扩展内核功能。

Kernel modules are pieces of kernel code that can be dynamically loaded and unloaded, allowing kernel functionality to be extended without rebooting the system.

常用命令：

Common commands:

- `lsmod` - 列出当前加载的内核模块。
  Lists currently loaded kernel modules.
  
- `insmod` - 插入模块到内核。
  Inserts a module into the kernel.
  
- `rmmod` - 从内核移除模块。
  Removes a module from the kernel.
  
- `modinfo` - 显示模块信息。
  Displays information about a module.

- `modprobe` - 智能地加载或卸载模块，会处理依赖关系。
  Intelligently loads or unloads modules, handling dependencies.

## 系统调用 | System Calls

系统调用是用户空间程序请求内核服务的接口，常见的系统调用包括：

System calls are interfaces for user space programs to request kernel services. Common system calls include:

- `fork()` - 创建新进程。
  Creates a new process.
  
- `exec()` - 执行程序。
  Executes a program.
  
- `open()` / `read()` / `write()` / `close()` - 文件操作。
  File operations.
  
- `socket()` / `connect()` - 网络操作。
  Network operations.
  
- `malloc()` / `free()` - 内存分配。
  Memory allocation.

## 文件系统 | File Systems

Linux支持多种文件系统类型：

Linux supports multiple filesystem types:

- **ext2/ext3/ext4** - 扩展文件系统，Linux的原生文件系统。
  Extended File System, Linux's native filesystem.
  
- **XFS** - 高性能日志文件系统。
  High-performance journaling filesystem.
  
- **Btrfs** - B-tree文件系统，支持快照、RAID等功能。
  B-tree File System, supporting snapshots, RAID, etc.
  
- **NTFS/FAT** - Windows兼容文件系统。
  Windows-compatible filesystems.

- **NFS** - 网络文件系统。
  Network File System.

- **CIFS/SMB** - 公共互联网文件系统/服务器消息块。
  Common Internet File System/Server Message Block.

## 参考资源 | References

- [The Linux Kernel Documentation](https://www.kernel.org/doc/html/latest/)
- [Linux Kernel Development (Robert Love)](https://www.amazon.com/Linux-Kernel-Development-Robert-Love/dp/0672329468)
- [Understanding the Linux Kernel (Daniel P. Bovet)](https://www.oreilly.com/library/view/understanding-the-linux/0596005652/)
- [Linux Kernel Architecture (Wolfgang Mauerer)](https://www.amazon.com/Professional-Linux-Kernel-Architecture-Programmer/dp/0470343435) 