@echo off
setlocal EnableDelayedExpansion

:: 设置颜色代码
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

:: 初始化操作状态
set "files_added=false"
set "changes_committed=false"
set "commit_hash="
set "target_branch="
set "commit_message="

:: 显示操作状态和恢复建议
:show_status_and_recovery
echo.
echo %BLUE%=== 操作状态 ===%NC%
echo 1. 文件暂存: %files_added%
echo 2. 更改提交: %changes_committed%
if not "%commit_hash%"=="" (
    echo 3. 提交哈希: %commit_hash%
)
echo 4. 目标分支: %target_branch%
echo 5. 提交信息: %commit_message%

echo.
echo %BLUE%=== 恢复建议 ===%NC%
if "%changes_committed%"=="true" (
    echo 您的更改已经提交到本地仓库。要重新推送，请执行：
    echo git push origin %target_branch%
    echo.
    echo 如果想要撤销提交，请执行：
    echo git reset --soft HEAD^
) else if "%files_added%"=="true" (
    echo 文件已暂存但未提交。要继续，请执行：
    echo git commit -m "%commit_message%"
    echo git push origin %target_branch%
    echo.
    echo 如果想要撤销暂存，请执行：
    echo git reset
)
goto :eof

:: 设置颜色代码
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "NC=[0m"

:: 定义提交类型数组
set "commit_type[1]=feat: ✨ 新功能"
set "commit_type[2]=fix: 🐛 修复bug"
set "commit_type[3]=docs: 📝 文档更新"
set "commit_type[4]=style: 💄 代码格式"
set "commit_type[5]=refactor: ♻️ 代码重构"
set "commit_type[6]=perf: ⚡️ 性能优化"
set "commit_type[7]=test: ✅ 测试相关"
set "commit_type[8]=build: 📦 构建相关"
set "commit_type[9]=ci: 👷 CI/CD相关"
set "commit_type[10]=chore: 🔧 其他更改"
set "commit_type[11]=custom: 🎨 自定义格式"

:: 定义表情数组
set "emoji[1]=✨ - 新功能"
set "emoji[2]=🐛 - Bug修复"
set "emoji[3]=📝 - 文档"
set "emoji[4]=💄 - 样式"
set "emoji[5]=♻️ - 重构"
set "emoji[6]=⚡️ - 性能"
set "emoji[7]=✅ - 测试"
set "emoji[8]=📦 - 构建"
set "emoji[9]=👷 - CI/CD"
set "emoji[10]=🔧 - 工具"
set "emoji[11]=🎨 - 格式"
set "emoji[12]=🚀 - 部署"
set "emoji[13]=🆕 - 新增"
set "emoji[14]=🔨 - 更新"
set "emoji[15]=🗑️ - 删除"
set "emoji[16]=🔀 - 合并"
set "emoji[17]=🔖 - 版本"
set "emoji[18]=🔒 - 安全"

:: 检查是否在git仓库中
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo %RED%错误: 当前目录不是git仓库%NC%
    exit /b 1
)

:: 获取当前分支
for /f "tokens=*" %%i in ('git symbolic-ref --short HEAD 2^>nul') do set current_branch=%%i

:: 检查是否有未提交的更改
git status --porcelain >nul
if errorlevel 1 (
    echo %YELLOW%没有发现需要提交的更改%NC%
    set /p "continue=是否继续? (y/n): "
    if /i "!continue!" neq "y" (
        echo 操作已取消
        exit /b 0
    )
)

:: 显示git状态
echo %YELLOW%当前Git状态:%NC%
git status -s

:: 选择提交方式
echo.
echo %YELLOW%请选择提交方式:%NC%
echo 1. 提交所有更改 (git add .)
echo 2. 交互式选择文件 (git add -p)
echo 3. 手动输入文件路径
set /p "choice=请选择 (1-3): "

