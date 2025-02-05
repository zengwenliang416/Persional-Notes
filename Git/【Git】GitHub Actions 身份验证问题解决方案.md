# GitHub Actions 身份验证问题解决方案

## 问题描述

在使用 GitHub Actions 时遇到以下错误：

```bash
Error: fatal: could not read Username for 'https://github.com': terminal prompts disabled
The process '/usr/bin/git' failed with exit code 128
```

这个错误通常出现在 GitHub Actions 工作流程中，当尝试执行 git 操作（如 clone、fetch 等）时，由于身份验证问题而无法访问仓库。

## 错误原因

这个错误主常见的原因包括：

1. Personal Access Token (PAT) 未正确配置在仓库的 Secrets 中
2. Token 已过期
3. Token 权限范围不足
4. 工作流配置文件中的 token 使用方式不正确

## 解决方案

### 1. 创建新的 Personal Access Token (PAT)

1. 访问 GitHub 个人设置：
   - 点击右上角头像
   - 选择 Settings
   - 进入 Developer settings
   - 选择 Personal access tokens -> Tokens (classic)

2. 生成新的 Token：
   - 点击 "Generate new token (classic)"
   - 设置适当的权限范围：
     - `repo` (完整的仓库访问权限)
     - `workflow` (如果需要管理 GitHub Actions)
   - 设置合理的过期时间
   - 生成并保存 token（注意：token 只会显示一次）

### 2. 配置仓库 Secrets

1. 进入仓库设置：
   - 访问仓库的 Settings 标签
   - 点击 "Secrets and variables" -> "Actions"
   - 选择 "New repository secret"

2. 添加 Secret：
   - Name: `PAT_TOKEN`
   - Value: 粘贴刚才生成的 token
   - 点击 "Add secret"

### 3. 在工作流配置中使用 Token

在 `.github/workflows/your-workflow.yml` 文件中正确使用 token：

```yaml
- name: Checkout repository
  uses: actions/checkout@v3
  with:
    token: ${{ secrets.PAT_TOKEN }}
    fetch-depth: 0  # 如果需要完整的提交历史
```

### 4. 验证解决方案

1. 访问仓库的 "Actions" 标签页
2. 找到失败的工作流
3. 点击 "Re-run all jobs" 重新运行工作流
4. 检查是否还有认证错误

## 注意事项

1. **安全性**：
   - 永远不要直接在代码中硬编码 token
   - 不要分享你的 Personal Access Token
   - 定期轮换 token 以提高安全性

2. **权限管理**：
   - 只授予必要的最小权限
   - 定期审查 token 的权限设置

3. **维护**：
   - 记录 token 的过期时间
   - 在 token 过期前更新
   - 定期检查工作流的运行状态

## 相关链接

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Personal Access Tokens 文档](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [GitHub Actions 安全最佳实践](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions) 