# ServletUtils 与 RequestContextHolder 使用指南

## 目录
[1. 目录](#目录)
[2. 概述](#概述)
[3. ServletUtils 工具类](#servletutils-工具类)
    [3.1 继承关系](#继承关系)
    [3.2 核心功能](#核心功能)
        [    请求参数获取](#请求参数获取)
        [    请求和响应操作](#请求和响应操作)
        [    自动填充 Bean 对象](#自动填充-bean-对象)
        [    响应处理](#响应处理)
    [3.7 使用示例](#使用示例)
        [    示例 2：文件下载](#示例-2文件下载)
        [    示例 3：文件上传与表单处理](#示例-3文件上传与表单处理)
[4. RequestContextHolder 使用指南](#requestcontextholder-使用指南)
    [4.1 概述](#概述-1)
    [4.2 使用场景](#使用场景)
    [4.3 示例](#示例)
        [    异步处理请求上下文](#异步处理请求上下文)
[5. 注意事项](#注意事项)
[6. 总结](#总结)



## 概述

在 Web 开发中，经常需要统一管理请求和响应对象，同时简化参数获取、文件下载以及请求上下文的处理流程。`ServletUtils` 和 `RequestContextHolder` 是两个非常重要的工具类，能够帮助开发者高效完成这些任务。

- `ServletUtils`：扩展自 Hutool 的 `JakartaServletUtil`，提供丰富的请求、响应操作及参数处理功能。
- `RequestContextHolder`：Spring 框架提供的请求上下文管理工具，用于在应用程序中获取当前线程的请求上下文。

---

## ServletUtils 工具类

### 继承关系

`ServletUtils` 扩展了 Hutool 的 `JakartaServletUtil`，保留了原有功能，同时增加了对 Spring 环境的深度集成。它提供了以下增强功能：

1. **Spring 请求与响应集成**：支持从 Spring 的上下文中获取 `HttpServletRequest` 和 `HttpServletResponse`。
2. **类型转换增强**：支持多种数据类型（如 Integer、Long、Boolean 等）的参数转换。
3. **参数填充**：支持将请求参数自动映射到 Java Bean。
4. **响应增强**：支持 JSON 响应、文件下载等功能。

---

### 核心功能

#### 请求参数获取

通过 `ServletUtils` 可以快速获取请求参数，并支持常见的数据类型转换：

```java
// 获取字符串参数
String value = ServletUtils.getParameter("paramName", "defaultValue");

// 获取整数参数
Integer intValue = ServletUtils.getParameterToInt("paramName", 0);

// 获取布尔参数
Boolean boolValue = ServletUtils.getParameterToBool("paramName", false);

// 获取参数Map
Map<String, String[]> paramArrayMap = ServletUtils.getParams(request);
Map<String, String> paramMap = ServletUtils.getParamMap(request);
```

#### 请求和响应操作

`ServletUtils` 提供了便捷的方法来操作请求和响应对象：

```java
// 获取请求与响应对象
HttpServletRequest request = ServletUtils.getRequest();
HttpServletResponse response = ServletUtils.getResponse();

// 设置响应头和内容
ServletUtils.renderString(response, "Hello, World!");

// 文件下载
ServletUtils.setAttachmentResponseHeader(response, "example.txt");
ServletUtils.write(response, fileBytes);
```

#### 自动填充 Bean 对象

将请求参数自动映射到 Java 对象中，支持复杂对象（如嵌套对象和集合类型）的自动填充：

```java
// 自动填充简单对象
UserRequest userRequest = ServletUtils.toBean(UserRequest.class);

// 处理嵌套对象
// 假设参数：user.address.city=北京&user.address.street=朝阳区
UserWithAddress user = ServletUtils.fillBean(request, new UserWithAddress(), "user");

// 处理集合类型
// 假设参数：users[0].name=张三&users[1].name=李四
UserListWrapper userListWrapper = ServletUtils.fillBean(request, new UserListWrapper());
```

#### 响应处理

支持多种格式的响应输出：

```java
// 输出 JSON 数据
ServletUtils.renderString(response, JsonUtils.toJsonString(data));

// 文件下载示例
ServletUtils.setAttachmentResponseHeader(response, "data.xlsx");
ServletUtils.write(response, FileUtil.readBytes("file.xlsx"));
```

---

### 使用示例

#### 示例 1：处理分页参数

```java
// 获取分页参数
int pageNum = ServletUtils.getParameterToInt("pageNum", 1);
int pageSize = ServletUtils.getParameterToInt("pageSize", 10);

// 调用业务逻辑
PageResult<UserDTO> page = userService.queryUsers(pageNum, pageSize);
return R.ok(page);
```

#### 示例 2：文件下载

```java
@GetMapping("/download")
public void download(@RequestParam String fileName) {
    try {
        byte[] fileBytes = FileUtil.readBytes(fileName);
        ServletUtils.setAttachmentResponseHeader(response, fileName);
        ServletUtils.write(response, fileBytes);
    } catch (Exception e) {
        log.error("文件下载失败", e);
        ServletUtils.renderString(response, "文件下载失败");
    }
}
```

#### 示例 3：文件上传与表单处理

```java
@PostMapping("/upload")
public R<Void> upload(MultipartHttpServletRequest request) {
    MultipartFile file = request.getFile("file");
    if (file != null && !file.isEmpty()) {
        String filePath = fileService.saveFile(file);
        return R.ok("文件保存路径：" + filePath);
    }
    return R.fail("上传文件为空");
}
```

---

## RequestContextHolder 使用指南

### 概述

`RequestContextHolder` 是 Spring 提供的一个工具类，用于获取当前线程的请求上下文，特别适用于非 Controller 层（如 Service、Filter 等）获取请求信息。

### 使用场景

1. 在非 Controller 层（如 Filter、Service）中获取 `HttpServletRequest`。
2. 在异步任务中传递请求上下文（需手动设置线程上下文）。

### 示例

#### 获取当前请求

```java
HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
String clientIP = request.getRemoteAddr();
```

#### 异步处理请求上下文

在异步任务中需要手动传递请求上下文：

```java
RequestAttributes attributes = RequestContextHolder.getRequestAttributes();
executorService.submit(() -> {
    try {
        RequestContextHolder.setRequestAttributes(attributes);
        // 异步任务逻辑
    } finally {
        RequestContextHolder.resetRequestAttributes();
    }
});
```

---

## 注意事项

1. **避免滥用**：尽量在 Controller 层注入请求对象（如 `@RequestParam`、`@RequestBody` 等）而不是直接使用工具类。
2. **线程隔离**：在异步任务中使用 `RequestContextHolder` 时，需手动设置上下文，确保线程安全。
3. **编码一致性**：默认字符集为 UTF-8，确保请求和响应的编码一致。
4. **异常处理**：`ServletUtils` 提供了统一的异常处理机制，开发者可以扩展 `renderString` 方法以适配项目需求。

---

## 总结

`ServletUtils` 和 `RequestContextHolder` 为 Web 开发提供了强大的工具支持，帮助开发者简化代码，提高开发效率：

- **ServletUtils**：提供快速获取参数、自动填充对象、响应处理等功能。
- **RequestContextHolder**：在非 Web 层中获取请求上下文的最佳选择。

通过结合这两种工具，开发者可以轻松实现高效、优雅的 Web 应用开发。希望本指南能够帮助您更好地理解和使用这些工具！
```
