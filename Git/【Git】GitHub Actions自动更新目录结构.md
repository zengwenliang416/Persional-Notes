# 【Git】GitHub Actions自动更新目录结构

本文档介绍如何使用 GitHub Actions 自动更新仓库 README.md 中的目录结构。

## 功能特点

1. 自动运行：每天 UTC 00:00 自动运行，也支持手动触发
2. 智能更新：只更新 README.md 中的目录结构部分，保持其他内容不变
3. PR 流程：通过 Pull Request 的方式提交更改，便于审查
4. 中文支持：完整支持中文文件名和目录名

## 工作流配置

### 1. 创建工作流文件

在仓库根目录创建 `.github/workflows/update-directory-tree.yml` 文件：

```yaml
name: 更新目录结构

on:
  schedule:
    - cron: '0 0 * * *'  # 每天 UTC 00:00 运行
  workflow_dispatch:  # 允许手动触发

jobs:
  update-directory-tree:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
        with:
          token: ${{ secrets.PAT_TOKEN }}  # 使用 PAT 进行 checkout
          fetch-depth: 1

      - name: Setup Git
        run: |
          git config --global user.email "github-actions[bot]@users.noreply.github.com"
          git config --global user.name "github-actions[bot]"

      - name: Install tree
        run: sudo apt-get install -y tree

      - name: Update Directory Structure
        run: |
          # 生成目录结构
          TREE_OUTPUT=$(tree -L 2 -I '.git|.github|node_modules' --charset=utf8)
          
          # 创建临时文件
          TEMP_FILE=$(mktemp)
          
          # 处理 README.md
          awk -v tree="$TREE_OUTPUT" -v date="$(TZ='Asia/Shanghai' date '+%Y年%m月%d日 %H:%M:%S')" '
          BEGIN { 
            in_tree = 0;
            found_tree = 0;
          }
          # 当找到目录结构标题时
          /^## 目录结构/ {
            if (!found_tree) {
              print $0;  # 打印标题
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
          # 当在目录结构部分时，跳过直到找到下一个标题或文件结束
          in_tree && /^##/ {
            in_tree = 0;
            print $0;
            next;
          }
          # 跳过目录结构部分的内容
          in_tree { next }
          # 打印其他所有内容
          { print $0 }
          # 如果没有找到目录结构部分，在文件末尾添加
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

      - name: Create Pull Request
        run: |
          # 检查是否有更改
          if [[ -n "$(git status --porcelain)" ]]; then
            # 获取当前时间作为分支名
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

### 2. 配置 Personal Access Token (PAT)

1. 访问 GitHub 设置页面：https://github.com/settings/tokens
2. 点击 "Generate new token (classic)"
3. 为 token 设置以下权限：
   - `repo` (完整的仓库访问权限)
   - `workflow` (工作流权限)
4. 生成并复制 token
5. 在仓库的 Settings -> Secrets and variables -> Actions 中添加名为 `PAT_TOKEN` 的 secret

### 3. 工作流说明

#### 触发条件
- 定时触发：每天 UTC 00:00 自动运行
- 手动触发：支持通过 GitHub Actions 页面手动触发

#### 工作流步骤

1. **检出代码**
   - 使用 PAT 进行身份验证
   - 获取仓库最新代码

2. **配置 Git**
   - 设置 Git 用户名和邮箱为 GitHub Actions 机器人

3. **安装工具**
   - 安装 `tree` 命令用于生成目录结构

4. **更新目录结构**
   - 使用 `tree` 命令生成目录结构
   - 使用 `awk` 脚本处理 README.md 文件：
     - 查找 "## 目录结构" 标题
     - 在原位置替换目录结构内容
     - 保持其他内容不变
     - 添加更新时间戳

5. **创建 Pull Request**
   - 检查是否有文件更改
   - 创建新分支
   - 提交更改
   - 创建 Pull Request

### 4. AWK 脚本说明

AWK 脚本的主要功能：

1. **状态标记**
   - `in_tree`：标记是否在目录结构部分内
   - `found_tree`：标记是否找到目录结构标题

2. **处理逻辑**
   - 找到目录结构标题时，插入新的目录结构
   - 跳过原有的目录结构内容
   - 遇到下一个标题时结束跳过
   - 如果没有找到目录结构，在文件末尾添加

3. **时间处理**
   - 使用 `TZ='Asia/Shanghai'` 确保时间戳使用中国时区

## 使用说明

1. 复制工作流文件到你的仓库
2. 配置 PAT
3. 确保 README.md 中有 "## 目录结构" 标题
4. 推送更改到 GitHub
5. 在 Actions 页面检查工作流运行状态

## 注意事项

1. PAT 权限必须正确配置
2. README.md 必须包含 "## 目录结构" 标题
3. 目录结构会被完整替换，包括标题到下一个二级标题之间的内容
4. 时区设置为中国时区，更新时间会显示为本地时间

## 常见问题

1. **工作流没有运行**
   - 检查 PAT 是否正确配置
   - 检查工作流文件语法是否正确

2. **目录结构没有更新**
   - 检查 README.md 中是否有 "## 目录结构" 标题
   - 检查 AWK 脚本是否正确处理文件编码

3. **PR 创建失败**
   - 检查 PAT 是否有足够的权限
   - 检查仓库的分支保护规则
