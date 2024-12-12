# ServletUtils 与 RequestContextHolder 使用指南

## 1. ServletUtils 工具类

### 1.1 概述
`ServletUtils` 是一个强大的 HTTP 请求和响应处理工具类，它继承自 Hutool 框架的 `JakartaServletUtil`。通过继承关系，`ServletUtils` 不仅具备了 Hutool 提供的基础功能，还扩展了更多实用的工具方法，使开发人员能够更便捷地处理 Web 请求、响应、会话管理等任务。

### 1.2 继承关系

#### 1.2.1 Hutool 的 JakartaServletUtil
`JakartaServletUtil` 是 Hutool 框架提供的 Servlet 工具类，提供以下核心功能：

- **请求包装**：包装 HttpServletRequest 对象
- **响应包装**：包装 HttpServletResponse 对象
- **请求参数处理**：处理 GET/POST 请求参数
- **文件上传处理**：处理 multipart 请求
- **Cookie 操作**：读写 Cookie
- **字符集处理**：处理请求和响应的字符集

```java
// Hutool JakartaServletUtil 示例
// 获取所有请求参数
Map<String, String[]> params = JakartaServletUtil.getParams(request);

// 获取客户端IP
String clientIP = JakartaServletUtil.getClientIP(request);

// 包装请求对象
ServletRequest wrapped = JakartaServletUtil.wrap(request, "UTF-8");
```

#### 1.2.2 ServletUtils 扩展功能
`ServletUtils` 在 `JakartaServletUtil` 的基础上扩展了以下功能：

```java
// Spring 集成
// 获取Spring管理的请求对象
HttpServletRequest springRequest = ServletUtils.getRequest();

// 获取Spring管理的响应对象
HttpServletResponse springResponse = ServletUtils.getResponse();

// 类型转换增强
// 支持多种数据类型的参数转换
Integer intValue = ServletUtils.getParameterToInt("pageSize", 10);
Long longValue = ServletUtils.getParameterToLong("id");
Boolean boolValue = ServletUtils.getParameterToBool("enabled", false);

// 响应处理增强
// JSON响应
ServletUtils.renderString(response, JsonUtils.toJsonString(result));

// 文件下载
ServletUtils.setAttachmentResponseHeader(response, "file.txt");
```

### 1.3 核心功能

#### 1.3.1 Bean 操作方法

##### fillBean 方法
`fillBean` 方法用于将请求参数填充到指定的 Bean 对象中。它支持复杂的参数映射，包括嵌套对象和集合类型。

```java
// 基础用法
UserQuery query = ServletUtils.fillBean(request, new UserQuery());

// 自定义参数前缀
// 假设参数为：user.name=张三&user.age=18
UserInfo userInfo = ServletUtils.fillBean(request, new UserInfo(), "user");

// 处理嵌套对象
// 参数：user.address.city=北京&user.address.street=朝阳区
UserWithAddress user = ServletUtils.fillBean(request, new UserWithAddress(), "user");

// 处理集合类型
// 参数：users[0].name=张三&users[1].name=李四
UserListWrapper wrapper = ServletUtils.fillBean(request, new UserListWrapper(), "");
```

特点：
- 支持属性自动类型转换
- 支持嵌套对象自动创建
- 支持数组和集合类型
- 可以指定参数前缀
- 忽略未知属性

##### toBean 方法
`toBean` 方法是 `fillBean` 的简化版本，用于快速将请求参数转换为指定类型的对象。

```java
// 基础用法
UserQuery query = ServletUtils.toBean(UserQuery.class);

// 带默认值的转换
UserQuery query = ServletUtils.toBean(UserQuery.class, new UserQuery());

// 实际应用示例
@PostMapping("/save")
public R<Void> save() {
    // 直接将请求参数转换为业务对象
    UserBO user = ServletUtils.toBean(UserBO.class);
    userService.save(user);
    return R.ok();
}
```

特点：
- 更简洁的 API
- 自动处理类型转换
- 支持默认值
- 适合简单对象转换

##### write 方法
`write` 方法用于向响应输出流写入数据，支持多种数据类型和格式。

```java
// 写入字符串
ServletUtils.write(response, "Hello World");

// 写入JSON对象
User user = new User("张三", 18);
ServletUtils.write(response, JsonUtils.toJsonString(user));

// 写入文件内容
ServletUtils.write(response, FileUtil.readBytes("file.txt"));

// 自定义响应头
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");
ServletUtils.write(response, jsonData);

// 下载文件示例
public void download(HttpServletResponse response) {
    try {
        // 设置响应头
        response.setContentType("application/octet-stream");
        ServletUtils.setAttachmentResponseHeader(response, "用户数据.xlsx");
        
        // 写入文件内容
        byte[] data = FileUtil.readBytes("path/to/file.xlsx");
        ServletUtils.write(response, data);
    } catch (Exception e) {
        // 处理异常
        ServletUtils.renderString(response, "下载失败");
    }
}
```

特点：
- 支持多种数据类型
- 自动处理字符编码
- 支持大文件写入
- 异常安全处理

#### 1.3.2 请求参数获取
```java
// 字符串参数
String value = ServletUtils.getParameter("paramName");
String defaultValue = ServletUtils.getParameter("paramName", "defaultValue");

// 整数参数
Integer intValue = ServletUtils.getParameterToInt("paramName");
Integer defaultInt = ServletUtils.getParameterToInt("paramName", 0);

// 布尔参数
Boolean boolValue = ServletUtils.getParameterToBool("paramName");
Boolean defaultBool = ServletUtils.getParameterToBool("paramName", false);

// 获取参数Map
Map<String, String[]> paramArrayMap = ServletUtils.getParams(request);
Map<String, String> paramMap = ServletUtils.getParamMap(request);
```

