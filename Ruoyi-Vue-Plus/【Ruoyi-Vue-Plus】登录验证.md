# 【Ruoyi-Vue-Plus】登录验证

**一、前端部分**

`src/views/login.vue`文件中的生命钩子函数包括获取验证码、初始化租户列表以及从`localStorage`获取登录信息。

1. **获取验证码函数**：
   - `getCode`是一个异步函数，用于获取验证码图片。
   - 首先调用`getCodeImg`方法获取验证码图片响应，解构出响应数据。
   - 判断验证码是否启用，如果响应中的`captchaEnabled`未定义，则默认启用验证码。
   - 若验证码启用，设置验证码图片的 URL 为 Base64 编码形式，并设置登录表单的`uuid`。
   - 在组件挂载时（`onMounted`）调用`getCode`函数，触发获取验证码的操作。
2. **初始化租户列表和获取登录信息**：
   - 在组件挂载时，还会调用`initTenantList`和`getLoginData`函数分别进行初始化租户列表和从`localStorage`获取登录信息的操作。

**二、后端接口部分**

1. 生成验证码接口：
   - `@GetMapping("/auth/code")`注解表示该方法处理`/auth/code`路径的 GET 请求。
   - 首先创建一个`CaptchaVo`对象，用于存储验证码信息。
   - 判断验证码是否启用，如果未启用，设置`captchaVo`的`captchaEnabled`为`false`并直接返回。
   - 如果启用验证码，生成一个唯一的 UUID，创建验证码的键值对，根据验证码类型和长度创建验证码生成器，并生成验证码。
   - 如果是数学验证码，使用 SpEL 表达式处理验证码结果。
   - 将验证码信息保存到 Redis 中，并设置`captchaVo`的`uuid`和`img`属性，最后返回包含验证码信息的响应。

**三、接口调用关系**

前端`src/views/login.vue`文件中的`getCode`函数调用了后端接口`src/api/login.ts`中的`getCodeImg`方法，该方法向`/auth/code`路径发送请求，后端通过`@GetMapping("/auth/code")`注解的方法处理该请求，并返回验证码信息，前端根据响应结果进行相应的处理，设置验证码的显示和登录表单的属性。



## PS：

登录后采用SSE发送消息到前端呈现内容

```java
        ......
				// 使用ScheduledExecutorService安排一个任务在指定延迟后执行
        scheduledExecutorService.schedule(() -> {
            // 创建一个新的SseMessageDto对象，用于构建服务器发送事件（SSE）消息
            SseMessageDto dto = new SseMessageDto();
            // 设置消息内容为欢迎登录信息
            dto.setMessage("欢迎登录RuoYi-Vue-Plus后台管理系统");
            // 设置消息接收者用户ID列表，仅包含当前用户ID
            dto.setUserIds(List.of(userId));
            // 发布SSE消息
            SseMessageUtils.publishMessage(dto);
        }, 5, TimeUnit.SECONDS);
				......
```

