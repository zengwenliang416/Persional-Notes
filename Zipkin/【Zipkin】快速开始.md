
## docker

The [Docker Zipkin](https://github.com/openzipkin/docker-zipkin) project is able to build docker images, provide scripts and a [`docker-compose.yml`](https://github.com/openzipkin/docker-zipkin/blob/master/docker-compose.yml) for launching pre-built images. The quickest start is to run the latest image directly:

```
docker run -d -p 9411:9411 openzipkin/zipkin
```

## Java

If you have Java 17 or higher installed, the quickest way to get started is to fetch the [latest release](https://search.maven.org/remote_content?g=io.zipkin&a=zipkin-server&v=LATEST&c=exec) as a self-contained executable jar:

```java
curl -sSL https://zipkin.io/quickstart.sh | bash -s
java -jar zipkin.jar
```

## Homebrew

If you have [Homebrew](https://brew.sh/) installed, the quickest way to get started is to install the [zipkin formula](https://formulae.brew.sh/formula/zipkin).

```
brew install zipkin
# to run in foreground
zipkin
# to run in background
brew services start zipkin
```

## Running from Source

Zipkin can be run from source if you are developing new features. To achieve this, you’ll need to get [Zipkin’s source](https://github.com/openzipkin/zipkin) and build it.

```
# get the latest source
git clone https://github.com/openzipkin/zipkin
cd zipkin
# Build the server and also make its dependencies
./mvnw -T1C -q --batch-mode -DskipTests --also-make -pl zipkin-server clean package
# Run the server
java -jar ./zipkin-server/target/zipkin-server-*exec.jar
# or Run the slim server
java -jar ./zipkin-server/target/zipkin-server-*slim.jar
```

## 测试

访问http://localhost:9411/zipkin/。