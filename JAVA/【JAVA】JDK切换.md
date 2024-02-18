# 【JAVA】JDK切换

Linux的教程一堆我就不凑热闹了，我介绍的是一种在windows终端上可以直接切换JDK版本的方式。

## 前置条件

### 下载jdk

![image-20240218150309125](./imgs/image-20240218150309125.png)

### 绑定默认jdk

![image-20240218150416704](./imgs/image-20240218150416704.png)

### 配置环境变量

![image-20240218150506003](./imgs/image-20240218150506003.png)

## JDK切换

### 脚本命令

将一下脚本写入到setjdk文件中

```bash
@echo off

:: 显示使用指南
if "%~1"=="" (
    echo Please specify the JDK version you wish to set.
    echo Usage: setjdk.bat [version]
    echo Example: setjdk.bat 11
    goto :EOF
)

set "version=%~1"

:: 检查版本是否受支持并调用相关的设置
if "%version%"=="8" (
    goto :SET_JDK_8
) else if "%version%"=="11" (
    goto :SET_JDK_11
) else if "%version%"=="17" (
    goto :SET_JDK_17
) else if "%version%"=="21" (
    goto :SET_JDK_21
) else (
    echo Invalid JDK version: %version%
    echo Supported versions: 8, 11, 17, 21
    goto :EOF
)

ENDLOCAL
goto :EOF

:SET_JDK_8
call set "JAVA_HOME=D:\workspace\tool\jdk8"
call set Path=%JAVA_HOME%\bin;%Path%
echo Java version set to 8
java -version
goto :EOF

:SET_JDK_11
set "JAVA_HOME=D:\workspace\tool\jdk11"
set Path=%JAVA_HOME%\bin;%Path%
java -version
goto :EOF

:SET_JDK_17
set "JAVA_HOME=D:\workspace\tool\jdk17"
set Path=%JAVA_HOME%\bin;%Path%
java -version
goto :EOF

:SET_JDK_21
set "JAVA_HOME=D:\workspace\tool\jdk21"
set Path=%JAVA_HOME%\bin;%Path%
java -version
goto :EOF
```

### 配置环境变量

确保脚本在jdktool下

![image-20240218150721368](./imgs/image-20240218150721368.png)

![image-20240218150803135](./imgs/image-20240218150803135.png)

### 测试

通过命令`setjdk [版本号]`即可实现JDK的切换。

![image-20240218150944488](./imgs/image-20240218150944488.png)