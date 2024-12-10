@echo off
setlocal EnableDelayedExpansion

:: 设置颜色代码
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "NC=[0m"

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
) else if "!choice!"=="2" (
    echo.
    echo %YELLOW%开始交互式选择...%NC%
    git add -p
) else if "!choice!"=="3" (
    echo.
    echo %YELLOW%请输入要添加的文件路径（多个文件用空格分隔）:%NC%
    set /p "files="
    if not "!files!"=="" (
        git add !files!
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

:: 获取提交信息
:get_message
set /p "message=请输入提交信息: "
if "!message!"=="" (
    echo %RED%提交信息不能为空，请重新输入%NC%
    goto get_message
)

:: 获取分支名称
set /p "branch=请输入分支名称 (默认是 %current_branch%): "
if "!branch!"=="" set "branch=%current_branch%"

echo.
echo %YELLOW%即将执行以下操作:%NC%
echo 1. git commit -m "%message%"
echo 2. git push origin %branch%

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
git commit -m "%message%"
if errorlevel 1 (
    echo %RED%提交更改失败%NC%
    exit /b 1
)

echo.
echo %YELLOW%2. 推送到远程...%NC%
git push origin "%branch%"
if errorlevel 1 (
    echo %RED%推送失败，请检查网络连接或远程仓库状态%NC%
    exit /b 1
) else (
    echo.
    echo %GREEN%所有操作已成功完成！%NC%
)

pause
