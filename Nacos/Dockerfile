FROM --platform=linux/arm64 openjdk:8-jdk-slim

MAINTAINER pader "huangmnlove@163.com"

# Nacos版本
ARG nacos_version=2.2.3

WORKDIR /

RUN apt-get update && apt-get install -y wget iputils-ping vim curl unzip

# 下载Nacos并解压
RUN wget https://github.com/alibaba/nacos/releases/download/${nacos_version}/nacos-server-${nacos_version}.tar.gz && \
    tar -xzvf nacos-server-${nacos_version}.tar.gz && \
    rm -rf nacos-server-${nacos_version}.tar.gz && \
    mv nacos /nacos

WORKDIR /nacos

# 暴露Nacos的端口
EXPOSE 8848
EXPOSE 9848
EXPOSE 9849

# 设置启动脚本
COPY docker-startup.sh /nacos/docker-startup.sh
RUN chmod +x /nacos/docker-startup.sh

# 默认以单机模式启动
CMD ["/nacos/docker-startup.sh"] 