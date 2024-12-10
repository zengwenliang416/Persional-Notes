## 打包命令

```bash
mvncleanpackage-Dmaven.test.skip=true		--跳过单测打包
mvncleaninstall-Dmaven.test.skip=true		--跳过单测打包，并把打好的包上传到本地仓库
mvncleandeploy-Dmaven.test.skip=true			--跳过单测打包，并把打好的包上传到远程仓库
mvncleanpackage-plitsp-cloud/itsp-cloud-services/itsp-cloud-service-platform-am-DskipTests=true--不构建itsp-cloud/itsp-cloud-services/itsp-cloud-service-platform
```

```bash
./mvnw-q--batch-mode-DskipTests--also-make-plzipkin-servercleaninstall
```

> -q：这个选项表示“quiet”，即减少输出信息，只显示最重要的信息，如错误和警告。
>
> --batch-mode：这个选项意味着Maven将在批处理模式下运行，这意味着它不会在遇到问题时暂停以等待用户输入，而是继续执行或失败。
>
> -DskipTests：这个参数告诉Maven跳过所有的单元测试。这对于快速构建而不关心测试结果的情况很有用。
>
> --also-make：当依赖关系发生变化时，Maven将自动构建相关的模块，而不仅仅是请求的目标模块。
>
> -plzipkin-server：这指定了要构建的项目模块，这里是zipkin-server模块。
>
> cleaninstall：这是一个Maven生命周期阶段，clean会删除以前的构建结果，install则会编译、打包并将项目安装到本地仓库。

```
mvndeploy:deploy-file"-DgroupId=com.abc""-DartifactId=demo""-Dversion=3.3.0""-Dpackaging=jar""-DgeneratePom=true""-Dfile=demo-V3.3.0.jar""-Durl=http://xxxx.com/repository/maven-releases/""-DrepositoryId=demo-releases"
```
