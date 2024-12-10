#!/bin/bash

# 设置错误时退出
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 提交类型数组
declare -a commit_types=(
    "feat: ✨ 新功能"
    "fix: 🐛 修复bug"
    "docs: 📝 文档更新"
    "style: 💄 代码格式"
    "refactor: ♻️ 代码重构"
    "perf: ⚡️ 性能优化"
    "test: ✅ 测试相关"
    "build: 📦 构建相关"
    "ci: 👷 CI/CD相关"
    "chore: 🔧 其他更改"
    "custom: 🎨 自定义格式"
)

# 表情数组
declare -a emojis=(
    "✨ - 新功能"
    "🐛 - Bug修复"
    "📝 - 文档"
    "💄 - 样式"
    "♻️ - 重构"
    "⚡️ - 性能"
    "✅ - 测试"
    "📦 - 构建"
    "👷 - CI/CD"
    "🔧 - 工具"
    "🎨 - 格式"
    "🚀 - 部署"
    "🆕 - 新增"
    "🔨 - 更新"
    "🗑️ - 删除"
    "🔀 - 合并"
    "🔖 - 版本"
    "🔒 - 安全"
)

# 检查是否在git仓库中
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}错误: 当前目录不是git仓库${NC}"
    exit 1
fi

# 获取当前分支
current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

# 检查是否有未提交的更改
if [ -z "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}没有发现需要提交的更改${NC}"
    read -p "是否继续? (y/n): " continue
    if [ "$continue" != "y" ]; then
        echo "操作已取消"
        exit 0
    fi
fi

# 显示git状态
echo -e "${YELLOW}当前Git状态:${NC}"
git status -s

# 选择提交方式
echo -e "\n${YELLOW}请选择提交方式:${NC}"
echo "1. 提交所有更改 (git add .)"
echo "2. 交互式选择文件 (git add -p)"
echo "3. 手动输入文件路径"
read -p "请选择 (1-3): " choice

case $choice in
    1)
        echo -e "\n${YELLOW}添加所有文件...${NC}"
        git add .
        ;;
    2)
        echo -e "\n${YELLOW}开始交互式选择...${NC}"
        git add -p
        ;;
    3)
        echo -e "\n${YELLOW}请输入要添加的文件路径（多个文件用空格分隔）:${NC}"
        read -e files
        if [ ! -z "$files" ]; then
            git add $files
        else
            echo -e "${RED}未指定任何文件${NC}"
            exit 1
        fi
        ;;
    *)
        echo -e "${RED}无效的选择${NC}"
        exit 1
        ;;
esac

# 显示已暂存的更改
echo -e "\n${YELLOW}已暂存的更改:${NC}"
git status -s

# 选择提交信息类型
echo -e "\n${YELLOW}请选择提交类型:${NC}"
for i in "${!commit_types[@]}"; do
    echo "$((i+1)). ${commit_types[$i]}"
done
read -p "请选择 (1-${#commit_types[@]}): " type_choice

if [ "$type_choice" -ge 1 ] && [ "$type_choice" -le ${#commit_types[@]} ]; then
    selected_type=${commit_types[$((type_choice-1))]}
else
    echo -e "${RED}无效的选择${NC}"
    exit 1
fi

# 如果选择自定义格式
if [[ "$selected_type" == "custom: "* ]]; then
    # 显示表情列表
    echo -e "\n${YELLOW}请选择表情:${NC}"
    for i in "${!emojis[@]}"; do
        echo "$((i+1)). ${emojis[$i]}"
    done
    read -p "请选择表情 (1-${#emojis[@]}, 直接回车跳过): " emoji_choice
    
    if [ ! -z "$emoji_choice" ] && [ "$emoji_choice" -ge 1 ] && [ "$emoji_choice" -le ${#emojis[@]} ]; then
        selected_emoji=$(echo "${emojis[$((emoji_choice-1))]}" | cut -d' ' -f1)
    fi
    
    read -p "请输入自定义提交类型: " custom_type
    if [ ! -z "$custom_type" ]; then
        if [ ! -z "$selected_emoji" ]; then
            commit_prefix="$custom_type: $selected_emoji"
        else
            commit_prefix="$custom_type:"
        fi
    else
        echo -e "${RED}提交类型不能为空${NC}"
        exit 1
    fi
else
    commit_prefix=$(echo "$selected_type" | cut -d' ' -f1,2)
fi

# 获取提交信息
read -p "请输入提交描述: " commit_desc
if [ -z "$commit_desc" ]; then
    echo -e "${RED}提交描述不能为空${NC}"
    exit 1
fi

# 组合完整的提交信息
message="$commit_prefix $commit_desc"

# 获取分支名称
read -p "请输入分支名称 (默认是 $current_branch): " branch
branch=${branch:-$current_branch}

echo -e "\n${YELLOW}即将执行以下操作:${NC}"
echo "1. git commit -m \"$message\""
echo "2. git push origin $branch"

read -p "确认执行? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo "操作已取消"
    exit 0
fi

# 执行git命令
echo -e "\n${YELLOW}正在执行git操作...${NC}"

echo -e "\n${YELLOW}1. 提交更改...${NC}"
git commit -m "$message"

echo -e "\n${YELLOW}2. 推送到远程...${NC}"
if git push origin "$branch"; then
    echo -e "\n${GREEN}所有操作已成功完成！${NC}"
else
    echo -e "\n${RED}推送失败，请检查网络连接或远程仓库状态${NC}"
    exit 1
fi
