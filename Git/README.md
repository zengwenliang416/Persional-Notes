# GitHub Branch Protection Scripts

这个项目提供了两个脚本，用于自动为 GitHub 仓库设置分支保护规则。支持 Unix/Linux/macOS（bash脚本）和 Windows（批处理脚本）环境。

## 功能特点

- 自动获取用户所有仓库
- 为每个仓库的默认分支（main 或 master）设置保护规则
- 支持仓库所有者绕过保护规则
- 要求协作者通过 Pull Request 提交代码
- 提供详细的执行日志和错误信息

## 分支保护规则

- 🔒 禁止直接推送到受保护分支（对协作者）
- ✅ 允许管理员绕过保护规则
- 👥 要求至少一个审查批准
- 🔄 自动关闭过时的审查
- ⚡ 允许强制推送（仅管理员）

## 使用方法

### Unix/Linux/macOS (github_branch_protection.sh)

1. 前置要求：
   ```bash
   # 安装 jq（用于解析 JSON）
   # macOS
   brew install jq
   
   # Ubuntu/Debian
   sudo apt-get install jq
   
   # CentOS/RHEL
   sudo yum install jq
   ```

2. 添加执行权限：
   ```bash
   chmod +x github_branch_protection.sh
   ```

3. 运行脚本：
   ```bash
   ./github_branch_protection.sh <github_username> <github_token>
   ```

### Windows (github_branch_protection.bat)

1. 前置要求：
   - Windows 10 或更高版本（内置 curl）
   - 下载 [jq for Windows](https://stedolan.github.io/jq/download/)
   - 将 `jq.exe` 放在脚本同目录下或添加到系统 PATH

2. 运行脚本：
   ```batch
   github_branch_protection.bat <github_username> <github_token>
   ```

## 获取 GitHub Token

1. 访问 [GitHub Token 设置页面](https://github.com/settings/tokens)
2. 点击 "Generate new token (classic)"
3. 选择以下权限：
   - `repo` （完整的仓库访问权限）
4. 生成并保存 token

## 注意事项

1. **Token 安全**：
   - 不要在公共场合分享你的 GitHub Token
   - 建议使用后立即删除 token 或设置合适的过期时间

2. **权限要求**：
   - 必须是仓库的所有者或管理员
   - Token 必须具有 repo 权限

3. **配置说明**：
   - 脚本会自动处理组织仓库和个人仓库的不同配置要求
   - 如果完整配置失败，会自动尝试使用简化配置

## 常见问题

1. **权限不足**：
   - 确保使用了正确的 GitHub Token
   - 验证 Token 是否具有足够的权限

2. **配置失败**：
   - 检查错误信息
   - 确认是否为仓库所有者
   - 验证仓库是否存在

3. **jq 未找到**：
   - 确保已正确安装 jq
   - 检查 PATH 环境变量

## 贡献

欢迎提交 Issue 和 Pull Request 来改进脚本。

## 许可

MIT License
