# Linux系统管理指南

## 用户和组管理

### 用户管理命令

```bash
# 添加用户
useradd -m -s /bin/bash username

# 设置用户密码
passwd username

# 修改用户信息
usermod -c "Full Name" username

# 删除用户
userdel -r username

# 添加到sudo组
usermod -aG sudo username

# 查看用户信息
id username
finger username
```

### 组管理命令

```bash
# 创建新组
groupadd groupname

# 添加用户到组
usermod -aG groupname username

# 从组中删除用户
gpasswd -d username groupname

# 修改组信息
groupmod -n new_name old_name

# 删除组
groupdel groupname
```

### 权限管理

```bash
# 修改文件所有者
chown user:group filename

# 递归修改目录权限
chmod -R 755 directory

# 设置SUID位（执行时具有文件所有者权限）
chmod u+s filename

# 设置SGID位（执行时具有组权限）
chmod g+s directory

# 设置粘滞位（只有所有者能删除文件）
chmod +t directory

# 设置默认权限
umask 022
```

## 系统监控与性能调优

### 系统资源监控

```bash
# 实时进程监控
top
htop

# 内存使用情况
free -m
vmstat 1

# CPU信息和使用率
lscpu
mpstat -P ALL 1

# 磁盘使用情况
df -h
du -sh /path/to/directory

# 磁盘I/O监控
iostat -xz 1
iotop

# 网络连接监控
netstat -tuln
ss -tuln
lsof -i
```

### 性能调优

```bash
# 调整进程优先级
nice -n 10 command
renice +5 -p PID

# 限制进程资源使用
ulimit -n 4096  # 文件描述符限制

# 查看系统调用
strace command

# 内存优化
echo 1 > /proc/sys/vm/drop_caches  # 清除缓存

# I/O调度器设置
echo deadline > /sys/block/sda/queue/scheduler
```

## 服务管理

### Systemd服务管理

```bash
# 启动服务
systemctl start service_name

# 停止服务
systemctl stop service_name

# 重启服务
systemctl restart service_name

# 设置开机自启动
systemctl enable service_name

# 禁用开机自启动
systemctl disable service_name

# 查看服务状态
systemctl status service_name

# 列出所有服务
systemctl list-units --type=service
```

### 创建自定义服务

创建文件`/etc/systemd/system/myservice.service`:

```ini
[Unit]
Description=My Custom Service
After=network.target

[Service]
Type=simple
User=myuser
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/python3 /opt/myapp/app.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

应用更改:

```bash
systemctl daemon-reload
systemctl enable myservice
systemctl start myservice
```

## 日志管理

### 系统日志

```bash
# 查看系统日志
journalctl
less /var/log/syslog

# 实时查看日志
journalctl -f
tail -f /var/log/syslog

# 查看特定服务日志
journalctl -u nginx.service

# 查看特定时间段日志
journalctl --since "2023-01-01" --until "2023-01-02 03:00"

# 查看启动日志
journalctl -b
```

### 日志轮转配置

编辑`/etc/logrotate.conf`或在`/etc/logrotate.d/`中创建配置:

```
/var/log/myapp/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 www-data www-data
    postrotate
        systemctl reload myapp
    endscript
}
```

### 日志服务器设置

修改`/etc/rsyslog.conf`将日志发送到远程服务器:

```
*.* @logserver.example.com:514
```

## 备份与恢复

### 数据备份策略

```bash
# 使用rsync进行增量备份
rsync -avz --delete /source/directory/ /backup/directory/

# 同步到远程服务器
rsync -avz -e ssh /source/directory/ user@remote:/backup/directory/

# 使用tar创建备份
tar -czf backup-$(date +%Y%m%d).tar.gz /path/to/directory

# 使用dd备份整个磁盘或分区
dd if=/dev/sda of=/backup/disk.img bs=4M status=progress
```

### 自动备份设置

创建备份脚本并添加到crontab:

```bash
# 编辑crontab
crontab -e

# 添加每日备份任务 (每天凌晨2点)
0 2 * * * /path/to/backup.sh
```

### 系统恢复

```bash
# 从tar备份恢复
tar -xzf backup.tar.gz -C /path/to/restore/

# 从dd镜像恢复
dd if=/backup/disk.img of=/dev/sda bs=4M status=progress

# 使用rsync恢复
rsync -avz /backup/directory/ /destination/directory/
```

## 系统安全

### 基本安全设置

```bash
# 更新系统
apt update && apt upgrade   # Debian/Ubuntu
yum update                  # CentOS/RHEL

# 禁用不必要的服务
systemctl disable service_name

