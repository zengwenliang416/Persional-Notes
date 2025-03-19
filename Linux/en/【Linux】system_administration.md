# Linux System Administration Guide

## User and Group Management

### User Management Commands

```bash
# Add user
useradd -m -s /bin/bash username

# Set user password
passwd username

# Modify user information
usermod -c "Full Name" username

# Delete user
userdel -r username

# Add to sudo group
usermod -aG sudo username

# View user information
id username
finger username
```

### Group Management Commands

```bash
# Create new group
groupadd groupname

# Add user to group
usermod -aG groupname username

# Remove user from group
gpasswd -d username groupname

# Modify group information
groupmod -n new_name old_name

# Delete group
groupdel groupname
```

### Permission Management

```bash
# Change file owner
chown user:group filename

# Recursively change directory permissions
chmod -R 755 directory

# Set SUID bit (execute with owner permissions)
chmod u+s filename

# Set SGID bit (execute with group permissions)
chmod g+s directory

# Set sticky bit (only owner can delete files)
chmod +t directory

# Set default permissions
umask 022
```

## System Monitoring and Performance Tuning

### System Resource Monitoring

```bash
# Real-time process monitoring
top
htop

# Memory usage
free -m
vmstat 1

# CPU information and usage
lscpu
mpstat -P ALL 1

# Disk usage
df -h
du -sh /path/to/directory

# Disk I/O monitoring
iostat -xz 1
iotop

# Network connection monitoring
netstat -tuln
ss -tuln
lsof -i
```

### Performance Tuning

```bash
# Adjust process priority
nice -n 10 command
renice +5 -p PID

# Limit process resource usage
ulimit -n 4096  # File descriptor limit

# View system calls
strace command

# Memory optimization
echo 1 > /proc/sys/vm/drop_caches  # Clear cache

# I/O scheduler settings
echo deadline > /sys/block/sda/queue/scheduler
```

## Service Management

### Systemd Service Management

```bash
# Start service
systemctl start service_name

# Stop service
systemctl stop service_name

# Restart service
systemctl restart service_name

# Enable at boot
systemctl enable service_name

# Disable at boot
systemctl disable service_name

# Check service status
systemctl status service_name

# List all services
systemctl list-units --type=service
```

### Creating Custom Services

Create file `/etc/systemd/system/myservice.service`:

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

Apply changes:

```bash
systemctl daemon-reload
systemctl enable myservice
systemctl start myservice
```

## Log Management

### System Logs

```bash
# View system logs
journalctl
less /var/log/syslog

# View logs in real-time
journalctl -f
tail -f /var/log/syslog

# View specific service logs
journalctl -u nginx.service

# View logs for specific time period
journalctl --since "2023-01-01" --until "2023-01-02 03:00"

# View boot logs
journalctl -b
```

### Log Rotation Configuration

Edit `/etc/logrotate.conf` or create configuration in `/etc/logrotate.d/`:

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

### Log Server Setup

Modify `/etc/rsyslog.conf` to send logs to a remote server:

```
*.* @logserver.example.com:514
```

## Backup and Recovery

### Data Backup Strategy

```bash
# Use rsync for incremental backups
rsync -avz --delete /source/directory/ /backup/directory/

# Sync to remote server
rsync -avz -e ssh /source/directory/ user@remote:/backup/directory/

# Create backup with tar
tar -czf backup-$(date +%Y%m%d).tar.gz /path/to/directory

# Backup entire disk or partition with dd
dd if=/dev/sda of=/backup/disk.img bs=4M status=progress
```

### Automated Backup Setup

Create a backup script and add to crontab:

```bash
# Edit crontab
crontab -e

# Add daily backup task (at 2:00 AM)
0 2 * * * /path/to/backup.sh
```

### System Recovery

```bash
# Restore from tar backup
tar -xzf backup.tar.gz -C /path/to/restore/

# Restore from dd image
dd if=/backup/disk.img of=/dev/sda bs=4M status=progress

# Restore using rsync
rsync -avz /backup/directory/ /destination/directory/
```

## System Security

### Basic Security Settings

