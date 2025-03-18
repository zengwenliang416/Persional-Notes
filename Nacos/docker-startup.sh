#!/bin/bash

# 设置默认参数
MODE=${MODE:-standalone}
PREFER_HOST_MODE=${PREFER_HOST_MODE:-hostname}
NACOS_SERVER_PORT=${NACOS_SERVER_PORT:-8848}
NACOS_APPLICATION_PORT=${NACOS_APPLICATION_PORT:-8848}
JVM_XMS=${JVM_XMS:-1g}
JVM_XMX=${JVM_XMX:-1g}
JVM_XMN=${JVM_XMN:-512m}
JVM_MS=${JVM_MS:-128m}
JVM_MMS=${JVM_MMS:-320m}
NACOS_DEBUG=${NACOS_DEBUG:-n}

# 打印参数信息
echo "MODE: $MODE"
echo "PREFER_HOST_MODE: $PREFER_HOST_MODE"
echo "NACOS_SERVER_PORT: $NACOS_SERVER_PORT"
echo "NACOS_APPLICATION_PORT: $NACOS_APPLICATION_PORT"
echo "JVM_XMS: $JVM_XMS"
echo "JVM_XMX: $JVM_XMX"
echo "JVM_XMN: $JVM_XMN"
echo "JVM_MS: $JVM_MS"
echo "JVM_MMS: $JVM_MMS"
echo "NACOS_DEBUG: $NACOS_DEBUG"

# JVM参数配置
JAVA_OPT="${JAVA_OPT} -server -Xms${JVM_XMS} -Xmx${JVM_XMX} -Xmn${JVM_XMN} -XX:MetaspaceSize=${JVM_MS} -XX:MaxMetaspaceSize=${JVM_MMS}"
JAVA_OPT="${JAVA_OPT} -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/nacos/logs/java_heapdump.hprof"
JAVA_OPT="${JAVA_OPT} -XX:-UseLargePages"

# 数据库配置
if [[ "${NACOS_DATABASE:-}" == "mysql" ]]; then
  if [[ "${MYSQL_SERVICE_HOST:-}" == "" ]]; then
    echo "MySQL host is required when using MySQL database"
    exit 1
  fi
  
  if [[ "${MYSQL_SERVICE_PORT:-}" == "" ]]; then
    MYSQL_SERVICE_PORT=3306
  fi
  
  if [[ "${MYSQL_SERVICE_USER:-}" == "" ]]; then
    echo "MySQL username is required when using MySQL database"
    exit 1
  fi
  
  if [[ "${MYSQL_SERVICE_PASSWORD:-}" == "" ]]; then
    echo "MySQL password is required when using MySQL database"
    exit 1
  fi
  
  if [[ "${MYSQL_SERVICE_DB_NAME:-}" == "" ]]; then
    MYSQL_SERVICE_DB_NAME="nacos_config"
  fi
  
  JAVA_OPT="${JAVA_OPT} -Dspring.datasource.platform=mysql"
  JAVA_OPT="${JAVA_OPT} -Ddb.num=1"
  JAVA_OPT="${JAVA_OPT} -Ddb.url.0=jdbc:mysql://${MYSQL_SERVICE_HOST}:${MYSQL_SERVICE_PORT}/${MYSQL_SERVICE_DB_NAME}?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useSSL=false"
  JAVA_OPT="${JAVA_OPT} -Ddb.user=${MYSQL_SERVICE_USER}"
  JAVA_OPT="${JAVA_OPT} -Ddb.password=${MYSQL_SERVICE_PASSWORD}"
fi

# 集群配置
if [[ "${MODE}" == "cluster" ]]; then
  
  # 检查集群节点地址
  if [[ "${NACOS_SERVERS:-}" == "" ]]; then
    echo "nacos.servers is required in cluster mode"
    exit 1
  fi
  
  JAVA_OPT="${JAVA_OPT} -Dnacos.member.list=${NACOS_SERVERS}"
fi

# Nacos端口配置
JAVA_OPT="${JAVA_OPT} -Dserver.port=${NACOS_SERVER_PORT}"
JAVA_OPT="${JAVA_OPT} -Dnacos.server.ip=${NACOS_SERVER_IP}"

# Debug模式
if [[ "${NACOS_DEBUG}" == "y" ]]; then
  JAVA_OPT="${JAVA_OPT} -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8000"
fi

# 兼容性配置
JAVA_OPT="${JAVA_OPT} -Djava.ext.dirs=${JAVA_HOME}/jre/lib/ext:${JAVA_HOME}/lib/ext:${NACOS_HOME}/plugins/cmdb:${NACOS_HOME}/plugins/mysql"

# 打印启动命令
echo "Nacos is starting with command: "
echo "$JAVA_HOME/bin/java ${JAVA_OPT} -cp /nacos/plugins/cmdb/*.jar:/nacos/plugins/mysql/*.jar:/nacos/target/nacos-server.jar:/nacos/target/classes:/nacos/target/dependency/* nacos.nacos"

# 启动Nacos
exec $JAVA_HOME/bin/java ${JAVA_OPT} -cp /nacos/plugins/cmdb/*.jar:/nacos/plugins/mysql/*.jar:/nacos/target/nacos-server.jar:/nacos/target/classes:/nacos/target/dependency/* nacos.nacos 