# 配置防火墙
ufw allow 22/tcp            # Ubuntu
firewall-cmd --permanent --add-service=ssh   # CentOS/RHEL

# 修改SSH配置
nano /etc/ssh/sshd_config
# 设置:
# PermitRootLogin no
# PasswordAuthentication no
systemctl restart sshd
```

### 安全强化措施

```bash
# 设置密码策略
nano /etc/security/pwquality.conf
# 设置:
# minlen = 12
# minclass = 3

# 限制su命令使用
dpkg-statoverride --update --add root sudo 4750 /bin/su

# 设置文件权限
find /home -type f -perm -0777 -exec chmod 0755 {} \;
find /var/www -type d -exec chmod 0755 {} \;
find /var/www -type f -exec chmod 0644 {} \;

# 审计系统
apt install auditd    # Debian/Ubuntu
yum install audit     # CentOS/RHEL
```

### 入侵检测

```bash
# 安装入侵检测系统
apt install rkhunter aide    # Debian/Ubuntu
yum install rkhunter aide    # CentOS/RHEL

# 初始化AIDE数据库
aide --init
mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# 周期性检查
aide --check
```

## 网络设置

### 网络配置

```bash
# 查看网络接口
ip addr show
ifconfig

# 临时设置IP地址
ip addr add 192.168.1.100/24 dev eth0

# 永久设置IP (Ubuntu)
nano /etc/netplan/01-netcfg.yaml
```

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses: [192.168.1.100/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

```bash
# 应用配置
netplan apply

# 设置主机名
hostnamectl set-hostname myserver
```

### 防火墙配置

UFW (Ubuntu):

```bash
# 启用防火墙
ufw enable

# 允许SSH
ufw allow ssh

# 允许Web服务
ufw allow 80/tcp
ufw allow 443/tcp

# 允许特定IP
ufw allow from 192.168.1.0/24 to any port 3306

# 查看状态
ufw status
```

Firewalld (CentOS/RHEL):

```bash
# 启用服务
systemctl enable firewalld
systemctl start firewalld

# 允许服务
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=ssh

# 允许端口
firewall-cmd --permanent --add-port=8080/tcp

# 应用更改
firewall-cmd --reload
```

### DNS配置

```bash
# 设置DNS服务器
nano /etc/resolv.conf
```

```
nameserver 8.8.8.8
nameserver 8.8.4.4
search example.com
```

## 存储管理

### 磁盘分区

```bash
# 查看磁盘和分区
fdisk -l
lsblk

# 创建分区
fdisk /dev/sdb

# 创建文件系统
mkfs.ext4 /dev/sdb1
mkfs.xfs /dev/sdb2

# 挂载分区
mount /dev/sdb1 /mnt/data

# 永久挂载 (编辑/etc/fstab)
echo "/dev/sdb1 /mnt/data ext4 defaults 0 2" >> /etc/fstab
```

### LVM管理

```bash
# 创建物理卷
pvcreate /dev/sdc /dev/sdd

# 创建卷组
vgcreate myvg /dev/sdc /dev/sdd

# 创建逻辑卷
lvcreate -n mylv -L 100G myvg

# 扩展逻辑卷
lvextend -L +50G /dev/myvg/mylv
resize2fs /dev/myvg/mylv    # 调整ext文件系统大小
xfs_growfs /dev/myvg/mylv   # 调整xfs文件系统大小
```

### RAID配置

```bash
# 创建RAID 1 (镜像)
mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sda1 /dev/sdb1

# 查看RAID状态
mdadm --detail /dev/md0
cat /proc/mdstat

# 保存配置
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
update-initramfs -u
```

## 容器与虚拟化

### Docker管理

```bash
# 安装Docker
apt install docker.io    # Debian/Ubuntu
yum install docker-ce    # CentOS/RHEL

# 启动并设置开机启动
systemctl start docker
systemctl enable docker

# 基本命令
docker ps                     # 查看运行中的容器
docker images                 # 查看本地镜像
docker pull nginx             # 拉取镜像
docker run -d -p 80:80 nginx  # 运行容器
docker stop container_id      # 停止容器
docker rm container_id        # 删除容器
```

### 虚拟机管理 (KVM)

```bash
# 安装KVM
apt install qemu-kvm libvirt-daemon-system virtinst  # Debian/Ubuntu
yum install qemu-kvm libvirt virt-install            # CentOS/RHEL

# 启动服务
systemctl start libvirtd
systemctl enable libvirtd

