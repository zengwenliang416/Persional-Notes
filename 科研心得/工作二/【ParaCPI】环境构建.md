# 【ParaCPI】环境构建

## 前置条件

安装conda并创建虚拟环境

```shell
# 创建一个名为ParaCPI的conda环境，不会询问确认
conda create -n ParaCPI python=3.7.10 -y

# 激活环境
conda activate ParaCPI
```

## 环境构建命令

将此代码保存为 `setup.sh`，然后在终端中使用 `sh setup.sh` 或 `bash setup.sh` 来运行它。确保您已经正确安装了conda并且它已经在您的PATH环境变量中。

```shell
#!/bin/bash

# 停止脚本在遇到错误时继续执行
set -e

# 安装PyTorch, torchvision和torchaudio
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu111

# 安装对应版本的torch_spline_conv、torch_sparse、torch_scatter和torch_cluster，补充资料中有下载lun
pip install torch_*

# 安装torch_geometric
pip install torch_geometric==2.0.4

# 安装rdkit, pandas和networkx
pip install rdkit pandas networkx

# 告诉用户安装完成
echo "Environment setup complete."

```

请确保该脚本具有可执行权限，如果没有，您可以通过运行以下命令来给予脚本执行权限：

```shell
chmod +x setup.sh
```

然后您可以通过下面的命令来运行它：

```
./setup.sh
```

## 补充资料

安装失败大多是版本不匹配的问题

### pytorch-geometric依赖库

https://pytorch-geometric.com/whl/

### pytorch安装指南

https://pytorch.org/get-started/locally/

## 数据处理

### human

```shell
#!/bin/bash

# 确保脚本在遇到错误时终止执行
set -e

# 定义函数进行预处理
preprocess() {
    python preprocessing_human.py --dataset "$1"
}

# 42系列的fold
preprocess data/human/raw/42/fold_2
preprocess data/human/raw/42/fold_3
preprocess data/human/raw/42/fold_4
preprocess data/human/raw/42/fold_5

# 52系列的fold
preprocess data/human/raw/52/fold_1
preprocess data/human/raw/52/fold_2
preprocess data/human/raw/52/fold_3
preprocess data/human/raw/52/fold_4
preprocess data/human/raw/52/fold_5

# 62系列的fold
preprocess data/human/raw/62/fold_1
preprocess data/human/raw/62/fold_2
preprocess data/human/raw/62/fold_3
preprocess data/human/raw/62/fold_4
preprocess data/human/raw/62/fold_5

echo "预处理完成。"
```

### celegans

```shell
#!/bin/bash

# Exit immediately if any command exits with a non-zero status.
set -e

# Function to preprocess a single dataset fold.
preprocess_fold() {
    python preprocessing_celegans.py --dataset "$1"
}

# Preprocess all the folds for the 42 series.
preprocess_fold data/celegans/raw/42/fold_1
preprocess_fold data/celegans/raw/42/fold_2
preprocess_fold data/celegans/raw/42/fold_3
preprocess_fold data/celegans/raw/42/fold_4
preprocess_fold data/celegans/raw/42/fold_5

# Preprocess all the folds for the 52 series.
preprocess_fold data/celegans/raw/52/fold_1
preprocess_fold data/celegans/raw/52/fold_2
preprocess_fold data/celegans/raw/52/fold_3
preprocess_fold data/celegans/raw/52/fold_4
preprocess_fold data/celegans/raw/52/fold_5

# Preprocess all the folds for the 62 series.
preprocess_fold data/celegans/raw/62/fold_1
preprocess_fold data/celegans/raw/62/fold_2
preprocess_fold data/celegans/raw/62/fold_3
preprocess_fold data/celegans/raw/62/fold_4
preprocess_fold data/celegans/raw/62/fold_5

echo "Preprocessing for all C. elegans dataset folds is complete."
```



## 模型训练

### human

```shell
#!/bin/bash

# 当任何语句的执行结果不是true时应该终止shell脚本
set -e

# 函数定义，用于执行训练命令
train() {
    python train_human.py --dataset "$1"
}

# 针对每个fold运行训练命令
# 42系列的fold
train human/raw/42/fold_2
train human/raw/42/fold_3
train human/raw/42/fold_4
train human/raw/42/fold_5

# 52系列的fold
train human/raw/52/fold_1
train human/raw/52/fold_2
train human/raw/52/fold_3
train human/raw/52/fold_4
train human/raw/52/fold_5

# 62系列的fold
train human/raw/62/fold_1
train human/raw/62/fold_2
train human/raw/62/fold_3
train human/raw/62/fold_4
train human/raw/62/fold_5

echo "所有fold的训练已完成。"
```

### celegans

```shell
#!/bin/bash

# Exit if any command fails
set -e

# Define a function for training a specific dataset fold
train_fold() {
    python train_celegans.py --dataset "$1"
}

# Train all folds for dataset series 42
train_fold celegans/raw/42/fold_1
train_fold celegans/raw/42/fold_2
train_fold celegans/raw/42/fold_3
train_fold celegans/raw/42/fold_4
train_fold celegans/raw/42/fold_5

# Train all folds for dataset series 52
train_fold celegans/raw/52/fold_1
train_fold celegans/raw/52/fold_2
train_fold celegans/raw/52/fold_3
train_fold celegans/raw/52/fold_4
train_fold celegans/raw/52/fold_5

# Train all folds for dataset series 62
train_fold celegans/raw/62/fold_1
train_fold celegans/raw/62/fold_2
train_fold celegans/raw/62/fold_3
train_fold celegans/raw/62/fold_4
train_fold celegans/raw/62/fold_5

echo "Training on all C. elegans dataset folds is complete."
```

## 文件下载

在Ubuntu中，要删除所有名为`model`的文件夹及其包含的内容，你可以使用`find`命令结合`rm`命令。以下是一个命令行示例，它会在当前目录及其所有子目录中查找名为`model`的文件夹，并删除它们：

```bash
find . -type d -name 'model' -exec rm -rf {} +
```

解释：
- `find`: 这是用来查找文件的命令。
- `.`: 表示当前目录。
- `-type d`: 表示只查找目录类型。
- `-name 'model'`: 查找名为`model`的目录。
- `-exec`: 对找到的每个目录执行紧随其后的命令。
- `rm -rf {}`: 删除找到的目录及其所有内容，`{}`是`find`命令找到的目录名的占位符。
- `+`: 表示结束`-exec`命令的参数列表。

**警告：`rm -rf`命令将不会提示你确认，并且删除的目录和内容都不可恢复。请确保你要删除的确实是这些目录，使用此命令前最好进行双重检查。**

如果你想首先确认将要删除的目录，可以先运行：

```bash
find . -type d -name 'model'
```

这将只列出所有名为`model`的目录而不删除它们。如果你确认这些是你想要删除的目录，那么可以运行上面的删除命令。