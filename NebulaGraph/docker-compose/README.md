# NebulaGraph Docker-Compose 部署指南

这个目录包含了使用Docker-Compose部署NebulaGraph v3.8.0的配置文件和说明。

## 目录结构

```
docker-compose/
├── docker-compose.yaml  # Docker-Compose配置文件
├── data/                # 数据持久化目录
│   ├── meta0/
│   ├── meta1/
│   ├── meta2/
│   ├── storage0/
│   ├── storage1/
│   └── storage2/
└── logs/                # 日志目录
    ├── meta0/
    ├── meta1/
    ├── meta2/
    ├── storage0/
    ├── storage1/
    ├── storage2/
    └── graph/
```

## 使用方法

### 启动服务

在`docker-compose`目录下执行以下命令启动NebulaGraph服务：

```bash
docker-compose up -d
```

启动后，集群包含以下服务：

- 3个Meta服务: metad0, metad1, metad2
- 3个Storage服务: storaged0, storaged1, storaged2
- 1个Graph服务: graphd
- 1个Console客户端: console (自动执行ADD HOSTS命令注册Storage服务)

### 查看服务状态

```bash
docker-compose ps
```

### 连接到NebulaGraph

#### 方式1：使用外部客户端连接

```bash
# 安装nebula-console客户端
docker run --rm -it --network=host vesoft/nebula-console:v3.8.0

# 连接到NebulaGraph
nebula-console -addr 127.0.0.1 -port 9669 -u root -p nebula
```

#### 方式2：使用容器内Console客户端

```bash
# 进入Console容器
docker exec -it docker-compose_console_1 bash

# 连接到Graph服务
nebula-console -addr graphd -port 9669 -u root -p nebula
```

### 停止服务

```bash
# 停止所有服务
docker-compose down

# 停止并删除数据卷
docker-compose down -v
```

## 常见问题

### 查看服务日志

```bash
# 查看特定服务的日志
docker-compose logs graphd
docker-compose logs metad0
docker-compose logs storaged0

# 持续查看日志
docker-compose logs -f
```

### Storage服务状态是OFFLINE

如果Storage服务显示为OFFLINE状态，可以手动注册Storage服务：

```
nebula> ADD HOSTS "storaged0":9779,"storaged1":9779,"storaged2":9779
``` 