if "!choice!"=="1" (
    echo.
    echo %YELLOW%添加所有文件...%NC%
    git add .
    set "files_added=true"
) else if "!choice!"=="2" (
    echo.
    echo %YELLOW%开始交互式选择...%NC%
    git add -p
    set "files_added=true"
) else if "!choice!"=="3" (
    echo.
    echo %YELLOW%请输入要添加的文件路径（多个文件用空格分隔）:%NC%
    set /p "files="
    if not "!files!"=="" (
        git add !files!
        set "files_added=true"
    ) else (
        echo %RED%未指定任何文件%NC%
        exit /b 1
    )
) else (
    echo %RED%无效的选择%NC%
    exit /b 1
)

:: 显示已暂存的更改
echo.
echo %YELLOW%已暂存的更改:%NC%
git status -s

:: 选择提交信息类型
echo.
echo %YELLOW%请选择提交类型:%NC%
for /l %%i in (1,1,11) do (
    echo %%i. !commit_type[%%i]!
)
set /p "type_choice=请选择 (1-11): "

if !type_choice! geq 1 if !type_choice! leq 11 (
    set "selected_type=!commit_type[%type_choice%]!"
) else (
    echo %RED%无效的选择%NC%
    exit /b 1
)

:: 如果选择自定义格式
if "!selected_type:~0,7!"=="custom:" (
    :: 显示表情列表
    echo.
    echo %YELLOW%请选择表情:%NC%
    for /l %%i in (1,1,18) do (
        echo %%i. !emoji[%%i]!
    )
    set /p "emoji_choice=请选择表情 (1-18, 直接回车跳过): "
    
    if not "!emoji_choice!"=="" (
        if !emoji_choice! geq 1 if !emoji_choice! leq 18 (
            for /f "tokens=1 delims= " %%a in ("!emoji[%emoji_choice%]!") do set "selected_emoji=%%a"
        )
    )
    
    set /p "custom_type=请输入自定义提交类型: "
    if not "!custom_type!"=="" (
        if not "!selected_emoji!"=="" (
            set "commit_prefix=!custom_type!: !selected_emoji!"
        ) else (
            set "commit_prefix=!custom_type!:"
        )
    ) else (
        echo %RED%提交类型不能为空%NC%
        exit /b 1
    )
) else (
    for /f "tokens=1,2 delims= " %%a in ("!selected_type!") do set "commit_prefix=%%a %%b"
)

:: 获取提交信息
set /p "commit_desc=请输入提交描述: "
if "!commit_desc!"=="" (
    echo %RED%提交描述不能为空%NC%
    exit /b 1
)

:: 组合完整的提交信息
set "message=!commit_prefix! !commit_desc!"
set "commit_message=!message!"

:: 获取分支名称
set /p "branch=请输入分支名称 (默认是 %current_branch%): "
if "!branch!"=="" set "branch=%current_branch%"
set "target_branch=!branch!"

echo.
echo %YELLOW%即将执行以下操作:%NC%
echo 1. git commit -m "!message!"
echo 2. git push origin !branch!

set /p "confirm=确认执行? (y/n): "
if /i "!confirm!" neq "y" (
    echo 操作已取消
    exit /b 0
)

:: 执行git命令
echo.
echo %YELLOW%正在执行git操作...%NC%

echo.
echo %YELLOW%1. 提交更改...%NC%
git commit -m "!message!"
if errorlevel 1 (
    echo %RED%提交更改失败%NC%
    call :show_status_and_recovery
    exit /b 1
)
set "changes_committed=true"
for /f "tokens=*" %%i in ('git rev-parse HEAD') do set "commit_hash=%%i"

echo.
echo %YELLOW%2. 推送到远程...%NC%
git push origin "!branch!"
if errorlevel 1 (
    echo %RED%推送失败，请检查网络连接或远程仓库状态%NC%
    call :show_status_and_recovery
    exit /b 1
) else (
    echo.
    echo %GREEN%所有操作已成功完成！%NC%
)

pause
