# Maven 常用命令

## 目录
- [1. 目录](#目录)
- [2. 一、Maven 生命周期](#一maven-生命周期)
- [3. 二、常用命令](#二常用命令)
    - [3.1 基础命令](#基础命令)
    - [3.2 组合命令](#组合命令)
    - [3.3 依赖管理](#依赖管理)
    - [3.4 多模块项目命令](#多模块项目命令)
    - [3.5 部署文件到仓库](#部署文件到仓库)
    - [3.6 常用参数说明](#常用参数说明)
- [4. 三、最佳实践](#三最佳实践)
    - [4.1 性能优化](#性能优化)
    - [4.2 常见问题解决](#常见问题解决)
- [5. 四、参考资源](#四参考资源)



## 一、Maven 生命周期

Maven 构建生命周期分为三个标准生命周期：

1. **clean**：项目清理
   - pre-clean
   - clean
   - post-clean

2. **default**：主要构建过程
   - validate
   - compile
   - test
   - package
   - verify
   - install
   - deploy

3. **site**：项目站点文档创建
   - pre-site
   - site
   - post-site
   - site-deploy

## 二、常用命令

### 基础命令

```bash
# 清理编译文件
mvn clean                           # 清理target目录

# 编译
mvn compile                         # 编译主代码
mvn test-compile                    # 编译测试代码

# 测试
mvn test                           # 运行测试
mvn test -Dtest=TestClassName      # 运行指定测试类

# 打包
mvn package                        # 打包
mvn package -DskipTests            # 跳过测试打包
mvn package -Dmaven.test.skip=true # 跳过测试代码的编译和运行

# 安装到本地仓库
mvn install                        # 安装到本地仓库
mvn install -DskipTests            # 跳过测试安装

# 部署到远程仓库
mvn deploy                         # 部署到远程仓库
```

### 组合命令

```bash
# 完整构建流程
mvn clean package                  # 清理并打包
mvn clean install                  # 清理、打包并安装到本地仓库
mvn clean deploy                   # 清理、打包并部署到远程仓库

# 跳过测试的构建
mvn clean package -DskipTests      # 跳过测试打包
mvn clean install -DskipTests      # 跳过测试安装
mvn clean deploy -DskipTests       # 跳过测试部署
```

### 依赖管理

```bash
# 查看依赖
mvn dependency:tree               # 查看依赖树
mvn dependency:list              # 列出所有依赖
mvn dependency:analyze           # 分析依赖

# 下载依赖源码
mvn dependency:sources           # 下载依赖源码
mvn dependency:resolve -Dclassifier=javadoc  # 下载依赖文档

# 更新依赖
mvn versions:display-dependency-updates  # 检查依赖更新
mvn versions:use-latest-versions        # 更新到最新版本
```

### 多模块项目命令

```bash
# 构建指定模块
mvn clean package -pl module-name                 # 构建单个模块
mvn clean package -pl module1,module2            # 构建多个模块

# 构建模块及其依赖
mvn clean package -pl module-name -am            # 构建模块及其依赖项
mvn clean package -pl module-name -amd           # 构建模块及依赖它的模块

# 排除模块
mvn clean package -pl !module-name               # 排除指定模块
```

### 部署文件到仓库

```bash
# 部署单个文件到远程仓库
mvn deploy:deploy-file \
    "-DgroupId=com.example" \
    "-DartifactId=demo" \
    "-Dversion=1.0.0" \
    "-Dpackaging=jar" \
    "-Dfile=demo-1.0.0.jar" \
    "-Durl=http://repository.example.com/maven-releases/" \
    "-DrepositoryId=releases"

# 部署源码和文档
mvn deploy:deploy-file \
    "-DgroupId=com.example" \
    "-DartifactId=demo" \
    "-Dversion=1.0.0" \
    "-Dpackaging=jar" \
    "-Dfile=demo-1.0.0.jar" \
    "-Dsources=demo-1.0.0-sources.jar" \
    "-Djavadoc=demo-1.0.0-javadoc.jar" \
    "-Durl=http://repository.example.com/maven-releases/" \
    "-DrepositoryId=releases"
```

### 常用参数说明

| 参数                      | 说明                                          |
|-------------------------|---------------------------------------------|
| `-DskipTests`           | 跳过测试执行，但会编译测试代码                          |
| `-Dmaven.test.skip=true`| 跳过测试代码的编译和执行                              |
| `-X` 或 `--debug`        | 开启调试模式                                     |
| `-q` 或 `--quiet`        | 安静模式，只输出错误                                |
| `-U`                    | 强制更新依赖快照                                  |
| `-o` 或 `--offline`      | 离线模式                                       |
| `-pl` 或 `--projects`    | 指定构建的项目列表                                 |
| `-am` 或 `--also-make`   | 同时构建所列模块的依赖模块                            |
| `-amd`                  | 同时构建依赖于所列模块的模块                           |
| `-rf` 或 `--resume-from` | 从指定的项目恢复反应堆                              |

## 三、最佳实践

### 性能优化

```bash
# 并行构建
mvn clean install -T 4    # 使用4个线程构建
mvn clean install -T 1C   # 每个CPU核心使用1个线程

# 离线构建
mvn clean install -o      # 使用本地仓库缓存

# 跳过不必要的插件
mvn clean install -DskipTests -Dmaven.javadoc.skip=true -Dmaven.source.skip=true
```

### 常见问题解决

```bash
# 强制更新依赖
mvn clean install -U

# 清理Maven本地仓库
mvn dependency:purge-local-repository

# 验证项目
mvn validate

# 检查更新
mvn versions:display-dependency-updates
mvn versions:display-plugin-updates
```

## 四、参考资源

- [Maven 官方文档](https://maven.apache.org/guides/index.html)
- [Maven 生命周期参考](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html)
- [Maven 插件列表](https://maven.apache.org/plugins/)