```bash
# Update system
apt update && apt upgrade   # Debian/Ubuntu
yum update                  # CentOS/RHEL

# Disable unnecessary services
systemctl disable service_name

# Configure firewall
ufw allow 22/tcp            # Ubuntu
firewall-cmd --permanent --add-service=ssh   # CentOS/RHEL

# Modify SSH configuration
nano /etc/ssh/sshd_config
# Set:
# PermitRootLogin no
# PasswordAuthentication no
systemctl restart sshd
```

### Security Hardening Measures

```bash
# Set password policy
nano /etc/security/pwquality.conf
# Set:
# minlen = 12
# minclass = 3

# Restrict su command usage
dpkg-statoverride --update --add root sudo 4750 /bin/su

# Set file permissions
find /home -type f -perm -0777 -exec chmod 0755 {} \;
find /var/www -type d -exec chmod 0755 {} \;
find /var/www -type f -exec chmod 0644 {} \;

# Audit system
apt install auditd    # Debian/Ubuntu
yum install audit     # CentOS/RHEL
```

### Intrusion Detection

```bash
# Install intrusion detection systems
apt install rkhunter aide    # Debian/Ubuntu
yum install rkhunter aide    # CentOS/RHEL

# Initialize AIDE database
aide --init
mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Periodic checks
aide --check
```

## Network Configuration

### Network Setup

```bash
# View network interfaces
ip addr show
ifconfig

# Temporarily set IP address
ip addr add 192.168.1.100/24 dev eth0

# Permanently set IP (Ubuntu)
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
# Apply configuration
netplan apply

# Set hostname
hostnamectl set-hostname myserver
```

### Firewall Configuration

UFW (Ubuntu):

```bash
# Enable firewall
ufw enable

# Allow SSH
ufw allow ssh

# Allow Web services
ufw allow 80/tcp
ufw allow 443/tcp

# Allow specific IP
ufw allow from 192.168.1.0/24 to any port 3306

# View status
ufw status
```

Firewalld (CentOS/RHEL):

```bash
# Enable service
systemctl enable firewalld
systemctl start firewalld

# Allow services
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=ssh

# Allow port
firewall-cmd --permanent --add-port=8080/tcp

# Apply changes
firewall-cmd --reload
```

### DNS Configuration

```bash
# Set DNS servers
nano /etc/resolv.conf
```

```
nameserver 8.8.8.8
nameserver 8.8.4.4
search example.com
```

## Storage Management

### Disk Partitioning

```bash
# View disks and partitions
fdisk -l
lsblk

# Create partition
fdisk /dev/sdb

# Create filesystem
mkfs.ext4 /dev/sdb1
mkfs.xfs /dev/sdb2

# Mount partition
mount /dev/sdb1 /mnt/data

# Permanent mount (edit /etc/fstab)
echo "/dev/sdb1 /mnt/data ext4 defaults 0 2" >> /etc/fstab
```

### LVM Management

```bash
# Create physical volume
pvcreate /dev/sdc /dev/sdd

# Create volume group
vgcreate myvg /dev/sdc /dev/sdd

# Create logical volume
lvcreate -n mylv -L 100G myvg

# Extend logical volume
lvextend -L +50G /dev/myvg/mylv
resize2fs /dev/myvg/mylv    # Resize ext filesystem
xfs_growfs /dev/myvg/mylv   # Resize xfs filesystem
```

### RAID Configuration

```bash
# Create RAID 1 (mirror)
mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sda1 /dev/sdb1

# Check RAID status
mdadm --detail /dev/md0
cat /proc/mdstat

# Save configuration
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
update-initramfs -u
```

## Containers and Virtualization

### Docker Management

```bash
# Install Docker
apt install docker.io    # Debian/Ubuntu
yum install docker-ce    # CentOS/RHEL

# Start and enable on boot
systemctl start docker
systemctl enable docker

# Basic commands
docker ps                     # View running containers
docker images                 # View local images
docker pull nginx             # Pull image
docker run -d -p 80:80 nginx  # Run container
docker stop container_id      # Stop container
docker rm container_id        # Remove container
```

### Virtual Machine Management (KVM)

