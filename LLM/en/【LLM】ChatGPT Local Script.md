# 【LLM】ChatGPT Local Script 🤖

This document explains how to use a local script to call the ChatGPT API.

[中文文档](../【LLM】ChatGPT本地调用脚本.md)

## 📋 Project Structure

```
LLM/
├── chatgpt.py          # Main script file
├── .env                # Environment variables configuration
├── README.md           # Chinese documentation
├── en/
│   └── README.md       # English documentation
└── chatgpt_env/        # Python virtual environment
```

## 🚀 Quick Start

### 1. Set Up Environment

```bash
1 # Navigate to LLM directory
2 cd LLM
3 
4 # Activate virtual environment
5 source chatgpt_env/bin/activate
```

### 2. Configure API Key

Edit the `.env` file:

```bash
1 # Add your OpenAI API key to the .env file
2 echo "OPENAI_API_KEY=your_openai_api_key" > .env
```

### 3. Run the Script

```bash
1 python chatgpt.py
```

## 💡 Advanced Usage

### Using Different Models

```bash
1 python chatgpt.py --model gpt-4
```

### Adding System Prompts

```bash
1 python chatgpt.py --system "You are a professional code assistant specialized in Python programming"
```

### Saving and Loading Conversations

```bash
1 # Save conversation
2 python chatgpt.py --save my_conversation.json
3 
4 # Load previous conversation
5 python chatgpt.py --load my_conversation.json
```

## 🔧 Script Features

1. **Real-time Streaming Output** - Shows responses character by character like the ChatGPT web interface
2. **History Management** - Support for saving and restoring conversation history
3. **Custom System Prompts** - Set specific roles or instructions
4. **Model Selection** - Supports all OpenAI chat models
5. **User-friendly** - Intuitive command line interface

## 📚 Use Cases

- Quick programming assistance
- Offline text processing and generation
- Integrating AI capabilities in batch scripts
- Knowledge queries in the terminal

---

For more detailed instructions, please refer to the [README documentation](README.md). 