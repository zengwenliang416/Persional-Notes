# 【Git】基础命令指南

## 一、Git 基本概念

Git 是一个分布式版本控制系统，用于跟踪文件的变化。以下是一些核心概念：

1. **工作区（Working Directory）**：
   - 实际操作的目录
   - 包含项目的实际文件

2. **暂存区（Staging Area）**：
   - 临时存储要提交的文件修改
   - 位于 .git 目录下的 index 文件

3. **本地仓库（Local Repository）**：
   - 存储项目的所有版本信息
   - 位于 .git 目录

4. **远程仓库（Remote Repository）**：
   - 位于远程服务器的仓库
   - 用于多人协作

## 二、基础配置

### 1. 全局配置

```bash
# 设置用户名和邮箱
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 设置默认编辑器
git config --global core.editor vim

# 查看所有配置
git config --list

# 设置 Git 使用的代理
git config --global http.proxy http://proxy.example.com:8080
git config --global https.proxy https://proxy.example.com:8080
```

### 2. 仓库配置

```bash
# 初始化新仓库
git init

# 克隆远程仓库
git clone <repository-url>
git clone <repository-url> <directory>

# 添加远程仓库
git remote add origin <repository-url>

# 查看远程仓库
git remote -v
```

## 三、基本操作

### 1. 文件操作

```bash
# 查看文件状态
git status
git status -s  # 简短格式

# 添加文件到暂存区
git add <file>          # 添加指定文件
git add .               # 添加所有文件
git add *.js           # 添加所有 JS 文件
git add src/           # 添加整个目录

# 提交更改
git commit -m "commit message"
git commit -am "commit message"  # 自动添加已跟踪的文件并提交

# 移除文件
git rm <file>          # 从工作区和暂存区删除
git rm --cached <file> # 仅从暂存区删除

# 移动/重命名文件
git mv <old-name> <new-name>
```

### 2. 查看历史

```bash
# 查看提交历史
git log
git log --oneline      # 简短格式
git log --graph        # 图形化显示
git log -p            # 显示详细差异
git log -n <number>   # 显示最近 n 次提交

# 查看特定提交
git show <commit-id>

# 查看文件改动
git diff              # 工作区与暂存区的差异
git diff --staged     # 暂存区与最新提交的差异
git diff <commit-id>  # 与指定提交的差异
```

## 四、分支操作

### 1. 基本分支操作

```bash
# 查看分支
git branch            # 列出本地分支
git branch -r         # 列出远程分支
git branch -a         # 列出所有分支

# 创建分支
git branch <branch-name>
git checkout -b <branch-name>  # 创建并切换到新分支

# 切换分支
git checkout <branch-name>
git switch <branch-name>      # Git 2.23+ 新命令

# 删除分支
git branch -d <branch-name>   # 删除已合并的分支
git branch -D <branch-name>   # 强制删除分支
```

### 2. 合并操作

```bash
# 合并分支
git merge <branch-name>       # 合并指定分支到当前分支
git merge --no-ff <branch>    # 禁用快进合并

# 变基
git rebase <branch-name>      # 将当前分支变基到指定分支

# 解决冲突
git status                    # 查看冲突文件
git add <file>               # 标记冲突已解决
git merge --continue         # 继续合并
git merge --abort           # 取消合并
```

## 五、远程操作

### 1. 远程仓库管理

```bash
# 查看远程仓库
git remote
git remote -v               # 显示详细信息

# 添加远程仓库
git remote add <name> <url>

# 删除远程仓库
git remote remove <name>

# 重命名远程仓库
git remote rename <old-name> <new-name>
```

### 2. 推送和拉取

```bash
# 推送到远程
git push <remote> <branch>
git push -u origin master   # 设置上游分支并推送
git push --force           # 强制推送（慎用）

# 拉取更新
git fetch <remote>         # 获取远程更新但不合并
git pull <remote> <branch> # 获取远程更新并合并
git pull --rebase         # 使用变基方式拉取
```

## 六、高级操作

### 1. 储藏（Stash）

```bash
# 储藏更改
git stash                  # 储藏所有更改
git stash save "message"   # 储藏并添加说明
git stash -u              # 包含未跟踪的文件

# 管理储藏
git stash list            # 查看储藏列表
git stash apply stash@{n} # 应用指定储藏
git stash pop            # 应用并删除最近的储藏
git stash drop stash@{n} # 删除指定储藏
git stash clear         # 清除所有储藏
```

### 2. 撤销操作

```bash
# 撤销工作区修改
git checkout -- <file>    # 撤销指定文件的修改
git restore <file>        # Git 2.23+ 新命令

# 撤销暂存区修改
git reset HEAD <file>     # 将文件从暂存区移出
git restore --staged <file> # Git 2.23+ 新命令

# 撤销提交
git reset --soft HEAD^    # 撤销最近一次提交，保留更改
git reset --hard HEAD^    # 撤销最近一次提交，丢弃更改
git revert <commit-id>    # 创建新提交来撤销指定提交
```

### 3. 标签管理

```bash
# 创建标签
git tag <tag-name>                # 创建轻量标签
git tag -a <tag-name> -m "message" # 创建附注标签

# 查看标签
git tag                          # 列出所有标签
git show <tag-name>              # 查看标签信息

# 推送标签
git push origin <tag-name>       # 推送指定标签
git push origin --tags          # 推送所有标签

# 删除标签
git tag -d <tag-name>           # 删除本地标签
git push origin :refs/tags/<tag-name> # 删除远程标签
```

## 七、最佳实践

1. **提交信息规范**：
   - 使用清晰、描述性的提交信息
   - 遵循团队的提交信息格式
   - 包含相关的 issue 或 ticket 编号

2. **分支管理策略**：
   - 主分支保持稳定
   - 使用特性分支进行开发
   - 定期同步主分支的更新

3. **合并策略**：
   - 优先使用 `merge --no-ff`
   - 重要分支考虑使用 `rebase`
   - 解决冲突时仔细检查

4. **代码审查**：
   - 提交前自查
   - 使用 Pull Request 进行团队审查
   - 及时响应审查意见

## 八、常见问题与解决

1. **解决合并冲突**：
```bash
# 发生冲突时
git status              # 查看冲突文件
# 手动编辑解决冲突
git add <resolved-files>
git commit -m "resolve conflicts"
```

2. **撤销误操作**：
```bash
# 撤销本地提交
git reset --soft HEAD^  # 保留更改
git reset --hard HEAD^  # 丢弃更改

# 撤销已推送的提交
git revert <commit-id>
```

3. **清理仓库**：
```bash
# 清理未跟踪的文件
git clean -n           # 预览要清理的文件
git clean -f           # 强制清理文件
git clean -fd          # 清理文件和目录
```