```bash
# Install KVM
apt install qemu-kvm libvirt-daemon-system virtinst  # Debian/Ubuntu
yum install qemu-kvm libvirt virt-install            # CentOS/RHEL

# Start service
systemctl start libvirtd
systemctl enable libvirtd

# Create virtual machine
virt-install --name myvm --ram 2048 --vcpus 2 \
  --disk path=/var/lib/libvirt/images/myvm.qcow2,size=20 \
  --os-type linux --os-variant ubuntu20.04 \
  --network bridge=virbr0 \
  --graphics none --console pty,target_type=serial \
  --location 'http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/'

# Manage virtual machines
virsh list --all              # View all VMs
virsh start myvm              # Start VM
virsh shutdown myvm           # Shutdown VM
virsh destroy myvm            # Force shutdown VM
virsh undefine myvm           # Delete VM configuration
```

## Automation and Configuration Management

### Ansible Basics

```bash
# Install Ansible
apt install ansible    # Debian/Ubuntu
yum install ansible    # CentOS/RHEL

# Create host inventory
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
# Test connection
ansible all -m ping

# Execute command
ansible webservers -m command -a "uptime"

# Run playbook
ansible-playbook deploy.yml
```

### Automation Script Example

System monitoring and alerting script:

```bash
#!/bin/bash

# Monitor CPU, memory, and disk usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
DISK_USAGE=$(df -h / | grep / | awk '{print $5}' | tr -d '%')

# Set thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

# Check and send alerts
if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
    echo "Warning: CPU usage ${CPU_USAGE}% exceeds threshold ${CPU_THRESHOLD}%" | mail -s "Server CPU Alert" admin@example.com
fi

if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
    echo "Warning: Memory usage ${MEMORY_USAGE}% exceeds threshold ${MEMORY_THRESHOLD}%" | mail -s "Server Memory Alert" admin@example.com
fi

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "Warning: Disk usage ${DISK_USAGE}% exceeds threshold ${DISK_THRESHOLD}%" | mail -s "Server Disk Alert" admin@example.com
fi
```

## Troubleshooting and Recovery

### Common Issues Diagnosis

```bash
# Check system logs
journalctl -xe
tail -f /var/log/syslog

# Check processes and resource usage
ps aux | grep process_name
top -c

# Check network connections
netstat -tuln
ping gateway_ip
traceroute example.com

# Check disk space
df -h
du -sh /*

# Check filesystem errors
fsck -f /dev/sda1
```

### Emergency Recovery

```bash
# Enter single user mode
# In GRUB boot menu, edit boot entry and add:
# linux /boot/vmlinuz-xxx root=/dev/sda1 ro single

# Reset root password (in single user mode)
passwd root

# Fix corrupted filesystem
fsck -y /dev/sda1

# Recovery from LiveCD
# Mount system disk
mount /dev/sda1 /mnt
# Create chroot environment
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
chroot /mnt
```

### Data Recovery

```bash
# Install recovery tools
apt install testdisk    # Debian/Ubuntu
yum install testdisk    # CentOS/RHEL

# Recover deleted partitions with testdisk
testdisk /dev/sda

# Recover deleted files with photorec
photorec /dev/sda

# Copy data from damaged disk
ddrescue /dev/sda /dev/sdb
```

## System Optimization

### Kernel Parameter Optimization

Edit `/etc/sysctl.conf`:

```
# Filesystem and I/O optimization
fs.file-max = 655360
vm.swappiness = 10
vm.dirty_ratio = 80
vm.dirty_background_ratio = 5

# Network optimization
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
```

Apply changes:

```bash
sysctl -p
```

### Service Optimization Example

Nginx optimization (`/etc/nginx/nginx.conf`):

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
    
    # Cache settings
    open_file_cache max=200000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;
    
    # GZIP compression
    gzip on;
    gzip_comp_level 5;
    gzip_min_length 256;
    gzip_types text/plain text/css application/json application/javascript text/xml;
}
```

### Application Performance Tuning

MySQL optimization (`/etc/mysql/my.cnf`):

```ini
[mysqld]
# Basic settings
innodb_buffer_pool_size = 4G
innodb_log_file_size = 512M
innodb_flush_method = O_DIRECT
innodb_flush_log_at_trx_commit = 2
sync_binlog = 0

# Connections
max_connections = 1000
thread_cache_size = 128

# Query cache
query_cache_type = 0

# Temporary tables
tmp_table_size = 64M
max_heap_table_size = 64M
```

---

> This document is continuously updated. Suggestions and additional content are welcome. 