# 创建虚拟机
virt-install --name myvm --ram 2048 --vcpus 2 \
  --disk path=/var/lib/libvirt/images/myvm.qcow2,size=20 \
  --os-type linux --os-variant ubuntu20.04 \
  --network bridge=virbr0 \
  --graphics none --console pty,target_type=serial \
  --location 'http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/'

# 管理虚拟机
virsh list --all              # 查看所有虚拟机
virsh start myvm              # 启动虚拟机
virsh shutdown myvm           # 关闭虚拟机
virsh destroy myvm            # 强制关闭虚拟机
virsh undefine myvm           # 删除虚拟机配置
```

## 自动化与配置管理

### Ansible基础

```bash
# 安装Ansible
apt install ansible    # Debian/Ubuntu
yum install ansible    # CentOS/RHEL

# 创建主机清单
nano /etc/ansible/hosts
```

```ini
[webservers]
web1.example.com
web2.example.com

[dbservers]
db1.example.com
db2.example.com
```

```bash
# 测试连接
ansible all -m ping

# 执行命令
ansible webservers -m command -a "uptime"

# 执行playbook
ansible-playbook deploy.yml
```

### 自动化脚本示例

系统监控与报警脚本:

```bash
#!/bin/bash

# 监控CPU、内存和磁盘使用率
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
DISK_USAGE=$(df -h / | grep / | awk '{print $5}' | tr -d '%')

# 设置阈值
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

# 检查并发送告警
if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
    echo "警告: CPU使用率 ${CPU_USAGE}% 超过阈值 ${CPU_THRESHOLD}%" | mail -s "服务器CPU告警" admin@example.com
fi

if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
    echo "警告: 内存使用率 ${MEMORY_USAGE}% 超过阈值 ${MEMORY_THRESHOLD}%" | mail -s "服务器内存告警" admin@example.com
fi

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "警告: 磁盘使用率 ${DISK_USAGE}% 超过阈值 ${DISK_THRESHOLD}%" | mail -s "服务器磁盘告警" admin@example.com
fi
```

## 故障排除与恢复

### 常见问题排查

```bash
# 检查系统日志
journalctl -xe
tail -f /var/log/syslog

# 检查进程和资源使用
ps aux | grep process_name
top -c

# 检查网络连接
netstat -tuln
ping gateway_ip
traceroute example.com

# 检查磁盘空间
df -h
du -sh /*

# 检查文件系统错误
fsck -f /dev/sda1
```

### 紧急恢复

```bash
# 进入单用户模式
# 在GRUB启动菜单编辑启动项，添加:
# linux /boot/vmlinuz-xxx root=/dev/sda1 ro single

# 重置root密码 (单用户模式下)
passwd root

# 修复损坏的文件系统
fsck -y /dev/sda1

# 从LiveCD启动恢复
# 挂载系统盘
mount /dev/sda1 /mnt
# 创建chroot环境
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
chroot /mnt
```

### 数据恢复

```bash
# 安装恢复工具
apt install testdisk    # Debian/Ubuntu
yum install testdisk    # CentOS/RHEL

# 使用testdisk恢复删除的分区
testdisk /dev/sda

# 使用photorec恢复删除的文件
photorec /dev/sda

# 从损坏的磁盘复制数据
ddrescue /dev/sda /dev/sdb
```

## 系统优化

### 内核参数优化

编辑`/etc/sysctl.conf`:

```
# 文件系统和I/O优化
fs.file-max = 655360
vm.swappiness = 10
vm.dirty_ratio = 80
vm.dirty_background_ratio = 5

# 网络优化
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
```

应用更改:

```bash
sysctl -p
```

### 服务优化示例

Nginx优化 (`/etc/nginx/nginx.conf`):

```nginx
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    worker_connections 16384;
    multi_accept on;
    use epoll;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;
    
    # 缓存设置
    open_file_cache max=200000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;
    
    # GZIP压缩
    gzip on;
    gzip_comp_level 5;
    gzip_min_length 256;
    gzip_types text/plain text/css application/json application/javascript text/xml;
}
```

### 应用性能调优

MySQL优化 (`/etc/mysql/my.cnf`):

```ini
[mysqld]
# 基础设置
innodb_buffer_pool_size = 4G
innodb_log_file_size = 512M
innodb_flush_method = O_DIRECT
innodb_flush_log_at_trx_commit = 2
sync_binlog = 0

# 连接数
max_connections = 1000
thread_cache_size = 128

# 查询缓存
query_cache_type = 0

# 临时表
tmp_table_size = 64M
max_heap_table_size = 64M
```

---

> 本文档持续更新中，欢迎提出建议和补充内容。 