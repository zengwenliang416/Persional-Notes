# 【AAS-6316】Spring boot适配

## Spring boot写法

### 2.1

```java
private boolean getOrDeduceUseForwardHeaders() {
	if (this.serverProperties.isUseForwardHeaders() != null) {
		return this.serverProperties.isUseForwardHeaders();
	}
	CloudPlatform platform = CloudPlatform.getActive(this.environment);
	return platform != null && platform.isUsingForwardHeaders();
}
```

### 2.2

```java
private boolean getOrDeduceUseForwardHeaders() {
	if (this.serverProperties.getForwardHeadersStrategy() == null) {
		CloudPlatform platform = CloudPlatform.getActive(this.environment);
		return platform != null && platform.isUsingForwardHeaders();
	}
	return this.serverProperties.getForwardHeadersStrategy().equals(ServerProperties.ForwardHeadersStrategy.NATIVE);
}
```

### 2.3

```java
private boolean getOrDeduceUseForwardHeaders() {
	if (this.serverProperties.getForwardHeadersStrategy() == null) {
		CloudPlatform platform = CloudPlatform.getActive(this.environment);
		return platform != null && platform.isUsingForwardHeaders();
	}
	return this.serverProperties.getForwardHeadersStrategy().equals(ServerProperties.ForwardHeadersStrategy.NATIVE);
}
```

### 2.4

```java
private boolean getOrDeduceUseForwardHeaders() {
	if (this.serverProperties.getForwardHeadersStrategy() == null) {
		CloudPlatform platform = CloudPlatform.getActive(this.environment);
		return platform != null && platform.isUsingForwardHeaders();
	}
	return this.serverProperties.getForwardHeadersStrategy().equals(ServerProperties.ForwardHeadersStrategy.NATIVE);
}
```

### 2.5

```java
private boolean getOrDeduceUseForwardHeaders() {
	if (this.serverProperties.getForwardHeadersStrategy() == null) {
		CloudPlatform platform = CloudPlatform.getActive(this.environment);
		return platform != null && platform.isUsingForwardHeaders();
	}
	return this.serverProperties.getForwardHeadersStrategy().equals(ServerProperties.ForwardHeadersStrategy.NATIVE);
}
```

### 2.6

```java
private boolean getOrDeduceUseForwardHeaders() {
	if (this.serverProperties.getForwardHeadersStrategy() == null) {
		CloudPlatform platform = CloudPlatform.getActive(this.environment);
		return platform != null && platform.isUsingForwardHeaders();
	}
	return this.serverProperties.getForwardHeadersStrategy().equals(ServerProperties.ForwardHeadersStrategy.NATIVE);
}
```

### 2.7

```java
private boolean getOrDeduceUseForwardHeaders() {
	if (this.serverProperties.getForwardHeadersStrategy() == null) {
		CloudPlatform platform = CloudPlatform.getActive(this.environment);
		return platform != null && platform.isUsingForwardHeaders();
	}
	return this.serverProperties.getForwardHeadersStrategy().equals(ServerProperties.ForwardHeadersStrategy.NATIVE);
}
```



从2.2开始参数配置方式变更

## 解决方案

更改相应的类和方法并修改优先级

```java
private boolean getOrDeduceUseForwardHeaders() {
    // First check if the ForwardHeadersStrategy is set to NATIVE
    if (this.serverProperties.getForwardHeadersStrategy() != null) {
        return this.serverProperties.getForwardHeadersStrategy().equals(ServerProperties.ForwardHeadersStrategy.NATIVE);
    }

    // Then check if useForwardHeaders is explicitly set
    if (this.serverProperties.isUseForwardHeaders() != null) {
        return this.serverProperties.isUseForwardHeaders();
    }
    
    // If neither is set, deduce from the CloudPlatform
    CloudPlatform platform = CloudPlatform.getActive(this.environment);
    return platform != null && platform.isUsingForwardHeaders();
}
```

