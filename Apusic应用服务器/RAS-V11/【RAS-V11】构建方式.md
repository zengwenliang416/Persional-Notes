# 【RAS-V11】构建方式

## 前置条件

```
jdk17
maven 3.6.3
ant 1.10.14
```



## bat脚本

```bash
@echo off
setlocal

REM Changing to the 'rams' directory
cd rams

call mvn -f modules/gson/pom.xml clean package
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

call mvn -f modules/jakartaee-migration/pom.xml clean package
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

REM Executing Ant commands
call ant clean
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

call ant
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

call ant package-zip
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

call mvn -f modules/etcd/pom.xml clean package
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

call mvn -f modules/etcdv3/pom.xml clean package
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

call mvn -f modules/apollo/pom.xml clean package
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

call mvn -f modules/redis/pom.xml clean package
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

REM Changing back to the root directory
cd ../

cd rams/output/embed

call mvn clean initialize
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

endlocal
```

## shell脚本

```shell
#!/bin/bash
# Exit on any error
set -e

# Changing to the 'rams' directory
cd rams

# Executing Maven commands
mvn -f modules/gson/pom.xml clean package

mvn -f modules/jakartaee-migration/pom.xml clean package

# Executing Ant commands
ant clean

ant

ant package-zip

mvn -f modules/etcd/pom.xml clean package

mvn -f modules/etcdv3/pom.xml clean package

mvn -f modules/apollo/pom.xml clean package

mvn -f modules/redis/pom.xml clean package

# Changing back to the root directory
cd ../..

# Continue with Maven commands in the embed directory
cd rams/output/embed

mvn clean initialize
```

