#!/bin/bash

# 默认配置项
DUMP_PATH="/tmp/jvm_dumps"
THREAD_MAX=120
INTERVAL=10

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -p <进程名>    指定要监控的Java进程名"
    echo "  -t <阈值>      设置线程数量阈值 (默认: 120)"
    echo "  -i <间隔>      设置检查间隔秒数 (默认: 10)"
    echo "  -d <目录>      设置转储文件保存目录 (默认: /tmp/jvm_dumps)"
    echo "  -h            显示此帮助信息"
}

# 解析命令行参数
while getopts "p:t:i:d:h" opt; do
    case $opt in
        p) TARGET_PID=$OPTARG ;;
        t) THREAD_MAX=$OPTARG ;;
        i) INTERVAL=$OPTARG ;;
        d) DUMP_PATH=$OPTARG ;;
        h) show_help; exit 0 ;;
        ?) show_help; exit 1 ;;
    esac
done

# 创建输出目录
mkdir -p "$DUMP_PATH"

# 如果没有指定进程，显示进程列表供选择
if [ -z "$TARGET_PID" ]; then
    echo "可用的Java进程列表："
    echo "------------------------"
    
    # 创建临时文件存储进程列表
    temp_file=$(mktemp)
    jps -l | grep -v "sun.tools.jps.Jps" > "$temp_file"
    
    # 显示进程列表
    cat -n "$temp_file"
    
    echo "------------------------"
    echo -n "请选择进程编号: "
    read -r selection
    
    # 获取总行数
    total_lines=$(wc -l < "$temp_file")
    
    # 验证输入
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "$total_lines" ]; then
        rm -f "$temp_file"
        echo "错误：无效的选择"
        exit 1
    fi
    
    # 获取选中进程的PID
    TARGET_PID=$(sed -n "${selection}p" "$temp_file" | awk '{print $1}')
    rm -f "$temp_file"
fi

if [ -z "$TARGET_PID" ]; then
    echo "错误：未选择有效的进程"
    exit 1
fi

echo "开始监控进程 $TARGET_PID"
echo "线程阈值：$THREAD_MAX"
echo "检查间隔：$INTERVAL 秒"
echo "转储目录：$DUMP_PATH"
echo "------------------------"

while true; do
    timestamp=$(date "+%Y%m%d_%H%M%S")
    
    # 检查进程是否存在
    if ! ps -p "$TARGET_PID" > /dev/null; then
        echo "进程 $TARGET_PID 已终止"
        exit 1
    fi
    
    # 获取线程数 (macOS 版本)
    thread_count=$(ps -M -p "$TARGET_PID" | grep -v "USER" | wc -l)
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 当前线程数: $thread_count"
    
    if [ "$thread_count" -gt "$THREAD_MAX" ]; then
        dump_file="$DUMP_PATH/threaddump_${TARGET_PID}_${timestamp}.txt"
        echo "线程数超过阈值，生成转储文件: $dump_file"
        jstack "$TARGET_PID" > "$dump_file" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "转储文件已生成"
        else
            echo "生成转储文件失败"
        fi
    fi
    
    sleep "$INTERVAL"
done