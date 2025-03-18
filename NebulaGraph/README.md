# NebulaGraph 学习笔记

本文件夹用于存放 NebulaGraph 分布式图数据库的学习内容，包括但不限于：

- 基本概念和架构
- 安装和部署指南
- 数据模型设计
- Cypher 查询语言学习
- 性能优化技巧
- 实践案例

## 目录结构

- `docker-compose/` - 使用Docker Compose部署NebulaGraph的配置文件和说明

## Docker部署

### 1. 快速开始

本项目使用Docker Compose方式部署NebulaGraph，包括:
- `docker-compose/docker-compose.yaml`: NebulaGraph核心服务配置
- `studio/docker-compose.yaml`: NebulaGraph Studio可视化界面配置

### 2. 启动服务

```bash
# 启动NebulaGraph核心服务
cd docker-compose
docker compose up -d

# 启动Studio可视化界面
cd ../studio
docker compose up -d
```

### 3. 访问服务

- NebulaGraph Console: `docker exec -it docker-compose-console-1 nebula-console -addr graphd -port 9669 -u root -p nebula`
- NebulaGraph Studio: 浏览器访问 `http://localhost:7001`

在Studio界面中连接数据库时，填写以下信息：
- 主机: graphd
- 端口: 9669
- 用户名: root
- 密码: nebula

### 4. 停止服务

```bash
# 停止NebulaGraph核心服务
cd docker-compose
docker compose down

# 停止Studio服务
cd ../studio
docker compose down
```

更多详细说明请参考 [docker-compose/README.md](docker-compose/README.md)。

## 相关资源

- [NebulaGraph 官方文档](https://docs.nebula-graph.io/)
- [NebulaGraph GitHub](https://github.com/vesoft-inc/nebula) 