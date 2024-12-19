# Markdown 文件处理脚本使用说明

## 目录
- [1. 简介](#简介)
- [2. 安装依赖](#安装依赖)
- [3. 使用方法](#使用方法)
    - [3.1 运行脚本](#运行脚本)
- [4. 脚本功能详解](#脚本功能详解)
    - [4.1 去除标题中的数字前缀](#去除标题中的数字前缀)
    - [4.2 生成目录](#生成目录)
- [5. 代码结构](#代码结构)
    - [5.1 主要函数](#主要函数)
- [6. 示例](#示例)
    - [6.1 原始文件示例](#原始文件示例)
    - [6.2 处理后文件示例](#处理后文件示例)
- [7. 注意事项](#注意事项)
- [8. 联系方式](#联系方式)



## 简介

本脚本用于处理Markdown文件，主要功能包括：
1. 去除Markdown标题中的数字前缀。
2. 生成美观的目录，并将其插入到文档中。

## 安装依赖

本脚本使用Python编写，确保你的系统已安装Python 3。你可以通过以下命令安装所需的依赖：

```sh
pip install -r requirements.txt
```

`requirements.txt` 文件内容如下：

```
logging
re
os
```

## 使用方法

### 运行脚本

1. **克隆或下载脚本**：
   将脚本文件 `[process_markdown.py](/Scripts/process_markdown.py)` 下载到你的本地机器上。

2. **运行脚本**：
   打开终端或命令行工具，导航到脚本所在的目录，然后运行以下命令：

   ```sh
   python process_markdown.py
   ```

3. **输入目录路径**：
   脚本会提示你输入Markdown文件所在的目录路径。例如：

   ```sh
   请输入Markdown文件所在的目录路径：/path/to/your/markdown/files
   ```

4. **查看处理结果**：
   脚本会递归处理指定目录及其子目录中的所有Markdown文件，并在处理完成后输出提示信息。

## 脚本功能详解

### 去除标题中的数字前缀

脚本会遍历Markdown文件中的所有标题，去除标题中的数字前缀。例如：

- 原始标题：`# 1.1 1.1.1 15.24 示例`
- 处理后标题：`# 示例`

### 生成目录

脚本会提取Markdown文件中的所有标题，并生成一个美观的目录。目录会自动插入到文档中第一个一级标题之后。例如：

```markdown
# 文档标题

## 代码结构

### 主要函数

1. **`remove_number_prefix_from_headers(content: str) -> str`**：
   - **参数**：`content` (str) - 包含Markdown内容的字符串。
   - **返回**：处理后的Markdown内容，标题中的数字前缀已被移除。

2. **`extract_headers(content: str) -> List[Tuple[int, str]]`**：
   - **参数**：`content` (str) - Markdown文件的内容。
   - **返回**：包含标题级别和标题文本的元组列表。

3. **`generate_toc(headers: List[Tuple[int, str]]) -> str`**：
   - **参数**：`headers` (List[Tuple[int, str]]) - 包含标题级别和标题文本的元组列表。
   - **返回**：生成的目录字符串。

4. **`remove_existing_toc(content: str) -> Tuple[str, bool]`**：
   - **参数**：`content` (str) - Markdown文件的内容。
   - **返回**：删除目录后的内容和是否找到并删除了目录的标志。

5. **`insert_toc(content: str, toc: str) -> str`**：
   - **参数**：`content` (str) - Markdown文件的内容；`toc` (str) - 生成的目录。
   - **返回**：插入目录后的新内容。

6. **`process_file(file_path: str)`**：
   - **参数**：`file_path` (str) - 要处理的Markdown文件路径。
   - **功能**：读取文件内容，去除标题中的数字前缀，生成目录，并将处理后的内容写回文件。

7. **`process_directory(directory: str)`**：
   - **参数**：`directory` (str) - 要处理的目录路径。
   - **功能**：递归处理指定目录及其子目录中的所有Markdown文件。

8. **`main()`**：
   - **功能**：程序的入口点，获取用户输入的目录路径，调用 `process_directory` 处理所有文件，并在完成后输出提示信息。

## 示例

假设你有一个目录 `/path/to/your/markdown/files`，其中包含多个Markdown文件。运行脚本后，脚本会处理这些文件，去除标题中的数字前缀，并生成目录。

### 原始文件示例

```markdown
# 文档标题

## 第一章

### 第一节

### 第二节

## 第二章

### 第一节
```

### 处理后文件示例

```markdown
# 文档标题

## 第一章

### 第一节

### 第二节

## 第二章

### 第一节
```

## 注意事项

1. **备份文件**：在运行脚本之前，建议备份原始文件，以防止意外的数据丢失。
2. **文件编码**：确保Markdown文件的编码为UTF-8，以避免字符乱码问题。

## 联系方式

如果有任何问题或建议，请联系 [wenliang_zeng416@163.com]。

---

