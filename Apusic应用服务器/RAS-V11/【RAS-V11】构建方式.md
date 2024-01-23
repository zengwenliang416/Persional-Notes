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

call ant -propertyfile build-pingan.properties
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

call ant package-zip -propertyfile build-pingan.properties
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