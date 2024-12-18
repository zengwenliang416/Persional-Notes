import os
import re
from typing import List, Tuple

def extract_headers(content: str) -> List[Tuple[int, str]]:
    """
    提取markdown文件中的标题，忽略代码块中的内容
    
    参数:
    content (str): markdown文件的内容
    
    返回:
    List[Tuple[int, str]]: 包含标题级别和标题文本的元组列表
    """
    # 移除代码块中的所有内容
    content_without_code = re.sub(r'```.*?```', '', content, flags=re.DOTALL)

    # 使用正则表达式匹配markdown标题
    pattern = re.compile(r'^(#{1,6})\s+(.+)$', re.MULTILINE)
    # 返回标题级别（#的数量）和标题文本的元组列表
    return [(len(match.group(1)), match.group(2).strip()) for match in pattern.finditer(content_without_code)]

def generate_toc(headers: List[Tuple[int, str]]) -> str:
    """
    生成美观的目录，为二级标题添加数字前缀
    
    参数:
    headers (List[Tuple[int, str]]): 包含标题级别和标题文本的元组列表
    
    返回:
    str: 生成的目录字符串
    """
    toc = ["## 目录\n"]
    h2_counter = 0
    for level, title in headers:
        if level == 2:
            h2_counter += 1
            prefix = f"{h2_counter}. "
            # 生成标题的链接
            link = re.sub(r'[^\w\s-]', '', title).strip().replace(" ", "-").lower()
            toc.append(f"- [{prefix}{title}](#{link})\n")
        elif level > 2:
            # 为更深层次的标题添加缩进
            indent = "    " * (level - 2)
            link = re.sub(r'[^\w\s-]', '', title).strip().replace(" ", "-").lower()
            toc.append(f"{indent}- [{title}](#{link})\n")
    toc.append("\n")  # 添加空行以提高可读性
    return "".join(toc)

def remove_existing_toc(content: str) -> Tuple[str, bool]:
    """
    删除已有的目录，直到下一个二级标题
    
    参数:
    content (str): markdown文件的内容
    
    返回:
    Tuple[str, bool]: 删除目录后的内容和是否找到并删除了目录的标志
    """
    lines = content.split('\n')
    new_lines = []
    skip = False
    toc_found = False
    for line in lines:
        if line.strip() == "## 目录":
            skip = True
            toc_found = True
        elif skip and line.startswith('## '):
            skip = False
        
        if not skip:
            new_lines.append(line)
    
    return '\n'.join(new_lines), toc_found

def insert_toc(content: str, toc: str) -> str:
    """
    将目录插入到文档中
    
    参数:
    content (str): markdown文件的内容
    toc (str): 生成的目录
    
    返回:
    str: 插入目录后的新内容
    """
    content, toc_found = remove_existing_toc(content)  # 删除旧的目录
    if toc_found:
        print("已删除旧的目录")
    else:
        print("未找到旧的目录")
    
    # 在第一个一级标题后插入目录
    pattern = re.compile(r'^# .+\n', re.MULTILINE)
    match = pattern.search(content)
    if match:
        insert_position = match.end()
        return content[:insert_position] + "\n" + toc + "\n" + content[insert_position:]
    else:
        return toc + "\n" + content

def process_file(file_path: str):
    """
    处理单个文件
    
    参数:
    file_path (str): 要处理的markdown文件路径
    """
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    print(f"\n处理文件：{file_path}")
    print("原始内容前100个字符：")
    print(content[:100])
    
    headers = extract_headers(content)
    toc = generate_toc(headers)
    new_content = insert_toc(content, toc)
    
    print("处理后内容前100个字符：")
    print(new_content[:100])
    
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(new_content)

def process_directory(directory: str):
    """
    递归处理目录及其子目录
    
    参数:
    directory (str): 要处理的目录路径
    """
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".md"):
                file_path = os.path.join(root, file)
                process_file(file_path)

def main():
    """
    主函数，程序的入口点
    """
    directory = input("请输入Markdown文件所在的目录路径：")
    process_directory(directory)
    print("\n所有文件处理完成！")

if __name__ == "__main__":
    main()
