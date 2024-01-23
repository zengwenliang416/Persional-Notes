# 【RAS-V10】构建方式

## 前置条件



## bat脚本

```bash
@echo off
setlocal

REM Changing to the 'rams' directory
cd rams

REM Executing Ant commands
call ant clean
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

call ant -propertyfile build-pingan.properties
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

call ant package-zip -propertyfile build-pingan.properties
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

REM Changing back to the root directory
cd ../

REM Executing Maven commands for module apollo
call mvn -f rams/modules/apollo/pom.xml clean package
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

REM Executing Maven commands for module redis
call mvn -f rams/modules/redis/pom.xml clean package
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

REM Installing JAR files to the local Maven repository
for %%f in (core el websocket jasper dbcp) do (
    call mvn install:install-file -Dfile=rams/output/embed/ras-embed-%%f.jar -DgroupId=com.rockyas.rms.embed -DartifactId=ras-embed-%%f -Dversion=10.1 -Dpackaging=jar
    if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
)

REM There are two versions of ecj, installing both to the repository
call mvn install:install-file -Dfile=rams/output/embed/ecj-4.20.jar -DgroupId=com.rockyas.rms.embed -DartifactId=ecj -Dversion=4.12 -Dpackaging=jar
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

call mvn install:install-file -Dfile=rams/output/embed/ecj-4.20.jar -DgroupId=com.rockyas.rms.embed -DartifactId=ecj -Dversion=4.20 -Dpackaging=jar
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

REM Executing Maven clean and install commands for multiple modules
for %%v in (1.2 1.3 1.4 1.5 2.4) do (
    call mvn -f rams-spring-boot-v%%v-starter/pom.xml clean install
    if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
    call mvn -f rams-spring-boot-v%%v-websocket-starter/pom.xml clean install
    if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
)

REM Executing Maven clean and install for rams-spring-boot-starter without version
call mvn -f rams-spring-boot-starter/pom.xml clean install
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

call mvn -f rams-spring-boot-websocket-starter/pom.xml clean install
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

endlocal
```

## shell脚本