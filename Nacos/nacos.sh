#!/bin/bash
# Nacos管理脚本
# 作者: Claude
# 用法: ./nacos.sh [start|stop|restart|status|logs|build|console]

# 显示帮助信息
show_usage() {
  echo "Nacos管理脚本"
  echo "用法: $0 [选项]"
  echo "选项:"
  echo "  start    - 启动Nacos服务"
  echo "  stop     - 停止Nacos服务"
  echo "  restart  - 重启Nacos服务"
  echo "  status   - 查看Nacos状态"
  echo "  logs     - 查看Nacos日志"
  echo "  build    - 构建ARM架构的Nacos镜像"
  echo "  console  - 打开Nacos控制台(浏览器)"
  echo "  mysql    - 启用MySQL存储配置"
}

# 准备目录
prepare_dirs() {
  mkdir -p data logs conf
  if [ ! -f conf/custom.properties ]; then
    cp custom.properties conf/
  fi
}

# 构建镜像
build_image() {
  echo "构建ARM架构的Nacos镜像..."
  docker build -t nacos-arm64:2.2.3 .
  echo "镜像构建完成"
}

# 启动服务
start_nacos() {
  prepare_dirs
  echo "启动Nacos服务..."
  docker-compose up -d
  echo "Nacos已启动，请访问: http://localhost:8848/nacos"
  echo "默认用户名/密码: nacos/nacos"
}

# 停止服务
stop_nacos() {
  echo "停止Nacos服务..."
  docker-compose down
  echo "Nacos已停止"
}

# 重启服务
restart_nacos() {
  stop_nacos
  start_nacos
}

# 查看状态
check_status() {
  echo "Nacos容器状态:"
  docker-compose ps
  
  echo -e "\n检查Nacos健康状态:"
  curl -s http://localhost:8848/nacos/v1/console/health | grep -o "\"status\":\"UP\""
  if [ $? -eq 0 ]; then
    echo "Nacos状态正常"
  else
    echo "Nacos状态异常"
  fi
}

# 查看日志
view_logs() {
  docker-compose logs -f nacos
}

# 打开控制台
open_console() {
  echo "打开Nacos控制台..."
  open http://localhost:8848/nacos
}

# 启用MySQL配置
enable_mysql() {
  echo "修改docker-compose.yaml，启用MySQL配置..."
  sed -i '' 's/# - NACOS_DATABASE=mysql/- NACOS_DATABASE=mysql/g' docker-compose.yaml
  sed -i '' 's/# - MYSQL_SERVICE_HOST=mysql/- MYSQL_SERVICE_HOST=mysql/g' docker-compose.yaml
  sed -i '' 's/# - MYSQL_SERVICE_PORT=3306/- MYSQL_SERVICE_PORT=3306/g' docker-compose.yaml
  sed -i '' 's/# - MYSQL_SERVICE_USER=nacos/- MYSQL_SERVICE_USER=nacos/g' docker-compose.yaml
  sed -i '' 's/# - MYSQL_SERVICE_PASSWORD=nacos/- MYSQL_SERVICE_PASSWORD=nacos/g' docker-compose.yaml
  sed -i '' 's/# - MYSQL_SERVICE_DB_NAME=nacos_config/- MYSQL_SERVICE_DB_NAME=nacos_config/g' docker-compose.yaml
  
  # 取消MySQL部分的注释
  sed -i '' 's/#   image: mysql:8.0.33-arm64/  image: mysql:8.0.33-arm64/g' docker-compose.yaml
  sed -i '' 's/#   container_name: nacos-mysql/  container_name: nacos-mysql/g' docker-compose.yaml
  sed -i '' 's/#   restart: always/  restart: always/g' docker-compose.yaml
  sed -i '' 's/#   environment:/  environment:/g' docker-compose.yaml
  sed -i '' 's/#     - MYSQL_ROOT_PASSWORD=root/    - MYSQL_ROOT_PASSWORD=root/g' docker-compose.yaml
  sed -i '' 's/#     - MYSQL_DATABASE=nacos_config/    - MYSQL_DATABASE=nacos_config/g' docker-compose.yaml
  sed -i '' 's/#     - MYSQL_USER=nacos/    - MYSQL_USER=nacos/g' docker-compose.yaml
  sed -i '' 's/#     - MYSQL_PASSWORD=nacos/    - MYSQL_PASSWORD=nacos/g' docker-compose.yaml
  sed -i '' 's/#   volumes:/  volumes:/g' docker-compose.yaml
  sed -i '' 's/#     - .\/mysql:\/var\/lib\/mysql/    - .\/mysql:\/var\/lib\/mysql/g' docker-compose.yaml
  sed -i '' 's/#     - .\/init.d:\/docker-entrypoint-initdb.d/    - .\/init.d:\/docker-entrypoint-initdb.d/g' docker-compose.yaml
  sed -i '' 's/#   ports:/  ports:/g' docker-compose.yaml
  sed -i '' 's/#     - "3306:3306"/    - "3306:3306"/g' docker-compose.yaml
  sed -i '' 's/#   networks:/  networks:/g' docker-compose.yaml
  sed -i '' 's/#     - nacos-net/    - nacos-net/g' docker-compose.yaml
  
  # 创建初始化脚本目录
  mkdir -p init.d
  
  echo "MySQL配置已启用，重启Nacos服务生效"
}

# 主函数
main() {
  case "$1" in
    start)
      start_nacos
      ;;
    stop)
      stop_nacos
      ;;
    restart)
      restart_nacos
      ;;
    status)
      check_status
      ;;
    logs)
      view_logs
      ;;
    build)
      build_image
      ;;
    console)
      open_console
      ;;
    mysql)
      enable_mysql
      ;;
    *)
      show_usage
      ;;
  esac
}

main "$@" 