import os
import re
import logging
from typing import List, Tuple

# 配置日志记录
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def remove_number_prefix_from_headers(content: str) -> str:
    """
    从markdown标题中去除数字前缀，包括数字、点和多余的空格
    
    参数:
    content (str): 包含markdown内容的字符串
    
    返回:
    str: 处理后的markdown内容，标题中的数字前缀已被移除
    """
    # 正则表达式匹配标题行，捕获标题级别和内容，忽略数字前缀
    pattern = re.compile(r'^(#{1,6})\s*(?:\d+(?:\.\d*)*\s*)*(.+)$', re.MULTILINE)
    # 使用捕获的组替换匹配的内容，保留标题级别和内容，去除数字前缀
    new_content = pattern.sub(r'\1 \2', content)
    return new_content

def extract_headers(content: str) -> List[Tuple[int, str]]:
    """
    提取markdown文件中的标题，忽略代码块中的内容
    
    参数:
    content (str): markdown文件的内容
    
    返回:
    List[Tuple[int, str]]: 包含标题级别和标题文本的元组列表
    """
    headers = []
    lines = content.splitlines()
    in_code_block = False
    code_fence_pattern = None  # 记录当前代码块的分隔符
    
    for i, line in enumerate(lines):
        stripped_line = line.strip()
        
        # 检查代码块标记
        if stripped_line.startswith('```') or stripped_line.startswith('~~~'):
            # 获取当前行使用的分隔符
            current_fence = '```' if stripped_line.startswith('```') else '~~~'
            
            if not in_code_block:
                # 进入代码块
                in_code_block = True
                code_fence_pattern = current_fence
            elif code_fence_pattern == current_fence:
                # 只有当遇到相同的分隔符时才结束代码块
                in_code_block = False
                code_fence_pattern = None
            continue
            
        # 跳过代码块中的内容
        if in_code_block:
            continue
            
        # 检查是否是标题行
        if stripped_line.startswith('#'):
            # 确保这不是代码块中的标题
            is_in_example = False
            # 向上查找最近的非空行
            for prev_line in reversed(lines[:i]):
                prev_stripped = prev_line.strip()
                if prev_stripped:  # 找到最近的非空行
                    # 检查是否在示例部分
                    if any(keyword in prev_stripped.lower() for keyword in ['示例', 'example']):
                        is_in_example = True
                    break
                    
            if not is_in_example:  # 只处理非示例部分的标题
                match = re.match(r'^(#{1,6})\s+(.+)$', stripped_line)
                if match:
                    level = len(match.group(1))
                    title = match.group(2).strip()
                    headers.append((level, title))
    
    return headers

def generate_toc(headers: List[Tuple[int, str]]) -> str:
    """
    生成美观的目录，为二级标题及其子标题添加数字前缀
    
    参数:
    headers (List[Tuple[int, str]]): 包含标题级别和标题文本的元组列表
    
    返回:
    str: 生成的目录字符串
    """
    toc = ["## 目录\n"]
    h2_counter = 0
    h3_counter = 0
    for level, title in headers:
        if level == 2:
            h2_counter += 1
            h3_counter = 0
            prefix = f"{h2_counter}. "
            link = re.sub(r'[^\w\s-]', '', title).strip().replace(" ", "-").lower()
            toc.append(f"- [{prefix}{title}](#{link})\n")
        elif level > 2:
            h3_counter += 1
            indent = "    " * (level - 2)
            prefix = f"{h2_counter}.{h3_counter} " if level == 3 else "    " * (level - 3)
            link = re.sub(r'[^\w\s-]', '', title).strip().replace(" ", "-").lower()
            toc.append(f"{indent}- [{prefix}{title}](#{link})\n")
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
        logging.info("已删除旧的目录")
    else:
        logging.info("未找到旧的目录")
    
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
    处理单个文件，去除标题中的数字前缀并生成目录
    
    参数:
    file_path (str): 要处理的markdown文件路径
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
        
        logging.info(f"\n处理文件：{file_path}")
        logging.debug("原始内容前100个字符：")
        logging.debug(content[:100])
        
        # 去除标题中的数字前缀
        content = remove_number_prefix_from_headers(content)
        
        # 提取标题并生成目录
        headers = extract_headers(content)
        toc = generate_toc(headers)
        new_content = insert_toc(content, toc)
        
        logging.debug("处理后内容前100个字符：")
        logging.debug(new_content[:100])
        
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(new_content)
    except Exception as e:
        logging.error(f"处理文件 {file_path} 时出错: {e}")

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
    logging.info("\n所有文件处理完成！")

if __name__ == "__main__":
    main()