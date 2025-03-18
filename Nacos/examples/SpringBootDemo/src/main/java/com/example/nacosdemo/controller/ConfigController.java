package com.example.nacosdemo.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/config")
@RefreshScope // 支持配置动态刷新
public class ConfigController {

    @Value("${app.name:默认应用名}")
    private String appName;

    @Value("${app.version:1.0.0}")
    private String appVersion;
    
    @Value("${app.env:dev}")
    private String appEnv;
    
    @Value("${app.desc:这是一个Nacos配置示例}")
    private String appDesc;

    /**
     * 获取当前应用配置
     */
    @GetMapping
    public Map<String, Object> getConfig() {
        Map<String, Object> config = new HashMap<>();
        config.put("appName", appName);
        config.put("appVersion", appVersion);
        config.put("appEnv", appEnv);
        config.put("appDesc", appDesc);
        // 添加当前时间戳，验证配置是否实时刷新
        config.put("timestamp", System.currentTimeMillis());
        return config;
    }
} 