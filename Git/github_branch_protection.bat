@echo off
setlocal EnableDelayedExpansion

if "%~2"=="" (
    echo Usage: %0 ^<github_username^> ^<github_token^>
    exit /b 1
)

set "USERNAME=%~1"
set "TOKEN=%~2"

:: 检查 jq 是否存在
where jq >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo jq is not installed. Please download it from: https://stedolan.github.io/jq/download/
    echo Place jq.exe in the same directory as this script or in your PATH
    exit /b 1
)

echo Getting repositories for %USERNAME%...

:: 获取仓库列表
curl -s -H "Authorization: token %TOKEN%" ^
    "https://api.github.com/users/%USERNAME%/repos?per_page=100" > repos.json

:: 解析仓库列表
for /f "tokens=* usebackq" %%a in (`jq -r ".[].name" repos.json`) do (
    echo.
    echo Processing repository: %%a
    
    :: 获取默认分支
    curl -s -H "Authorization: token %TOKEN%" ^
        "https://api.github.com/repos/%USERNAME%/%%a" > repo_info.json
    
    for /f "tokens=* usebackq" %%b in (`jq -r ".default_branch" repo_info.json`) do (
        set "default_branch=%%b"
        echo Default branch: !default_branch!
        
        :: 设置分支保护
        (
            echo {
            echo    "required_status_checks": null,
            echo    "enforce_admins": false,
            echo    "required_pull_request_reviews": {
            echo        "dismiss_stale_reviews": true,
            echo        "require_code_owner_reviews": false,
            echo        "required_approving_review_count": 1
            echo    },
            echo    "restrictions": null,
            echo    "allow_force_pushes": true,
            echo    "allow_deletions": false
            echo }
        ) > protection.json
        
        curl -s -X PUT ^
            -H "Authorization: token %TOKEN%" ^
            -H "Accept: application/vnd.github.luke-cage-preview+json" ^
            -H "Content-Type: application/json" ^
            -d "@protection.json" ^
            "https://api.github.com/repos/%USERNAME%/%%a/branches/!default_branch!/protection" > response.json
        
        :: 检查是否成功
        jq -e ".message" response.json >nul 2>&1
        if !ERRORLEVEL! EQU 0 (
            echo Error: 
            jq -r ".message" response.json
            echo Trying simplified configuration...
            
            :: 尝试简化配置
            (
                echo {
                echo    "required_status_checks": null,
                echo    "enforce_admins": false,
                echo    "required_pull_request_reviews": null,
                echo    "restrictions": null,
                echo    "allow_force_pushes": true,
                echo    "allow_deletions": false
                echo }
            ) > protection_simple.json
            
            curl -s -X PUT ^
                -H "Authorization: token %TOKEN%" ^
                -H "Accept: application/vnd.github.luke-cage-preview+json" ^
                -H "Content-Type: application/json" ^
                -d "@protection_simple.json" ^
                "https://api.github.com/repos/%USERNAME%/%%a/branches/!default_branch!/protection" > response_simple.json
            
            jq -e ".message" response_simple.json >nul 2>&1
            if !ERRORLEVEL! EQU 0 (
                echo Error with simplified config: 
                jq -r ".message" response_simple.json
            ) else (
                echo √ Successfully protected %%a's !default_branch! branch with simplified config
            )
        ) else (
            echo √ Successfully protected %%a's !default_branch! branch
        )
    )
)

:: 清理临时文件
del /q repos.json repo_info.json protection.json protection_simple.json response.json response_simple.json 2>nul

endlocal
