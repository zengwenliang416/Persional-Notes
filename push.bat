@echo off
setlocal EnableDelayedExpansion

:: 设置颜色代码
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

:: 初始化状态变量
set "STATUS_FILES_ADDED=false"
set "STATUS_CHANGES_COMMITTED=false"
set "STATUS_COMMIT_HASH="
set "STATUS_BRANCH="
set "STATUS_COMMIT_MESSAGE="

:: 定义提交类型数组
set "type[1]=feat: ✨ 新功能"
set "type[2]=fix: 🐛 修复bug"
set "type[3]=docs: 📝 文档更新"
set "type[4]=style: 💄 代码格式"
set "type[5]=refactor: ♻️ 代码重构"
set "type[6]=perf: ⚡️ 性能优化"
set "type[7]=test: ✅ 测试相关"
set "type[8]=build: 📦️ 构建相关"
set "type[9]=ci: 👷 CI/CD相关"
set "type[10]=chore: 🔨 其他更改"
set "type[11]=custom: 🎨 自定义格式"

:: 显示操作状态和恢复建议
:show_status_and_recovery
echo.
echo %BLUE%=== 操作状态 ===%NC%
echo 1. 文件暂存: %STATUS_FILES_ADDED%
echo 2. 更改提交: %STATUS_CHANGES_COMMITTED%
if not "%STATUS_COMMIT_HASH%"=="" (
    echo 3. 提交哈希: %STATUS_COMMIT_HASH%
)
echo 4. 目标分支: %STATUS_BRANCH%
echo 5. 提交信息: %STATUS_COMMIT_MESSAGE%

echo.
echo %BLUE%=== 恢复建议 ===%NC%
if "%STATUS_CHANGES_COMMITTED%"=="true" (
    echo 您的更改已经提交到本地仓库。要重新推送，请执行：
    echo git push origin %STATUS_BRANCH%
    echo.
    echo 如果想要撤销提交，请执行：
    echo git reset --soft HEAD^
) else if "%STATUS_FILES_ADDED%"=="true" (
    echo 文件已暂存但未提交。要继续，请执行：
    echo git commit -m "%STATUS_COMMIT_MESSAGE%"
    echo git push origin %STATUS_BRANCH%
    echo.
    echo 如果想要撤销暂存，请执行：
    echo git reset
)
goto :eof

:: 检查是否在git仓库中
git rev-parse --git-dir >nul 2>&1
if errorlevel 1 (
    echo %RED%错误：当前目录不是git仓库%NC%
    exit /b 1
)

:: 获取当前分支
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set "current_branch=%%i"

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
    set "STATUS_FILES_ADDED=true"
) else if "!choice!"=="2" (
    echo.
    echo %YELLOW%开始交互式选择...%NC%
    git add -p
    set "STATUS_FILES_ADDED=true"
) else if "!choice!"=="3" (
    echo.
    echo %YELLOW%请输入要添加的文件路径（多个文件用空格分隔）:%NC%
    set /p "files="
    if not "!files!"=="" (
        git add !files!
        set "STATUS_FILES_ADDED=true"
    ) else (
        echo %RED%未指定任何文件%NC%
        exit /b 1
    )
) else (
    echo %RED%无效的选择%NC%
    exit /b 1
)

:: 显示提交类型选项
echo.
echo %YELLOW%请选择提交类型:%NC%
for /l %%i in (1,1,11) do echo %%i. !type[%%i]!
set /p "type_choice=请选择 (1-11): "

:: 验证提交类型选择
if !type_choice! lss 1 (
    echo %RED%无效的选择%NC%
    exit /b 1
)
if !type_choice! gtr 11 (
    echo %RED%无效的选择%NC%
    exit /b 1
)

:: 获取选择的提交类型
set "commit_prefix=!type[%type_choice%]!"

:: 如果选择了自定义格式，让用户输入emoji
if "!type_choice!"=="11" (
    echo.
    echo %YELLOW%请选择emoji:%NC%
    echo 1. 🎨 艺术     2. 🌟 闪耀     3. 🚀 火箭
    echo 4. 🎯 目标     5. 🎬 电影     6. 🎮 游戏
    echo 7. 📱 手机     8. 💻 电脑     9. 🌈 彩虹
    set /p "emoji_choice=请选择 (1-9): "
    
    :: 设置emoji
    if "!emoji_choice!"=="1" set "emoji=🎨"
    if "!emoji_choice!"=="2" set "emoji=🌟"
    if "!emoji_choice!"=="3" set "emoji=🚀"
    if "!emoji_choice!"=="4" set "emoji=🎯"
    if "!emoji_choice!"=="5" set "emoji=🎬"
    if "!emoji_choice!"=="6" set "emoji=🎮"
    if "!emoji_choice!"=="7" set "emoji=📱"
    if "!emoji_choice!"=="8" set "emoji=💻"
    if "!emoji_choice!"=="9" set "emoji=🌈"
    
    :: 获取自定义类型
    set /p "custom_type=请输入提交类型: "
    set "commit_prefix=!custom_type!: !emoji!"
)

:: 获取提交描述
echo.
set /p "commit_desc=请输入提交描述: "

:: 组合完整的提交信息
set "message=!commit_prefix! !commit_desc!"
set "STATUS_COMMIT_MESSAGE=!message!"

:: 获取分支名称
set /p "branch=请输入分支名称 (默认是 %current_branch%): "
if "!branch!"=="" set "branch=%current_branch%"
set "STATUS_BRANCH=!branch!"

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
set "STATUS_CHANGES_COMMITTED=true"
for /f "tokens=*" %%i in ('git rev-parse HEAD') do set "STATUS_COMMIT_HASH=%%i"

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
