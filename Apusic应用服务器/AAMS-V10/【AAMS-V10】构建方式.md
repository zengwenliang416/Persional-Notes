```bash
@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

SET PROP_FILE=build.properties
call setjdk 8

call ant -propertyfile %PROP_FILE% clean deploy

call mvn clean package -Dmaven.test.skip=true -f modules/etcd/pom.xml
call mvn clean package -Dmaven.test.skip=true -f modules/apollo/pom.xml
call mvn clean package -Dmaven.test.skip=true -f modules/etcdv3/pom.xml
call mvn clean package -Dmaven.test.skip=true -f modules/redis/pom.xml
call mvn clean package -Dmaven.test.skip=true -f modules/kafka/pom.xml
call ant -propertyfile %PROP_FILE% clean package-zip

REM Installing JAR files with Maven
FOR %%i IN (aas-embed-core aas-embed-el aas-embed-websocket aas-embed-jasper aas-dbcp aas-util ecj) DO (
    IF "%%i"=="ecj" (
        call mvn install:install-file -Dfile=output/embed/%%i-4.20.jar -DgroupId=com.apusic.ams.embed -DartifactId=%%i -Dversion=10.1.1 -Dpackaging=jar
    ) ELSE (
        call mvn install:install-file -Dfile=output/embed/%%i.jar -DgroupId=com.apusic.ams.embed -DartifactId=%%i -Dversion=10.1 -Dpackaging=jar
    )
)

call mvn clean install -Dmaven.test.skip=true -f starter/aams-spring-boot-v2.4-web-starter/pom.xml
call mvn clean install -Dmaven.test.skip=true -f starter/aams-spring-boot-web-starter/pom.xml
call mvn clean install -Dmaven.test.skip=true -f starter/aams-spring-boot-v2.4-web-starter/pom.xml
call mvn clean install -Dmaven.test.skip=true -f starter/aams-spring-boot-starter/pom.xml
call mvn clean install -Dmaven.test.skip=true -f starter/aams-spring-boot-websocket-starter/pom.xml
call mvn clean install -Dmaven.test.skip=true -f starter/aams-spring-boot-v1.5-starter/pom.xml
call mvn clean install -Dmaven.test.skip=true -f starter/aams-spring-boot-v1.5-websocket-starter/pom.xml

ENDLOCAL
```

