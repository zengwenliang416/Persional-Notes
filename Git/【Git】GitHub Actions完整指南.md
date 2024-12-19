# 【Git】GitHub Actions 完整指南

## 目录
- [1. 目录](#目录)
- [2. 功能概述](#功能概述)
    - [2.1 主要特点](#主要特点)
- [3. 工作流配置文件](#工作流配置文件)
    - [3.1 完整配置文件](#完整配置文件)
    - [3.2 配置文件解析](#配置文件解析)
        - [    触发条件](#触发条件)
        - [    运行环境和权限](#运行环境和权限)
        - [    工作步骤](#工作步骤)
- [4. 使用指南](#使用指南)
    - [4.1 初始设置](#初始设置)
    - [4.2 日常使用](#日常使用)
- [5. 注意事项和最佳实践](#注意事项和最佳实践)
    - [5.1 权限管理](#权限管理)
    - [5.2 文件处理](#文件处理)
    - [5.3 Git 操作](#git-操作)
    - [5.4 性能优化](#性能优化)
- [6. 故障排查](#故障排查)
    - [6.1 常见问题](#常见问题)
    - [6.2 解决方案](#解决方案)
- [7. 扩展建议](#扩展建议)
    - [7.1 功能扩展](#功能扩展)
    - [7.2 配置优化](#配置优化)
    - [7.3 安全加强](#安全加强)
- [8. 结语](#结语)



## 功能概述

### 主要特点

1. **自动运行**
   - 每天 UTC 00:00 自动运行
   - 支持手动触发
   - 监听 master 分支推送事件

2. **智能更新**
   - 只更新 README.md 中的目录结构部分
   - 保持其他内容不变
   - 自动添加更新时间戳

3. **版本控制**
   - 通过 Pull Request 提交更改
   - 自动创建新分支
   - 规范的提交信息

4. **中文支持**
   - 完整支持中文文件名和目录名
   - 正确处理文件编码
   - 使用中国时区时间戳

## 工作流配置文件

### 完整配置文件

```yaml
name: 更新目录结构

on:
  schedule:
    - cron: '0 0 * * *'  # 每天 UTC 00:00 运行
  workflow_dispatch:      # 允许手动触发
  push:
    branches:
      - master           # 监听 master 分支上的推送事件

jobs:
  update-directory-tree:
    runs-on: ubuntu-latest    # 运行环境
    permissions:              # 权限设置
      contents: write         # 仓库内容写入权限
      pull-requests: write    # PR 创建权限
    
    steps:
      # 步骤1：检出代码
      - name: Checkout repository
        uses: actions/checkout@v3
        with:
          token: ${{ secrets.PAT_TOKEN }}  # 使用 PAT 进行认证
          fetch-depth: 1                    # 仅获取最新的提交

      # 步骤2：配置 Git
      - name: Setup Git
        run: |
          git config --global user.email "github-actions[bot]@users.noreply.github.com"
          git config --global user.name "github-actions[bot]"

      # 步骤3：安装 tree 命令
      - name: Install tree
        run: sudo apt-get install -y tree

      # 步骤4：更新目录结构
      - name: Update Directory Structure
        run: |
          # 生成目录结构
          TREE_OUTPUT=$(tree -L 2 -I '.git|.github|node_modules' --charset=utf8)
          
          # 创建临时文件
          TEMP_FILE=$(mktemp)
          
          # 使用 awk 处理 README.md
          awk -v tree="$TREE_OUTPUT" -v date="$(TZ='Asia/Shanghai' date '+%Y年%m月%d日 %H:%M:%S')" '
          BEGIN { 
            in_tree = 0;
            found_tree = 0;
          }
          /^## 目录结构/ {
            if (!found_tree) {
              print $0;
              print "最后更新时间：" date;
              print "";
              print "```";
              print tree;
              print "```";
              found_tree = 1;
              in_tree = 1;
              next;
            }
          }
          in_tree && /^##/ {
            in_tree = 0;
            print $0;
            next;
          }
          in_tree { next }
          { print $0 }
          END {
            if (!found_tree) {
              print "\n## 目录结构";
              print "最后更新时间：" date;
              print "";
              print "```";
              print tree;
              print "```";
            }
          }
          ' README.md > "$TEMP_FILE"
          
          # 替换原文件
          mv "$TEMP_FILE" README.md

      # 步骤5：创建 Pull Request
      - name: Create Pull Request
        run: |
          # 检查是否有更改
          if [[ -n "$(git status --porcelain)" ]]; then
            # 创建分支名
            BRANCH_NAME="directory-tree-updates-$(TZ='Asia/Shanghai' date +%Y%m%d-%H%M%S)"
            
            # 创建新分支
            git checkout -b "$BRANCH_NAME"
            
            # 提交更改
            git add README.md
            git commit -m "docs: 更新目录结构
            
            - 更新时间：$(TZ='Asia/Shanghai' date '+%Y年%m月%d日 %H:%M:%S')
            - 由 GitHub Actions 自动创建"
            
            # 推送到远程
            git push origin "$BRANCH_NAME"
            
            # 创建 PR
            gh pr create \
              --title "docs: 自动更新目录结构" \
              --body "自动更新 README.md 中的目录结构
              
              - 更新时间：$(TZ='Asia/Shanghai' date '+%Y年%m月%d日 %H:%M:%S')
              - 由 GitHub Actions 自动创建" \
              --base master \
              --head "$BRANCH_NAME"
          else
            echo "No changes to commit"
          fi
        env:
          GITHUB_TOKEN: ${{ secrets.PAT_TOKEN }}
```

### 配置文件解析

#### 触发条件
```yaml
on:
  schedule:
    - cron: '0 0 * * *'  # 定时触发
  workflow_dispatch:      # 手动触发
  push:
    branches:
      - master           # 推送触发
```
- `schedule`: 使用 cron 表达式设置定时
- `workflow_dispatch`: 允许在 Actions 页面手动触发
- `push`: 监听指定分支的推送事件

#### 运行环境和权限
```yaml
jobs:
  update-directory-tree:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
```
- 指定 Ubuntu 最新版本作为运行环境
- 设置必要的仓库权限

#### 工作步骤
每个步骤都有特定的功能：
1. 检出代码：获取仓库代码
2. 配置 Git：设置用户信息
3. 安装工具：安装必要的命令行工具
4. 更新目录：生成和更新目录结构
5. 创建 PR：提交更改并创建拉取请求

## 使用指南

### 初始设置

1. **配置 Personal Access Token (PAT)**
   - 访问 GitHub 设置页面
   - 生成新的 PAT
   - 设置必要权限
   - 添加到仓库 Secrets

2. **准备 README.md**
   - 确保包含 "## 目录结构" 标题
   - 检查文件编码为 UTF-8

3. **创建工作流文件**
   - 在 `.github/workflows/` 目录下创建配置文件
   - 复制并调整配置内容

### 日常使用

1. **查看运行状态**
   - 访问仓库的 Actions 页面
   - 检查工作流运行历史
   - 查看详细日志

2. **手动触发更新**
   - 打开 Actions 页面
   - 选择工作流
   - 点击 "Run workflow"

3. **管理 Pull Requests**
   - 审查自动创建的 PR
   - 检查目录结构更新
   - 合并或关闭 PR

## 注意事项和最佳实践

### 权限管理
- 使用最小权限原则
- 定期更新 PAT
- 检查仓库权限设置

### 文件处理
- 保持 README.md 格式规范
- 正确处理文件编码
- 注意临时文件安全

### Git 操作
- 遵循分支命名规范
- 使用规范的提交信息
- 注意冲突处理

### 性能优化
- 使用浅克隆
- 排除不必要的目录
- 合理设置目录树深度

## 故障排查

### 常见问题

1. **工作流未触发**
   - 检查 PAT 配置
   - 验证触发条件
   - 查看权限设置

2. **目录更新失败**
   - 检查 README.md 格式
   - 验证 tree 命令
   - 检查文件编码

3. **PR 创建失败**
   - 验证 PAT 权限
   - 检查分支设置
   - 查看错误日志

### 解决方案

1. **权限问题**
   - 更新 PAT
   - 检查权限范围
   - 验证仓库设置

2. **文件问题**
   - 修复文件格式
   - 更正编码设置
   - 检查文件权限

3. **Git 问题**
   - 清理冲突分支
   - 重置 Git 配置
   - 更新工作流配置

## 扩展建议

### 功能扩展
- 添加更多自动化任务
- 集成其他工具
- 扩展通知功能

### 配置优化
- 参数配置化
- 添加条件判断
- 优化错误处理

### 安全加强
- 加强权限控制
- 改进错误处理
- 添加安全检查

## 结语

这个 GitHub Actions 工作流提供了一个自动化的解决方案，用于维护仓库的目录结构。通过合理的配置和使用，可以大大减少手动维护工作，提高效率。记得定期检查和更新配置，确保工作流持续有效运行。
