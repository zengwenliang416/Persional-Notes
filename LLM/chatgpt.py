#!/usr/bin/env python3
# coding: utf-8
import os
import json
import argparse
import openai
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

class ChatGPT:
    def __init__(self, api_key=None, model="gpt-3.5-turbo"):
        self.api_key = api_key or os.getenv("OPENAI_API_KEY")
        if not self.api_key:
            raise ValueError("API密钥未提供，请设置OPENAI_API_KEY环境变量或直接传入")
        
        self.client = openai.OpenAI(api_key=self.api_key)
        self.model = model
        self.messages = []
    
    def add_message(self, role, content):
        self.messages.append({"role": role, "content": content})
    
    def chat(self, message=None, stream=True):
        if message:
            self.add_message("user", message)
        
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=self.messages,
                stream=stream
            )
            
            if stream:
                collected_content = ""
                for chunk in response:
                    if chunk.choices[0].delta.content:
                        content = chunk.choices[0].delta.content
                        collected_content += content
                        print(content, end="", flush=True)
                print()
                self.add_message("assistant", collected_content)
                return collected_content
            else:
                content = response.choices[0].message.content
                self.add_message("assistant", content)
                return content
        except Exception as e:
            print(f"API调用错误: {e}")
            return None
    
    def save_conversation(self, filename="conversation.json"):
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(self.messages, f, ensure_ascii=False, indent=2)
    
    def load_conversation(self, filename="conversation.json"):
        if os.path.exists(filename):
            with open(filename, "r", encoding="utf-8") as f:
                self.messages = json.load(f)

def main():
    parser = argparse.ArgumentParser(description="ChatGPT 本地命令行工具")
    parser.add_argument("--key", help="OpenAI API密钥")
    parser.add_argument("--model", default="gpt-3.5-turbo", help="模型名称")
    parser.add_argument("--system", help="系统消息")
    parser.add_argument("--load", help="加载对话文件")
    parser.add_argument("--save", help="保存对话到文件")
    args = parser.parse_args()
    
    chatgpt = ChatGPT(api_key=args.key, model=args.model)
    
    if args.load:
        chatgpt.load_conversation(args.load)
    
    if args.system:
        chatgpt.add_message("system", args.system)
    
    print(f"使用模型: {args.model}")
    print("开始对话 (输入'exit'退出, 输入'save'保存对话):")
    
    try:
        while True:
            user_input = input("\n你: ")
            if user_input.lower() == "exit":
                break
            elif user_input.lower() == "save":
                save_file = args.save or input("保存文件名: ")
                chatgpt.save_conversation(save_file)
                print(f"对话已保存到 {save_file}")
                continue
            
            print("\nChatGPT: ", end="")
            chatgpt.chat(user_input)
    except KeyboardInterrupt:
        print("\n程序已中断")
    finally:
        if args.save:
            chatgpt.save_conversation(args.save)
            print(f"对话已保存到 {args.save}")

if __name__ == "__main__":
    main() 