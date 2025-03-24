# 【LLM】ChatGPT本地调用脚本 🤖

本文档介绍如何使用本地脚本调用ChatGPT API。

[English Documentation](en/【LLM】ChatGPT%20Local%20Script.md)

## 📋 项目结构

```
LLM/
├── chatgpt.py          # 主脚本文件
├── .env                # 环境变量配置文件
├── README.md           # 中文文档
├── en/
│   └── README.md       # 英文文档
└── chatgpt_env/        # Python虚拟环境
```

## 🚀 快速开始

### 1. 设置环境

```bash
1 # 进入LLM目录
2 cd LLM
3 
4 # 激活虚拟环境
5 source chatgpt_env/bin/activate
```

### 2. 配置API密钥

编辑`.env`文件:

```bash
1 # 将你的OpenAI API密钥添加到.env文件
2 echo "OPENAI_API_KEY=你的OpenAI密钥" > .env
```

### 3. 运行脚本

```bash
1 python chatgpt.py
```

## 💡 进阶用法

### 使用不同模型

```bash
1 python chatgpt.py --model gpt-4
```

### 添加系统提示

```bash
1 python chatgpt.py --system "你是一个专业的代码助手，精通Python编程"
```

### 保存和加载对话

```bash
1 # 保存对话
2 python chatgpt.py --save my_conversation.json
3 
4 # 加载上次的对话继续
5 python chatgpt.py --load my_conversation.json
```

## 🔧 脚本特性

1. **实时流式输出** - 像ChatGPT网页版一样逐字显示回答
2. **历史记录管理** - 支持保存和恢复对话历史
3. **自定义系统提示** - 设置特定角色或指令
4. **模型选择** - 支持所有OpenAI聊天模型
5. **简单易用** - 直观的命令行界面

## 📚 使用场景

- 快速获取编程帮助
- 离线文本处理和生成
- 批处理脚本中集成AI能力
- 在终端中进行知识查询

---

更详细的使用说明请参考[README文档](README.md)。 