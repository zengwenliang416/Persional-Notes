#!/bin/bash
# NebulaGraph 统一管理脚本
# 用法: ./nebula.sh [start|stop|restart|status|console]

# 显示使用帮助
show_usage() {
  echo "NebulaGraph 管理脚本"
  echo "用法: $0 [选项]"
  echo "选项:"
  echo "  start    - 启动NebulaGraph服务和Studio"
  echo "  stop     - 停止所有服务"
  echo "  restart  - 重启所有服务"
  echo "  status   - 查看服务状态"
  echo "  console  - 连接到NebulaGraph控制台"
  echo "  studio   - 仅启动Studio管理界面"
  echo "  core     - 仅启动NebulaGraph核心服务"
}

# 启动NebulaGraph核心服务
start_core() {
  echo "启动NebulaGraph核心服务..."
  
  # 创建自定义网络
  docker network create nebula-net 2>/dev/null || true
  
  # 创建数据目录
  mkdir -p ./data/meta{0,1,2} ./data/storage{0,1,2} ./logs/meta{0,1,2} ./logs/storage{0,1,2} ./logs/graph
  
  # 启动metad服务
  docker run -d --name metad0 --network=nebula-net \
    -p 9559:9559 -p 19559:19559 \
    -v $PWD/data/meta0:/data/meta \
    -v $PWD/logs/meta0:/logs \
    -e TZ=Asia/Shanghai \
    --cap-add=SYS_PTRACE \
    vesoft/nebula-metad:v3.8.0 \
    --meta_server_addrs=metad0:9559,metad1:9559,metad2:9559 \
    --local_ip=metad0 --ws_ip=metad0 --port=9559 --ws_http_port=19559 \
    --data_path=/data/meta --log_dir=/logs --v=0 --minloglevel=0
  
  docker run -d --name metad1 --network=nebula-net \
    -v $PWD/data/meta1:/data/meta \
    -v $PWD/logs/meta1:/logs \
    -e TZ=Asia/Shanghai \
    --cap-add=SYS_PTRACE \
    vesoft/nebula-metad:v3.8.0 \
    --meta_server_addrs=metad0:9559,metad1:9559,metad2:9559 \
    --local_ip=metad1 --ws_ip=metad1 --port=9559 --ws_http_port=19559 \
    --data_path=/data/meta --log_dir=/logs --v=0 --minloglevel=0
  
  docker run -d --name metad2 --network=nebula-net \
    -v $PWD/data/meta2:/data/meta \
    -v $PWD/logs/meta2:/logs \
    -e TZ=Asia/Shanghai \
    --cap-add=SYS_PTRACE \
    vesoft/nebula-metad:v3.8.0 \
    --meta_server_addrs=metad0:9559,metad1:9559,metad2:9559 \
    --local_ip=metad2 --ws_ip=metad2 --port=9559 --ws_http_port=19559 \
    --data_path=/data/meta --log_dir=/logs --v=0 --minloglevel=0
  
  # 等待meta服务启动
  echo "等待meta服务启动..."
  sleep 10
  
  # 启动storaged服务
  docker run -d --name storaged0 --network=nebula-net \
    -p 9779:9779 -p 19779:19779 \
    -v $PWD/data/storage0:/data/storage \
    -v $PWD/logs/storage0:/logs \
    -e TZ=Asia/Shanghai \
    --cap-add=SYS_PTRACE \
    vesoft/nebula-storaged:v3.8.0 \
    --meta_server_addrs=metad0:9559,metad1:9559,metad2:9559 \
    --local_ip=storaged0 --ws_ip=storaged0 --port=9779 --ws_http_port=19779 \
    --data_path=/data/storage --log_dir=/logs --v=0 --minloglevel=0
  
  docker run -d --name storaged1 --network=nebula-net \
    -v $PWD/data/storage1:/data/storage \
    -v $PWD/logs/storage1:/logs \
    -e TZ=Asia/Shanghai \
    --cap-add=SYS_PTRACE \
    vesoft/nebula-storaged:v3.8.0 \
    --meta_server_addrs=metad0:9559,metad1:9559,metad2:9559 \
    --local_ip=storaged1 --ws_ip=storaged1 --port=9779 --ws_http_port=19779 \
    --data_path=/data/storage --log_dir=/logs --v=0 --minloglevel=0
  
  docker run -d --name storaged2 --network=nebula-net \
    -v $PWD/data/storage2:/data/storage \
    -v $PWD/logs/storage2:/logs \
    -e TZ=Asia/Shanghai \
    --cap-add=SYS_PTRACE \
    vesoft/nebula-storaged:v3.8.0 \
    --meta_server_addrs=metad0:9559,metad1:9559,metad2:9559 \
    --local_ip=storaged2 --ws_ip=storaged2 --port=9779 --ws_http_port=19779 \
    --data_path=/data/storage --log_dir=/logs --v=0 --minloglevel=0
  
  # 启动graphd服务
  docker run -d --name graphd --network=nebula-net \
    -p 9669:9669 -p 19669:19669 \
    -v $PWD/logs/graph:/logs \
    -e TZ=Asia/Shanghai \
    --cap-add=SYS_PTRACE \
    vesoft/nebula-graphd:v3.8.0 \
    --meta_server_addrs=metad0:9559,metad1:9559,metad2:9559 \
    --local_ip=graphd --ws_ip=graphd --port=9669 --ws_http_port=19669 \
    --log_dir=/logs --v=0 --minloglevel=0
  
  # 等待服务启动
  echo "等待服务启动..."
  sleep 20
  
  # 添加存储主机
  echo "添加存储主机..."
  docker run --rm -it --network=nebula-net \
    vesoft/nebula-console:v3.8.0 \
    -addr graphd -port 9669 -u root -p nebula \
    -e 'ADD HOSTS "storaged0":9779,"storaged1":9779,"storaged2":9779'
  
  echo "NebulaGraph核心服务已启动"
}

