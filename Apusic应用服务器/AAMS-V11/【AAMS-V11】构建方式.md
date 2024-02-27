```
mvn clean package -f modules/gson
mvn clean package -f modules/jakartaee-migration
ant clean deploy
mvn clean package -f modules/etcd
mvn clean package -f modules/etcdv3
mvn clean package -f modules/apollo
mvn clean package -f modules/redis
ant release -propertyfile ${BuildProperties}
ant package-examples-war
cd output/embed && mvn clean initialize
mvn clean package -f starter/aams-spring-boot-starter/pom.xml
mkdir -p output/embed/starter-3.0
cp starter/aams-spring-boot-starter/target/aams-spring-boot-starter-*.jar output/embed/starter-3.0
cp starter/aams-spring-boot-starter/pom.xml output/embed/starter-3.0
mvn clean package -f starter/aams-spring-boot-starter/pom-all.xml
cp starter/aams-spring-boot-starter/target/aams-spring-boot-starter-*.jar output/embed/starter-3.0
mvn clean package -f starter/aams-spring-boot-v3.2-starter/pom.xml
mkdir -p output/embed/starter-3.2
cp starter/aams-spring-boot-v3.2-starter/target/aams-spring-boot-starter-*.jar output/embed/starter-3.2
cp starter/aams-spring-boot-v3.2-starter/pom.xml output/embed/starter-3.2
mvn clean package -f starter/aams-spring-boot-v3.2-starter/pom-all.xml
cp starter/aams-spring-boot-v3.2-starter/target/aams-spring-boot-starter-*.jar output/embed/starter-3.2
ant embed-package -propertyfile ${BuildProperties}
```

