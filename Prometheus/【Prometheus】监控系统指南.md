# Prometheus 监控系统指南

## 目录
[1. 目录](#目录)
[2. 一、简介](#一简介)
    [2.1 主要特点](#主要特点)
[3. 二、安装和配置](#二安装和配置)
    [3.1 macOS安装](#macos安装)
    [3.2 Docker安装](#docker安装)
    [3.3 配置文件](#配置文件)
        [    基础配置 (prometheus.yml)](#基础配置-prometheusyml)
        [    配置文件位置](#配置文件位置)
[4. 三、基本使用](#三基本使用)
    [4.1 访问界面](#访问界面)
    [4.2 PromQL基础查询](#promql基础查询)
    [4.3 常用监控指标](#常用监控指标)
[5. 四、告警配置](#四告警配置)
    [5.1 告警规则示例](#告警规则示例)
    [5.2 Alertmanager配置](#alertmanager配置)
[6. 五、Grafana配置](#五grafana配置)
    [6.1 添加数据源](#添加数据源)
    [6.2 导入常用面板](#导入常用面板)
    [6.3 自定义面板示例](#自定义面板示例)
[7. 六、最佳实践](#六最佳实践)
    [7.1 性能优化](#性能优化)
    [7.2 存储配置](#存储配置)
    [7.3 安全建议](#安全建议)
[8. 七、故障排查](#七故障排查)
    [8.1 常见问题](#常见问题)
    [8.2 监控Prometheus自身](#监控prometheus自身)
[9. 八、参考资源](#八参考资源)



## 一、简介

Prometheus是一个开源的系统监控和告警工具包，最初由SoundCloud开发。它现在是继Kubernetes之后的第二个加入云原生计算基金会(CNCF)的项目。

### 主要特点

- 多维度数据模型（基于时间序列）
- PromQL查询语言
- 不依赖分布式存储
- 通过HTTP拉取数据
- 支持推送数据（通过中间网关）
- 多种图形和仪表盘支持（如Grafana）

## 二、安装和配置

### macOS安装

```bash
# 使用Homebrew安装
brew install prometheus

# 安装Grafana（可视化工具）
brew install grafana

# 启动服务
brew services start prometheus
brew services start grafana

# 检查服务状态
brew services list
```

### Docker安装

```bash
# 拉取镜像
docker pull prom/prometheus
docker pull grafana/grafana

# 运行Prometheus
docker run -d \
    --name prometheus \
    -p 9090:9090 \
    -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml \
    prom/prometheus

# 运行Grafana
docker run -d \
    --name grafana \
    -p 3000:3000 \
    grafana/grafana
```

### 配置文件

#### 基础配置 (prometheus.yml)
```yaml
global:
  scrape_interval: 15s    # 默认抓取间隔
  evaluation_interval: 15s # 规则评估间隔

# Alertmanager配置
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - localhost:9093

# 规则文件列表
rule_files:
  - "rules/*.yml"

# 抓取配置
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
```

#### 配置文件位置
- macOS (Homebrew): `/opt/homebrew/etc/prometheus.yml`
- Linux: `/etc/prometheus/prometheus.yml`
- Docker: 需要挂载到容器的`/etc/prometheus/prometheus.yml`

## 三、基本使用

### 访问界面
- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000`

### PromQL基础查询

```promql
# 查询当前指标
http_requests_total

# 过去5分钟的平均值
rate(http_requests_total[5m])

# 按标签筛选
http_requests_total{status="200"}

# 聚合查询
sum(rate(http_requests_total[5m])) by (status)
```

### 常用监控指标

```promql
# CPU使用率
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# 内存使用率
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# 磁盘使用率
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100

# 网络IO
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])
```

## 四、告警配置

### 告警规则示例

```yaml
groups:
- name: example
  rules:
  - alert: HighCPUUsage
    expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: High CPU usage on {{ $labels.instance }}
      description: CPU usage is above 80% for 5 minutes

  - alert: HighMemoryUsage
    expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: High memory usage on {{ $labels.instance }}
      description: Memory usage is above 90% for 5 minutes
```

### Alertmanager配置

```yaml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'email-notifications'

receivers:
- name: 'email-notifications'
  email_configs:
  - to: 'your-email@example.com'
    from: 'prometheus@example.com'
    smarthost: 'smtp.example.com:587'
    auth_username: 'your-username'
    auth_password: 'your-password'
```

## 五、Grafana配置

### 添加数据源
1. 访问Grafana (`http://localhost:3000`)
2. 默认登录凭据: admin/admin
3. 配置 → 数据源 → 添加数据源
4. 选择Prometheus
5. URL设置为`http://localhost:9090`
6. 保存并测试

### 导入常用面板
1. 创建 → 导入
2. 输入面板ID（常用面板）：
   - Node Exporter: 1860
   - MySQL: 7362
   - Redis: 763
   - JVM: 4701

### 自定义面板示例

```
# 系统负载面板
avg(node_load1) by (instance)
avg(node_load5) by (instance)
avg(node_load15) by (instance)

# HTTP请求面板
sum(rate(http_requests_total[5m])) by (status)

# 响应时间面板
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))
```

## 六、最佳实践

### 性能优化
- 合理设置抓取间隔
- 使用适当的存储保留期
- 优化查询语句
- 使用记录规则预计算

### 存储配置
```yaml
storage:
  tsdb:
    path: data/
    retention.time: 15d
    wal-compression: true
```

### 安全建议
- 启用认证
- 使用TLS加密
- 限制网络访问
- 定期备份数据

## 七、故障排查

### 常见问题
1. 服务无法启动
   ```bash
   # 检查日志
   tail -f /var/log/prometheus/prometheus.log
   
   # 验证配置
   promtool check config prometheus.yml
   ```

2. 数据抓取失败
   ```bash
   # 检查目标状态
   curl http://localhost:9090/api/v1/targets
   
   # 测试抓取
   curl http://target-host:port/metrics
   ```

### 监控Prometheus自身
```promql
# 抓取持续时间
rate(prometheus_target_interval_length_seconds_sum[5m])
/ rate(prometheus_target_interval_length_seconds_count[5m])

# 存储大小
prometheus_tsdb_storage_blocks_bytes

# 内存使用
process_resident_memory_bytes{job="prometheus"}
```

## 八、参考资源

- [Prometheus官方文档](https://prometheus.io/docs/introduction/overview/)
- [Grafana官方文档](https://grafana.com/docs/)
- [PromQL查询语言](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [告警配置指南](https://prometheus.io/docs/alerting/latest/configuration/)