# 启动NebulaGraph Studio
start_studio() {
  echo "启动NebulaGraph Studio管理界面..."
  
  # 确保网络存在
  docker network create nebula-net 2>/dev/null || true
  
  # 启动Studio
  docker run -d --name nebula-studio \
    --network=nebula-net \
    -p 7001:7001 \
    vesoft/nebula-graph-studio:v3.10.0
  
  echo "NebulaGraph Studio已启动，请访问 http://localhost:7001"
  echo "连接信息:"
  echo "  主机: graphd"
  echo "  端口: 9669"
  echo "  用户名: root"
  echo "  密码: nebula"
}

# 停止NebulaGraph核心服务
stop_core() {
  echo "停止NebulaGraph核心服务..."
  docker stop graphd storaged0 storaged1 storaged2 metad0 metad1 metad2 2>/dev/null || true
  docker rm graphd storaged0 storaged1 storaged2 metad0 metad1 metad2 2>/dev/null || true
  echo "NebulaGraph核心服务已停止"
}

# 停止NebulaGraph Studio
stop_studio() {
  echo "停止NebulaGraph Studio..."
  docker stop nebula-studio 2>/dev/null || true
  docker rm nebula-studio 2>/dev/null || true
  echo "NebulaGraph Studio已停止"
}

# 查看服务状态
show_status() {
  echo "NebulaGraph服务状态:"
  docker ps -a --filter "name=metad" --filter "name=storaged" --filter "name=graphd" --filter "name=nebula-studio"
}

# 连接到NebulaGraph控制台
connect_console() {
  echo "连接到NebulaGraph控制台..."
  docker run --rm -it --network=nebula-net \
    vesoft/nebula-console:v3.8.0 \
    -addr graphd -port 9669 -u root -p nebula
}

# 主函数
main() {
  case "$1" in
    start)
      stop_core
      stop_studio
      start_core
      start_studio
      show_status
      ;;
    stop)
      stop_studio
      stop_core
      ;;
    restart)
      stop_studio
      stop_core
      start_core
      start_studio
      show_status
      ;;
    status)
      show_status
      ;;
    console)
      connect_console
      ;;
    studio)
      stop_studio
      start_studio
      ;;
    core)
      stop_core
      start_core
      ;;
    *)
      show_usage
      ;;
  esac
}

main "$@" 