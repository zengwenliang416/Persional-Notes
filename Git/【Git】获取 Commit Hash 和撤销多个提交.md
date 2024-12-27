# 【Git】获取 Commit Hash 和撤销多个提交

## 目录

[1. 获取 Commit Hash](#获取-commit-hash)

- [1.1 使用 git log 命令](#使用-git-log-命令)

- [1.2 使用简化的 git log 命令](#使用简化的-git-log-命令)

- [1.3 查看特定分支的提交历史](#查看特定分支的提交历史)

- [1.4 查看最近的 N 个提交](#查看最近的-n-个提交)

- [1.5 使用图形化界面](#使用图形化界面)

- [1.6 在 GitHub/GitLab 等网页界面查看](#在-githubgitlab-等网页界面查看)

[2. 使用 Git Reset 撤销提交](#使用-git-reset-撤销提交)

- [2.1 重置到指定提交](#重置到指定提交)

- [2.2 强制推送到远程（如需同步）](#强制推送到远程如需同步)

[3. 使用 Git Revert 撤销提交](#使用-git-revert-撤销提交)

- [3.1 逆序撤销多个提交](#逆序撤销多个提交)

- [3.2 推送更改到远程](#推送更改到远程)

[4. 注意事项和最佳实践](#注意事项和最佳实践)

- [4.1 备份本地分支](#备份本地分支)

- [4.2 与团队沟通](#与团队沟通)

- [4.3 检查权限](#检查权限)

- [4.4 仔细检查 commit hash](#仔细检查-commit-hash)

- [4.5 使用部分 commit hash](#使用部分-commit-hash)

- [4.6 理解 reset 和 revert 的区别](#理解-reset-和-revert-的区别)

- [4.7 定期同步和更新](#定期同步和更新)

- [4.8 注意完整性](#注意完整性)



## 获取 Commit Hash

在撤销提交之前，你需要知道要撤销到哪个提交。以下是获取 commit hash 的几种方法：

### 使用 git log 命令
```bash
git log
```
这会显示完整的提交历史，包括完整的 commit hash、作者、日期和提交信息。

输出示例：
```
commit a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9
Author: Your Name <your.email@example.com>
Date:   Mon Jan 1 12:00:00 2023 +0000

    Your commit message

commit 1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s
Author: Your Name <your.email@example.com>
Date:   Sun Dec 31 23:59:59 2022 +0000

    Another commit message
```

### 使用简化的 git log 命令
```bash
git log --oneline
```
这会显示简短的 commit hash 和提交信息，更加简洁。

输出示例：
```
a1b2c3d Your commit message
1a2b3c4 Another commit message
```

### 查看特定分支的提交历史
```bash
git log <branch-name>
```

### 查看最近的 N 个提交
```bash
git log -n 5  # 显示最近的 5 个提交
```

### 使用图形化界面
如果你使用 Git 图形化界面工具（如 GitKraken, SourceTree 等），你可以在提交历史视图中直接看到并复制 commit hash。

### 在 GitHub/GitLab 等网页界面查看
如果你的项目托管在 GitHub, GitLab 等平台上，你可以在网页界面的提交历史中查看和复制 commit hash。

## 使用 Git Reset 撤销提交

Git reset 会改变提交历史，适用于本地分支或确保其他人没有基于这些提交进行工作的情况。

### 重置到指定提交
```bash
git reset --hard <commit-hash>
```

### 强制推送到远程（如需同步）
```bash
git push origin <branch-name> --force
```

## 使用 Git Revert 撤销提交

Git revert 通过创建新的提交来撤销指定的更改，不改变提交历史，适合在团队合作中使用。

### 逆序撤销多个提交
```bash
git revert <commit-hash1> <commit-hash2> ... <commit-hashN>
```

### 推送更改到远程
```bash
git push origin <branch-name>
```

## 注意事项和最佳实践

### 备份本地分支
在执行撤销操作之前，创建一个备份分支：
```bash
git branch backup-branch
```

### 与团队沟通
如果在团队项目中操作，提前通知团队成员以避免影响他们的工作。

### 检查权限
确保你有权限执行强制推送等操作。

### 仔细检查 commit hash
在使用 `git reset` 或 `git revert` 时，确保使用正确的 commit hash。

### 使用部分 commit hash
通常使用 commit hash 的前 7-8 个字符就足够唯一标识一个提交。

### 理解 reset 和 revert 的区别
- `git reset` 改变提交历史，适合本地分支。
- `git revert` 创建新提交来撤销更改，适合共享分支。

### 定期同步和更新

在执行重要操作前，确保你的本地仓库是最新的：
```bash
git fetch
git pull
```

### 注意完整性
- 完整的 commit hash 很长，通常使用前 7-8 个字符就足够唯一标识一个提交。
- 在使用 `git reset` 或 `git revert` 时，确保你使用的是正确的 commit hash。
- 如果你不确定要使用哪个 commit hash，可以先用 `git log` 仔细查看提交历史和相应的更改。
