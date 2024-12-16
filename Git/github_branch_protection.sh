#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <github_username> <github_token>"
    exit 1
fi

USERNAME="$1"
TOKEN="$2"

# 获取用户所有仓库
echo "Getting repositories for $USERNAME..."
repos=$(curl -s -H "Authorization: token $TOKEN" \
    "https://api.github.com/users/$USERNAME/repos?per_page=100" | \
    jq -r '.[].name')

for repo in $repos; do
    echo -e "\nProcessing repository: $repo"
    
    # 获取默认分支
    default_branch=$(curl -s -H "Authorization: token $TOKEN" \
        "https://api.github.com/repos/$USERNAME/$repo" | \
        jq -r '.default_branch')
    
    echo "Default branch: $default_branch"
    
    # 设置分支保护
    response=$(curl -s -X PUT \
        -H "Authorization: token $TOKEN" \
        -H "Accept: application/vnd.github.luke-cage-preview+json" \
        -H "Content-Type: application/json" \
        "https://api.github.com/repos/$USERNAME/$repo/branches/$default_branch/protection" \
        -d '{
            "required_status_checks": null,
            "enforce_admins": false,
            "required_pull_request_reviews": {
                "dismiss_stale_reviews": true,
                "require_code_owner_reviews": false,
                "required_approving_review_count": 1
            },
            "restrictions": null,
            "allow_force_pushes": true,
            "allow_deletions": false
        }')
    
    # 检查是否成功
    if echo "$response" | jq -e '.message' > /dev/null; then
        echo "Error: $(echo "$response" | jq -r '.message')"
        echo "Trying simplified configuration..."
        
        # 尝试简化配置
        response=$(curl -s -X PUT \
            -H "Authorization: token $TOKEN" \
            -H "Accept: application/vnd.github.luke-cage-preview+json" \
            -H "Content-Type: application/json" \
            "https://api.github.com/repos/$USERNAME/$repo/branches/$default_branch/protection" \
            -d '{
                "required_status_checks": null,
                "enforce_admins": false,
                "required_pull_request_reviews": null,
                "restrictions": null,
                "allow_force_pushes": true,
                "allow_deletions": false
            }')
        
        if echo "$response" | jq -e '.message' > /dev/null; then
            echo "Error with simplified config: $(echo "$response" | jq -r '.message')"
        else
            echo "✓ Successfully protected $repo's $default_branch branch with simplified config"
        fi
    else
        echo "✓ Successfully protected $repo's $default_branch branch"
    fi
done
