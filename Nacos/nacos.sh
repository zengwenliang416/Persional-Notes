#!/bin/bash
# Nacos 统一管理脚本
# 用法: ./nacos.sh [start|stop|restart|status|log]

# 显示使用帮助
show_usage() {
  echo "Nacos 管理脚本"
  echo "用法: $0 [选项]"
  echo "选项:"
  echo "  start    - 启动Nacos服务"
  echo "  stop     - 停止Nacos服务"
  echo "  restart  - 重启Nacos服务"
  echo "  status   - 查看服务状态"
  echo "  log      - 查看日志"
}

# 设置环境变量
NACOS_VERSION="2.2.3"
NACOS_PORT=8848
NACOS_DATA_DIR="$PWD/data"
NACOS_LOGS_DIR="$PWD/logs"
NACOS_CONF_DIR="$PWD/conf"
NACOS_CONTAINER_NAME="nacos-server"
MYSQL_CONTAINER_NAME="nacos-mysql"

# 创建数据目录
ensure_dirs() {
  mkdir -p "$NACOS_DATA_DIR" "$NACOS_LOGS_DIR" "$NACOS_CONF_DIR"
  echo "确保数据目录存在: $NACOS_DATA_DIR"
  echo "确保日志目录存在: $NACOS_LOGS_DIR"
  echo "确保配置目录存在: $NACOS_CONF_DIR"
}

# 启动MySQL容器(用于Nacos持久化)
start_mysql() {
  # 检查MySQL容器是否已存在
  if docker ps -a | grep -q "$MYSQL_CONTAINER_NAME"; then
    echo "MySQL容器已存在，正在启动..."
    docker start "$MYSQL_CONTAINER_NAME"
  else
    echo "创建并启动MySQL容器..."
    docker run -d --name "$MYSQL_CONTAINER_NAME" \
      -p 3306:3306 \
      -e MYSQL_ROOT_PASSWORD=root \
      -e MYSQL_DATABASE=nacos_config \
      -e MYSQL_USER=nacos \
      -e MYSQL_PASSWORD=nacos \
      mysql:8.0
    
    # 等待MySQL启动
    echo "等待MySQL启动..."
    sleep 10
    
    # 初始化Nacos数据库
    echo "初始化Nacos数据库..."
    docker exec "$MYSQL_CONTAINER_NAME" mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS nacos_config CHARACTER SET utf8 COLLATE utf8_bin;"
    
    # 导入Nacos数据库初始化脚本
    echo "正在获取Nacos MySQL初始化脚本..."
    curl -o /tmp/nacos-mysql.sql https://raw.githubusercontent.com/alibaba/nacos/v${NACOS_VERSION}/distribution/conf/mysql-schema.sql
    
    if [ -f /tmp/nacos-mysql.sql ]; then
      docker cp /tmp/nacos-mysql.sql "$MYSQL_CONTAINER_NAME":/tmp/
      docker exec "$MYSQL_CONTAINER_NAME" mysql -uroot -proot nacos_config < /tmp/nacos-mysql.sql
      echo "Nacos数据库初始化完成"
      rm -f /tmp/nacos-mysql.sql
    else
      echo "无法获取Nacos数据库初始化脚本，将使用内嵌数据库。"
    fi
  fi
}

# 启动Nacos容器
start_nacos() {
  ensure_dirs
  
  echo "检查Nacos容器是否已存在..."
  if docker ps -a | grep -q "$NACOS_CONTAINER_NAME"; then
    echo "Nacos容器已存在，正在启动..."
    docker start "$NACOS_CONTAINER_NAME"
  else
    echo "创建并启动Nacos容器..."
    
    # 获取MySQL容器IP
    if docker ps | grep -q "$MYSQL_CONTAINER_NAME"; then
      MYSQL_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$MYSQL_CONTAINER_NAME")
      USE_MYSQL=true
      echo "使用MySQL: $MYSQL_IP"
    else
      USE_MYSQL=false
      echo "未检测到MySQL容器，将使用内嵌数据库。"
    fi
    
    if [ "$USE_MYSQL" = true ]; then
      # 使用MySQL数据库
      docker run -d --name "$NACOS_CONTAINER_NAME" \
        -p $NACOS_PORT:8848 \
        -p 9848:9848 \
        -p 9849:9849 \
        -e JVM_XMS=512m \
        -e JVM_XMX=512m \
        -e MODE=standalone \
        -e SPRING_DATASOURCE_PLATFORM=mysql \
        -e MYSQL_SERVICE_HOST="$MYSQL_IP" \
        -e MYSQL_SERVICE_PORT=3306 \
        -e MYSQL_SERVICE_DB_NAME=nacos_config \
        -e MYSQL_SERVICE_USER=root \
        -e MYSQL_SERVICE_PASSWORD=root \
        -v "$NACOS_DATA_DIR":/home/nacos/data \
        -v "$NACOS_LOGS_DIR":/home/nacos/logs \
        -v "$NACOS_CONF_DIR":/home/nacos/conf \
        nacos/nacos-server:${NACOS_VERSION}
    else
      # 使用内嵌数据库
      docker run -d --name "$NACOS_CONTAINER_NAME" \
        -p $NACOS_PORT:8848 \
        -p 9848:9848 \
        -p 9849:9849 \
        -e JVM_XMS=512m \
        -e JVM_XMX=512m \
        -e MODE=standalone \
        -v "$NACOS_DATA_DIR":/home/nacos/data \
        -v "$NACOS_LOGS_DIR":/home/nacos/logs \
        -v "$NACOS_CONF_DIR":/home/nacos/conf \
        nacos/nacos-server:${NACOS_VERSION}
    fi
  fi
  
  echo "Nacos正在启动，可通过以下地址访问:"
  echo "控制台: http://localhost:$NACOS_PORT/nacos"
  echo "默认账号: nacos"
  echo "默认密码: nacos"
}

# 停止Nacos容器
stop_nacos() {
  echo "停止Nacos容器..."
  docker stop "$NACOS_CONTAINER_NAME" 2>/dev/null || true
  echo "Nacos容器已停止"
}

# 停止MySQL容器
stop_mysql() {
  echo "停止MySQL容器..."
  docker stop "$MYSQL_CONTAINER_NAME" 2>/dev/null || true
  echo "MySQL容器已停止"
}

# 查看Nacos服务状态
show_status() {
  echo "Nacos服务状态:"
  docker ps -a --filter "name=$NACOS_CONTAINER_NAME" --filter "name=$MYSQL_CONTAINER_NAME"
}

# 查看Nacos日志
show_logs() {
  echo "Nacos日志:"
  docker logs -f "$NACOS_CONTAINER_NAME"
}

# 主函数
main() {
  case "$1" in
    start)
      start_mysql
      start_nacos
      show_status
      ;;
    stop)
      stop_nacos
      stop_mysql
      ;;
    restart)
      stop_nacos
      stop_mysql
      start_mysql
      start_nacos
      show_status
      ;;
    status)
      show_status
      ;;
    log)
      show_logs
      ;;
    *)
      show_usage
      ;;
  esac
}

main "$@" 