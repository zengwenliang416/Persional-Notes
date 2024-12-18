# Markdown 文件处理工具

## 目录
- [1. 目录](#目录)
- [2. markdown_header_cleaner.py](#markdown_header_cleanerpy)
    - [作用](#作用)
    - [用法](#用法)
    - [示例](#示例)
- [3. markdown_toc_generator.py](#markdown_toc_generatorpy)
    - [作用](#作用)
    - [用法](#用法)
    - [示例](#示例)
- [4. 注意事项](#注意事项)



## markdown_header_cleaner.py

### 作用
这个脚本用于移除Markdown文件中标题的数字前缀。它可以处理单个文件或递归处理整个目录中的所有Markdown文件。

### 用法
1. 确保您的系统已安装Python 3。
2. 打开命令行界面，导航到脚本所在的目录。
3. 运行以下命令：
   ```
   python markdown_header_cleaner.py
   ```
4. 根据提示输入包含Markdown文件的目录路径。

### 示例
假设您有一个名为 `example.md` 的文件，内容如下：

```markdown
# 介绍

## 背景

### 历史

## 目的
```

运行脚本后，文件内容将变为：

```markdown
# 介绍

## 背景

### 历史

## 目的
```

## markdown_toc_generator.py

### 作用

这个脚本用于为Markdown文件生成目录（TOC）。它会在文件的第一个一级标题后插入目录，并为二级标题添加数字前缀。

### 用法
1. 确保您的系统已安装Python 3。
2. 打开命令行界面，导航到脚本所在的目录。
3. 运行以下命令：
   ```
   python markdown_toc_generator.py
   ```
4. 根据提示输入包含Markdown文件的目录路径。

### 示例
假设您有一个名为 `example.md` 的文件，内容如下：

```markdown
# 项目概述

## 介绍

### 背景

## 功能

### 主要功能

### 次要功能

## 技术栈
```

运行脚本后，文件内容将变为：

```markdown
# 项目概述

## 介绍

### 背景

## 功能

### 主要功能

### 次要功能

## 技术栈
```

## 注意事项

1. 这两个脚本会直接修改原文件，建议在使用前备份重要文件。
2. 脚本会递归处理指定目录下的所有 `.md` 文件，请确保选择正确的目录。
3. `markdown_toc_generator.py` 会自动删除已存在的旧目录（如果有的话）并生成新的目录。
4. 这些脚本假设Markdown文件使用标准的ATX风格标题（使用 `#` 符号）。

通过使用这两个工具，您可以轻松地清理Markdown文件的标题格式并为其生成清晰的目录结构，从而提高文档的可读性和导航性。