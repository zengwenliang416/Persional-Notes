# 【ParaCPI】环境构建

## 前置条件

安装conda

## 环境构建命令

将此代码保存为 `setup.sh`，然后在终端中使用 `sh setup.sh` 或 `bash setup.sh` 来运行它。确保您已经正确安装了conda并且它已经在您的PATH环境变量中。

```shell
#!/bin/bash

# 停止脚本在遇到错误时继续执行
set -e

# 创建一个名为ParaCPI的conda环境，不会询问确认
conda create -n ParaCPI python=3.7.10 -y

# 激活环境
conda activate ParaCPI

# 安装PyTorch, torchvision和torchaudio
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu111

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

