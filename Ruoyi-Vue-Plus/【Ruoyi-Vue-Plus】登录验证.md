# 【Ruoyi-Vue-Plus】登录验证

## 目录

[1. 目录](#目录)

[2. PS：](#ps)



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

