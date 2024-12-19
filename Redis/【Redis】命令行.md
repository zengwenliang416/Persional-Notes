# Redis 命令行工具使用指南

## 目录
- [1. 目录](#目录)
- [2. 基础命令](#基础命令)
    - [2.1 版本和帮助](#版本和帮助)
    - [2.2 连接服务器](#连接服务器)
    - [2.3 监控和调试](#监控和调试)
    - [2.4 数据导入导出](#数据导入导出)
- [3. 常用操作示例](#常用操作示例)
    - [3.1 键值操作](#键值操作)
    - [3.2 批量操作](#批量操作)
    - [3.3 安全性](#安全性)
- [4. 高级功能](#高级功能)
    - [4.1 集群操作](#集群操作)
    - [4.2 发布订阅](#发布订阅)
    - [4.3 性能测试](#性能测试)
- [5. 故障排查](#故障排查)
    - [5.1 连接问题](#连接问题)
    - [5.2 内存分析](#内存分析)
- [6. 最佳实践](#最佳实践)
- [7. 参考资源](#参考资源)



## 基础命令

### 版本和帮助
```bash
# 查看 redis-cli 版本
redis-cli -v

# 查看 redis-server 版本
redis-server -v

# 显示帮助信息
redis-cli --help
```

### 连接服务器
```bash
# 基本连接（默认 localhost:6379）
redis-cli

# 指定主机和端口
redis-cli -h HOST -p PORT

# 使用密码连接
redis-cli -a PASSWORD

# 指定数据库索引（0-15）
redis-cli -n DATABASE_NUMBER
```

### 监控和调试
```bash
# 实时监控 Redis 服务器接收到的命令
redis-cli monitor

# 显示服务器统计信息
redis-cli info

# 显示延迟统计
redis-cli --latency

# 显示实时延迟图表
redis-cli --latency-dist
```

### 数据导入导出
```bash
# 导出 RDB 文件
redis-cli --rdb dump.rdb

# 导出 AOF 文件
redis-cli bgrewriteaof

# 从 RDB 文件恢复数据
redis-server --dbfilename dump.rdb
```

## 常用操作示例

### 键值操作
```bash
# 设置键值
redis-cli set mykey "Hello"

# 获取键值
redis-cli get mykey

# 删除键
redis-cli del mykey

# 检查键是否存在
redis-cli exists mykey
```

### 批量操作
```bash
# 批量删除键
redis-cli keys "pattern*" | xargs redis-cli del

# 清空当前数据库
redis-cli flushdb

# 清空所有数据库
redis-cli flushall
```

### 安全性
```bash
# 设置密码
redis-cli config set requirepass "your_password"

# 验证密码
redis-cli auth "your_password"
```

## 高级功能

### 集群操作
```bash
# 检查集群状态
redis-cli cluster info

# 显示集群节点
redis-cli cluster nodes

# 集群复制状态
redis-cli cluster replicas node-id
```

### 发布订阅
```bash
# 发布消息
redis-cli publish channel message

# 订阅频道
redis-cli subscribe channel

# 订阅多个频道
redis-cli subscribe channel1 channel2
```

### 性能测试
```bash
# 基本性能测试
redis-cli --eval script.lua

# 基准测试
redis-cli benchmark

# 指定请求数的基准测试
redis-cli benchmark -n 100000
```

## 故障排查

### 连接问题
```bash
# 测试连接
redis-cli ping

# 检查服务器是否运行
redis-cli info server

# 查看客户端连接列表
redis-cli client list
```

### 内存分析
```bash
# 显示内存使用情况
redis-cli info memory

# 查找大键
redis-cli --bigkeys

# 显示内存使用的详细信息
redis-cli memory stats
```

## 最佳实践

1. **安全建议**
   - 始终为生产环境设置强密码
   - 限制 Redis 访问到受信任的网络
   - 定期备份数据

2. **性能优化**
   - 使用 pipeline 批量操作
   - 合理设置键的过期时间
   - 避免使用耗时命令（如 KEYS）

3. **监控建议**
   - 定期检查内存使用情况
   - 监控延迟情况
   - 设置合适的告警阈值

## 参考资源

- [Redis 官方文档](https://redis.io/documentation)
- [Redis 命令参考](https://redis.io/commands)
- [Redis 安全指南](https://redis.io/topics/security)