#### 1.3.3 请求/响应对象操作
```java
// 获取基础对象
HttpServletRequest request = ServletUtils.getRequest();
HttpServletResponse response = ServletUtils.getResponse();
HttpSession session = ServletUtils.getSession();

// 请求头处理
String headerValue = ServletUtils.getHeader(request, "headerName");
Map<String, String> headers = ServletUtils.getHeaders(request);

// 响应处理
ServletUtils.renderString(response, jsonString);
```

#### 1.3.4 请求信息处理
```java
// 客户端信息
String clientIP = ServletUtils.getClientIP();

// 请求类型判断
boolean isAjax = ServletUtils.isAjaxRequest(request);

// URL编解码
String encoded = ServletUtils.urlEncode("原始字符串");
String decoded = ServletUtils.urlDecode("编码后的字符串");
```

### 1.4 特性优势
- **继承增强**：继承 Hutool 的 `JakartaServletUtil`，保留原有功能的同时扩展新特性
- **Spring 集成**：与 Spring 框架深度集成，支持获取 Spring 管理的请求响应对象
- **类型转换**：支持多种数据类型的自动转换，包括 String、Integer、Long、Boolean 等
- **空值处理**：内置默认值机制，避免空指针异常
- **异常处理**：统一的异常处理机制，提高代码健壮性
- **编码支持**：统一使用 UTF-8 字符集，确保编码一致性

### 1.5 使用注意事项
1. 所有方法均为静态方法，可直接通过类名调用
2. 依赖于 Spring 的 RequestContextHolder，需在 Web 环境中使用
3. 继承自 Hutool 的方法优先使用 ServletUtils 的包装方法
4. Ajax 请求判断支持多种方式：
   - Accept 头包含 application/json
   - X-Requested-With 头包含 XMLHttpRequest
   - URI 以 .json 或 .xml 结尾
   - 请求参数 __ajax 值为 json 或 xml

## 2. RequestContextHolder

### 2.1 概述
`RequestContextHolder` 是 Spring 框架提供的用于存储请求上下文的持有者，它使得在应用程序的任何位置都能获取到当前请求的上下文信息。

### 2.2 主要用途
- 在非 Web 层组件中获取请求信息
- 实现请求上下文的线程隔离
- 支持异步请求处理

### 2.3 最佳实践
1. 优先使用 `ServletUtils` 封装的方法
2. 在异步环境下注意请求上下文的传递
3. 建议在 Controller 层直接注入 `HttpServletRequest` 而不是通过工具类获取
4. 在使用 Hutool 原生方法时，注意与 Spring 上下文的兼容性

## 3. 应用场景示例

### 3.1 参数处理
```java
// 处理分页参数
int pageNum = ServletUtils.getParameterToInt("pageNum", 1);
int pageSize = ServletUtils.getParameterToInt("pageSize", 10);

// 处理查询条件
String searchKey = ServletUtils.getParameter("searchKey");
if (StringUtils.isNotEmpty(searchKey)) {
    // 执行搜索逻辑
}
```

### 3.2 文件下载
```java
// 设置响应头
response.setContentType("application/octet-stream");
ServletUtils.setAttachmentResponseHeader(response, "filename.txt");

// 写入响应流
ServletUtils.renderString(response, content);
```

### 3.3 Ajax 请求处理
```java
if (ServletUtils.isAjaxRequest(request)) {
    // 返回 JSON 数据
    ServletUtils.renderString(response, JsonUtils.toJsonString(result));
} else {
    // 返回页面
    return "viewName";
}
```

### 3.4 Hutool 集成示例
```java
// 使用 Hutool 原生方法
String ip = JakartaServletUtil.getClientIP(request);

// 使用 ServletUtils 封装方法（推荐）
String ip = ServletUtils.getClientIP();

// 文件上传处理
UploadFile file = JakartaServletUtil.getMultipart(request).getFile("file");
String fileName = file.getFileName();

```

### 3.5 表单提交处理
```java
@PostMapping("/submit")
public R<Void> submit() {
    // 将表单数据转换为对象
    FormData formData = ServletUtils.fillBean(request, new FormData());
    
    // 处理文件上传
    MultipartFile file = ServletUtils.getMultipart(request).getFile("file");
    if (file != null) {
        formData.setFileName(file.getOriginalFilename());
    }
    
    // 业务处理
    formService.process(formData);
    return R.ok();
}
```

### 3.6 复杂查询条件处理
```java
@GetMapping("/search")
public R<PageVO<UserVO>> search() {
    // 转换查询参数
    UserQuery query = ServletUtils.toBean(UserQuery.class);
    
    // 处理分页参数
    Integer pageNum = ServletUtils.getParameterToInt("pageNum", 1);
    Integer pageSize = ServletUtils.getParameterToInt("pageSize", 10);
    
    // 执行查询
    PageVO<UserVO> result = userService.search(query, pageNum, pageSize);
    return R.ok(result);
}
```

### 3.7 文件下载处理
```java
@GetMapping("/export")
public void export() {
    try {
        // 生成导出数据
        byte[] excelData = exportService.generateExcel();
        
        // 设置响应头
        response.setContentType("application/vnd.ms-excel");
        ServletUtils.setAttachmentResponseHeader(response, "导出数据.xlsx");
        
        // 写入响应
        ServletUtils.write(response, excelData);
    } catch (Exception e) {
        // 异常处理
        ServletUtils.renderString(response, "导出失败：" + e.getMessage());
    }
}
