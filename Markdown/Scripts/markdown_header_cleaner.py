import os
import re

def remove_number_prefix_from_headers(content: str) -> str:
    """
    从markdown标题中去除数字前缀，包括数字、点和多余的空格
    
    参数:
    content (str): 包含markdown内容的字符串
    
    返回:
    str: 处理后的markdown内容，标题中的数字前缀已被移除
    """
    # 正则表达式匹配标题行，捕获标题级别和内容，忽略数字前缀
    pattern = re.compile(r'^(#{1,6})\s*(?:\d+\.?)*\s*\.?\s*(.+)$', re.MULTILINE)
    # 使用捕获的组替换匹配的内容，保留标题级别和内容，去除数字前缀
    new_content = pattern.sub(r'\1 \2', content)
    return new_content

def process_file(file_path: str):
    """
    处理单个文件，去除标题中的数字前缀
    
    参数:
    file_path (str): 要处理的markdown文件的路径
    """
    # 读取文件内容
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    print(f"\n处理文件：{file_path}")
    print("原始内容示例：")
    print(content.split('\n')[0:3])  # 打印前三行作为示例
    
    # 调用函数去除标题中的数字前缀
    new_content = remove_number_prefix_from_headers(content)
    
    print("处理后内容示例：")
    print(new_content.split('\n')[0:3])  # 打印前三行作为示例
    
    # 将处理后的内容写回文件
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(new_content)

def process_directory(directory: str):
    """
    递归处理目录及其子目录中的所有markdown文件
    
    参数:
    directory (str): 要处理的目录路径
    """
    # 遍历目录及其子目录
    for root, dirs, files in os.walk(directory):
        for file in files:
            # 只处理.md后缀的文件
            if file.endswith(".md"):
                file_path = os.path.join(root, file)
                process_file(file_path)

def main():
    """
    主函数，程序的入口点
    """
    # 获取用户输入的目录路径
    directory = input("请输入Markdown文件所在的目录路径：")
    # 处理指定目录
    process_directory(directory)
    print("\n所有文件处理完成！")

if __name__ == "__main__":
    # 当脚本作为主程序运行时，执行main函数
    main()
