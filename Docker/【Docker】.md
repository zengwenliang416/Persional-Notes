好的，我们分别来详细解答 Docker命令用法 和 Dockerfile编写技巧。

A. 更详细的Docker命令用法

1. 镜像管理

a. docker pull

用法：

docker pull <image>:<tag>

	•	如果不指定 <tag>，默认拉取 latest 版本。
示例：

docker pull nginx:1.21
docker pull ubuntu  # 拉取最新的 Ubuntu 镜像

b. docker build

用法：

docker build -t <image_name>:<tag> <build_context>

	•	<build_context> 是构建上下文，可以是 Dockerfile 所在的目录或 .tar 文件。
示例：

docker build -t myapp:1.0 .
docker build -f custom.Dockerfile -t customapp:2.0 .

c. docker save / docker load

	•	保存镜像到文件：

docker save -o myapp.tar myapp:1.0


	•	从文件加载镜像：

docker load -i myapp.tar

2. 容器管理

a. docker run

用法：

docker run [options] <image>

常用参数：
	•	-d：后台运行。
	•	-it：交互式运行。
	•	--name：指定容器名称。
	•	-p：映射端口。
	•	-v：挂载数据卷。
	•	--env 或 -e：设置环境变量。
示例：

docker run -d --name mynginx -p 8080:80 nginx
docker run -it --name ubuntu-test ubuntu bash

b. docker logs

查看容器日志：

docker logs <container>  # 默认显示全部日志
docker logs -f <container>  # 实时查看日志
docker logs --since 1h <container>  # 查看最近 1 小时日志

c. docker exec

用法：

docker exec -it <container> <command>

进入容器交互：

docker exec -it mynginx bash

3. 数据卷管理

a. docker volume create

用法：

docker volume create myvolume

b. 挂载数据卷

挂载到容器：

docker run -d -v myvolume:/data nginx

查看卷挂载位置：

docker inspect <container>

4. 网络管理

a. 创建和连接网络

创建网络：

docker network create mynetwork

将容器连接到网络：

docker network connect mynetwork <container>

5. Docker Compose

a. docker-compose up

启动服务：

docker-compose up -d  # 后台启动

b. docker-compose logs

查看日志：

docker-compose logs -f  # 实时查看日志

B. Dockerfile 编写技巧

1. 基础指令

a. FROM

定义基础镜像：

FROM ubuntu:20.04

b. RUN

运行命令：

RUN apt-get update && apt-get install -y nginx

c. COPY

复制文件到容器：

COPY ./source /app

d. WORKDIR

设置工作目录：

WORKDIR /app

e. CMD

定义容器启动命令（不能被覆盖）：

CMD ["nginx", "-g", "daemon off;"]

f. ENTRYPOINT

设置入口命令（可以追加参数）：

ENTRYPOINT ["python3", "app.py"]

2. 示例：Node.js 应用 Dockerfile

# 基础镜像
FROM node:14

# 设置工作目录
WORKDIR /usr/src/app

# 复制文件
COPY package*.json ./
RUN npm install

COPY . .

# 暴露端口
EXPOSE 3000

# 设置启动命令
CMD ["node", "index.js"]

3. 多阶段构建示例

用于构建和运行分离，优化镜像大小。

# 第1阶段：构建

FROM golang:1.17 as builder
WORKDIR /app
COPY . .
RUN go build -o main .

# 第2阶段：运行
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/main .
CMD ["./main"]









