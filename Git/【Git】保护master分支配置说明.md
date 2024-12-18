# Git仓库Master分支保护配置说明

## 目录
- [1. 目录](#目录)
- [2. GitHub设置方法](#github设置方法)
    - [基础设置步骤](#基础设置步骤)
    - [保护规则配置](#保护规则配置)
- [3. GitLab设置方法](#gitlab设置方法)
    - [基础设置步骤](#基础设置步骤)
    - [保护规则配置](#保护规则配置)
- [4. 本地Git配置（可选）](#本地git配置可选)
    - [预防性配置](#预防性配置)
- [5. 最佳实践](#最佳实践)
    - [分支策略](#分支策略)
    - [合并流程](#合并流程)
    - [紧急情况处理](#紧急情况处理)
- [6. 其他建议](#其他建议)
- [7. 批量设置分支保护](#批量设置分支保护)
    - [GitHub批量设置](#github批量设置)
        - [使用GitHub API](#使用github-api)
        - [使用GitHub Enterprise组织级策略](#使用github-enterprise组织级策略)
    - [GitLab批量设置](#gitlab批量设置)
        - [使用GitLab API](#使用gitlab-api)
        - [使用Python脚本批量设置](#使用python脚本批量设置)
        - [GitLab Enterprise组设置](#gitlab-enterprise组设置)
    - [注意事项](#注意事项)
- [8. Pull Request审查流程](#pull-request审查流程)
    - [创建Pull Request](#创建pull-request)
    - [审查步骤](#审查步骤)
    - [合并条件](#合并条件)
    - [最佳实践](#最佳实践)
    - [常见问题](#常见问题)



## GitHub设置方法

### 基础设置步骤
1. 进入GitHub仓库页面
2. 点击 `Settings` 选项卡
3. 选择左侧菜单中的 `Branches`
4. 在 `Branch protection rules` 部分点击 `Add rule`

### 保护规则配置
1. Branch name pattern 填写：`master`
2. 勾选以下保护选项：
   - ✓ Require pull request reviews before merging
     - 要求代码在合并前必须经过审查
     - 可以设置所需的审查人数（建议至少1人）
   
   - ✓ Dismiss stale pull request approvals when new commits are pushed
     - 新的提交会使之前的审批失效
   
   - ✓ Require status checks to pass before merging
     - 确保CI检查通过才能合并
   
   - ✓ Require branches to be up to date before merging
     - 确保分支是最新的才能合并
   
   - ✓ Include administrators
     - 管理员也需要遵循这些规则

## GitLab设置方法

### 基础设置步骤
1. 进入GitLab项目页面
2. 点击 `Settings` -> `Repository`
3. 展开 `Protected Branches` 部分

### 保护规则配置
1. Branch：选择 `master`
2. 配置以下权限：
   - Allowed to merge：选择 `Maintainers`
   - Allowed to push：选择 `No one`
   - 勾选 `Code owner approval required`

## 本地Git配置（可选）

### 预防性配置
```bash
# 防止直接推送到master
git config branch.master.pushRemote "no_push"

# 设置pre-commit钩子
cat > .git/hooks/pre-commit << 'EOF'
# !/bin/sh
branch="$(git rev-parse --abbrev-ref HEAD)"
if [ "$branch" = "master" ]; then
  echo "不允许在master分支直接提交"
  exit 1
fi
EOF
chmod +x .git/hooks/pre-commit
```

## 最佳实践

### 分支策略
1. 开发新功能时创建feature分支
2. 修复bug时创建hotfix分支
3. 使用develop分支作为开发主分支
4. master分支只用于产品发布

### 合并流程
1. 创建Pull Request/Merge Request
2. 代码审查
3. CI/CD检查通过
4. 审批通过后合并

### 紧急情况处理
1. 建立明确的紧急处理流程
2. 记录所有紧急更改
3. 事后进行代码审查

## 其他建议

1. 定期备份master分支
2. 建立清晰的分支命名规范
3. 设置自动化测试流程
4. 保持提交信息的规范性
5. 定期清理过期分支

## 批量设置分支保护

### GitHub批量设置

#### 使用GitHub API
```bash
# 获取组织下所有仓库
curl -H "Authorization: token YOUR_TOKEN" \
     "https://api.github.com/orgs/YOUR_ORG/repos"

# 为每个仓库设置分支保护
curl -X PUT \
  -H "Authorization: token YOUR_TOKEN" \
  -H "Accept: application/vnd.github.luke-cage-preview+json" \
  https://api.github.com/repos/OWNER/REPO/branches/master/protection \
  -d '{
    "required_status_checks": null,
    "enforce_admins": true,
    "required_pull_request_reviews": {
      "dismissal_restrictions": {},
      "dismiss_stale_reviews": true,
      "require_code_owner_reviews": true,
      "required_approving_review_count": 1
    },
    "restrictions": null
  }'
```

#### 使用GitHub Enterprise组织级策略
1. 进入组织设置
2. 选择 `Repository defaults`
3. 配置默认的分支保护规则
4. 这些规则将自动应用到新创建的仓库

### GitLab批量设置

#### 使用GitLab API
```bash
# 获取所有项目
curl --header "PRIVATE-TOKEN: YOUR_TOKEN" \
     "https://gitlab.com/api/v4/projects"

# 为每个项目设置分支保护
curl --request POST \
     --header "PRIVATE-TOKEN: YOUR_TOKEN" \
     "https://gitlab.com/api/v4/projects/PROJECT_ID/protected_branches" \
     --data "name=master&push_access_level=0&merge_access_level=40"
```

#### 使用Python脚本批量设置
```python
import requests

def protect_master_branch(gitlab_url, token, project_id):
    headers = {'PRIVATE-TOKEN': token}
    protect_url = f"{gitlab_url}/api/v4/projects/{project_id}/protected_branches"
    
    data = {
        'name': 'master',
        'push_access_level': 0,  # No one can push
        'merge_access_level': 40,  # Only maintainers can merge
        'code_owner_approval_required': True
    }
    
    response = requests.post(protect_url, headers=headers, data=data)
    return response.status_code == 201

# 使用示例
gitlab_url = 'https://gitlab.com'
token = 'YOUR_TOKEN'
projects = requests.get(f"{gitlab_url}/api/v4/projects", headers={'PRIVATE-TOKEN': token}).json()

for project in projects:
    protect_master_branch(gitlab_url, token, project['id'])
```

#### GitLab Enterprise组设置
1. 进入组设置页面
2. 选择 `Settings` -> `Repository`
3. 配置 `Default branch protection`
4. 这些设置将应用到组内所有新项目

### 注意事项

1. API令牌安全：
   - 使用有限权限的令牌
   - 定期轮换令牌
   - 不要在代码中硬编码令牌

2. 批量操作风险：
   - 先在测试环境验证脚本
   - 分批执行，避免一次性操作太多仓库
   - 保留操作日志

3. 异常处理：
   - 记录失败的操作
   - 实现重试机制
   - 提供回滚方案

4. 权限控制：
   - 确保有足够的权限执行这些操作
   - 记录谁在何时进行了批量修改
   - 通知相关团队成员

5. 后续维护：
   - 定期验证保护规则是否生效
   - 监控规则是否被修改
   - 建立规则变更的审计机制

## Pull Request审查流程

### 创建Pull Request
```bash
# 创建新分支
git checkout -b feature/your-feature

# 修改代码并提交
git add .
git commit -m "your changes"

# 推送到新分支
git push origin feature/your-feature

# 在GitHub上创建Pull Request
# 访问仓库页面，点击"Compare & pull request"
```

### 审查步骤

1. 访问Pull Request页面
   - 点击 "Files changed" 标签页
   - 查看代码变更

2. 添加评论
   - 点击具体代码行左侧的 "+" 号
   - 可以添加具体的评论
   - 可以提出修改建议

3. 提交审查
   点击 "Review changes" 按钮，选择：
   - ✓ **Approve**：批准变更
   - ⚠ **Request changes**：请求修改
   - 💬 **Comment**：添加评论但不批准或拒绝

### 合并条件
1. 获得必要数量的批准（根据设置，通常是1个）
2. 所有讨论都已解决
3. 所有必要的检查都已通过

### 最佳实践
1. 仔细审查每一行代码变更
2. 检查代码风格和规范
3. 验证功能正确性
4. 考虑性能影响
5. 确保测试覆盖率

### 常见问题
1. 审查权限不足
   - 确保有仓库的写入权限
   - 联系仓库管理员获取权限

2. 无法合并
   - 检查是否获得足够的批准
   - 确认所有讨论都已解决
   - 验证分支是否最新

3. 代码冲突
   - 将目标分支合并到特性分支
   - 解决冲突后重新提交
