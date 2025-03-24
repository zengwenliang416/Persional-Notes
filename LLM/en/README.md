# 🤖 Local ChatGPT Script

This script allows you to interact with ChatGPT via command line locally, without opening a browser to use the powerful AI assistant.

[中文文档](../README.md)

## 🚀 Features

- 🔑 API key configuration support (environment variables or direct parameter)
- 💬 Real-time streaming response
- 📝 Save and load conversation history
- 🛠️ Customizable system prompts
- 🔄 Support for multiple models

## 📋 Prerequisites

1. OpenAI API key (https://platform.openai.com/api-keys)
2. Python 3.6+

## 📦 Installation

```bash
1 # Create and activate virtual environment
2 python3 -m venv chatgpt_env
3 source chatgpt_env/bin/activate
4 # Install dependencies
5 pip install openai python-dotenv
```

## 🔧 Configuration

There are two ways to configure the API key:

1. Create a `.env` file with the following content:

```
1 OPENAI_API_KEY=your_openai_api_key
```

2. Pass it via command line:

```bash
1 python chatgpt.py --key your_openai_api_key
```

## 📝 Usage

### Basic Usage

```bash
1 # Make sure you're in the LLM directory
2 cd LLM
3 # Activate virtual environment
4 source chatgpt_env/bin/activate
5 # Run the script
6 python chatgpt.py
```

### Advanced Options

```bash
1 python chatgpt.py --model gpt-4 --system "You are a helpful AI assistant" --save conversation.json
```

Parameters:
- `--key`: OpenAI API key (uses environment variable if not provided)
- `--model`: Model name (default: gpt-3.5-turbo)
- `--system`: System prompt
- `--load`: Load conversation history file
- `--save`: Save conversation to specified file

## 💡 In-conversation Commands

- Type `exit` to quit the program
- Type `save` to manually save the current conversation

## 📜 Example

```
Using model: gpt-3.5-turbo
Starting conversation (type 'exit' to quit, 'save' to save the conversation):

You: Hello, what can you do?

ChatGPT: Hello! I'm an AI assistant that can help you with answering questions, providing information, engaging in conversation, and more. Here are some things I can do:

1. Answer knowledge-based questions
2. Provide creative ideas and inspiration
3. Help with writing and optimizing text
4. Explain complex concepts
5. Offer suggestions and opinions
6. Assist with learning and research
7. Perform simple calculations
8. Discuss various topics

Is there something specific you'd like help with?

You: exit
``` 