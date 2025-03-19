# Dify 学习与部署文档 🚀

> Dify是一个强大的LLMOps平台，帮助构建基于大语言模型的应用程序。本目录包含Dify相关的学习笔记和部署指南。

## 目录内容 📑

- [部署文档](部署文档.md) - Dify的完整部署流程指南，包括环境准备、安装步骤和常见问题解决
- [Docker-Compose详解](Docker-Compose详解.md) - 详细解析Dify的docker-compose.yaml配置文件，帮助理解各组件的作用和关系

## 多语言支持 🌐

所有文档均提供中英文双语版本：
- 中文版：直接位于当前目录
- 英文版：位于[en](en/)子目录

## Git提交规范 📝

提交Dify相关文档时，请遵循以下格式：
```
<类型>(英文): <表情>: <提交描述>(中文)
```

常用类型与表情对应关系：
- `feat` (新功能): ✨
- `fix` (修复): 🐛
- `docs` (文档): 📝
- `style` (格式): 💄
- `refactor` (重构): ♻️
- `perf` (性能优化): ⚡️
- `test` (测试): ✅
- `chore` (构建/工具): 🔧

示例：
```
docs(en): 📝: 更新部署文档中的环境配置说明
feat(core): ✨: 添加自定义向量数据库支持
```

## 部署环境要求 💻

- **硬件要求**：至少2 CPU核心、4GB内存
- **软件要求**：Docker和Docker Compose
- **网络要求**：稳定的网络连接，需要下载镜像

## 相关链接 🔗

- [Dify官方文档](https://docs.dify.ai/)
- [Dify GitHub仓库](https://github.com/langgenius/dify)
- [English Documentation](en/README.md) 