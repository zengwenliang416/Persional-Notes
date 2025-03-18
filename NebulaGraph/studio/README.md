# NebulaGraph Studio 部署指南

NebulaGraph Studio是NebulaGraph可视化图形界面工具，可以更直观地操作图数据库。

## 部署前提

1. 已经成功部署了NebulaGraph数据库
2. Docker和Docker Compose已安装

## 快速部署

### 1. 确认NebulaGraph网络名称

在启动Studio前，需要确认NebulaGraph的Docker网络名称，可以通过以下命令查看：

```bash
docker network ls
```

找到形如`docker-compose_nebula-net`的网络名称，并修改`docker-compose.yaml`文件中的外部网络名称。

### 2. 启动Studio服务

```bash
cd NebulaGraph/studio
docker-compose up -d
```

### 3. 访问Studio

浏览器访问：`http://localhost:7001` 或 `http://服务器IP:7001`

### 4. 连接数据库

在Studio界面中填写以下信息连接NebulaGraph数据库：
- 主机: graphd
- 端口: 9669
- 用户名: root
- 密码: nebula (或您设置的密码)

## 常见问题

1. 如果无法连接到NebulaGraph，请检查网络配置是否正确
2. 确保NebulaGraph服务已正常启动并可访问

## 停止服务

```bash
cd NebulaGraph/studio
docker-compose down
``` 