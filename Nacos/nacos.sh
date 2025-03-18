#!/bin/bash
# Nacos 服务管理脚本
# 适用于 macOS ARM 架构，使用内置数据库（Derby）
# 用法: ./nacos.sh [start|stop|restart|status|console]

# 显示使用帮助
show_usage() {
  echo "Nacos 管理脚本"
  echo "用法: $0 [选项]"
  echo "选项:"
  echo "  start    - 启动Nacos服务"
  echo "  stop     - 停止Nacos服务"
  echo "  restart  - 重启Nacos服务"
  echo "  status   - 查看服务状态"
  echo "  logs     - 查看服务日志"
}

# 配置信息
NACOS_VERSION="v2.3.0"
NACOS_PORT=8848
NACOS_GRPC_PORT=9848
NACOS_CONTAINER_NAME="nacos-server"
WORK_DIR="$PWD"

# 启动Nacos服务
start_nacos() {
  echo "启动Nacos服务..."
  
  # 创建自定义网络
  docker network create nacos-net 2>/dev/null || true
  
  # 创建数据目录
  mkdir -p "$WORK_DIR/data" "$WORK_DIR/logs" "$WORK_DIR/conf"
  
  # 启动Nacos服务
  docker run -d --name ${NACOS_CONTAINER_NAME} \
    --network nacos-net \
    -p ${NACOS_PORT}:${NACOS_PORT} \
    -p ${NACOS_GRPC_PORT}:${NACOS_GRPC_PORT} \
    -e MODE=standalone \
    -e PREFER_HOST_MODE=hostname \
    -e NACOS_AUTH_ENABLE=false \
    -e NACOS_REPLICAS=1 \
    -e JVM_XMS=512m \
    -e JVM_XMX=512m \
    -e JVM_XMN=256m \
    -v "$WORK_DIR/conf":/home/nacos/conf \
    -v "$WORK_DIR/data":/home/nacos/data \
    -v "$WORK_DIR/logs":/home/nacos/logs \
    nacos/nacos-server:${NACOS_VERSION}
  
  if [ $? -eq 0 ]; then
    echo "Nacos服务启动中..."
    echo "服务初始化可能需要几十秒，请耐心等待"
    echo "控制台地址: http://localhost:${NACOS_PORT}/nacos"
    echo "默认账号: nacos"
    echo "默认密码: nacos"
  else
    echo "Nacos服务启动失败！"
  fi
}

# 停止Nacos服务
stop_nacos() {
  echo "停止Nacos服务..."
  docker stop ${NACOS_CONTAINER_NAME} 2>/dev/null || true
  docker rm ${NACOS_CONTAINER_NAME} 2>/dev/null || true
  echo "Nacos服务已停止"
}

# 查看服务状态
show_status() {
  echo "Nacos服务状态:"
  docker ps -a --filter "name=${NACOS_CONTAINER_NAME}"
  
  # 检查服务可访问性
  if docker ps -q -f "name=${NACOS_CONTAINER_NAME}" | grep -q .; then
    echo ""
    echo "检查服务可访问性..."
    http_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${NACOS_PORT}/nacos/index.html)
    if [ "$http_code" = "200" ]; then
      echo "Nacos服务运行正常，可通过 http://localhost:${NACOS_PORT}/nacos 访问"
    else
      echo "Nacos服务似乎运行中，但网页返回状态码: $http_code"
      echo "服务可能仍在初始化，请稍后再试"
    fi
  fi
}

# 查看服务日志
show_logs() {
  echo "显示Nacos服务日志:"
  docker logs -f ${NACOS_CONTAINER_NAME}
}

# 主函数
main() {
  case "$1" in
    start)
      stop_nacos
      start_nacos
      ;;
    stop)
      stop_nacos
      ;;
    restart)
      stop_nacos
      start_nacos
      ;;
    status)
      show_status
      ;;
    logs)
      show_logs
      ;;
    *)
      show_usage
      ;;
  esac
}

main "$@" 