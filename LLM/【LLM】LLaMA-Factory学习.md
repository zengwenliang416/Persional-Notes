# LLaMA-Factory 学习指南

## 目录

[1. 目录](#目录)

[2. 一、基础介绍](#一基础介绍)

- [2.1 主要特点](#主要特点)

[3. 二、环境配置](#二环境配置)

- [3.1 基本要求](#基本要求)

- [3.2 安装步骤](#安装步骤)

[4. 三、模型训练](#三模型训练)

- [4.1 数据准备](#数据准备)

- [4.2 训练配置](#训练配置)

- [4.3 训练监控](#训练监控)

[5. 四、模型评估](#四模型评估)

- [5.1 评估方法](#评估方法)

- [5.2 评估指标](#评估指标)

[6. 五、模型导出](#五模型导出)

- [6.1 模型合并](#模型合并)

- [6.2 格式转换](#格式转换)

[7. 六、部署优化](#六部署优化)

- [7.1 性能优化](#性能优化)

- [7.2 服务部署](#服务部署)

[8. 七、最佳实践](#七最佳实践)

- [8.1 训练技巧](#训练技巧)

- [8.2 常见问题](#常见问题)

[9. 八、参考资源](#八参考资源)

- [9.1 官方资源](#官方资源)



## 一、基础介绍

LLaMA-Factory是一个强大的语言模型训练和微调工具包，支持多种模型和训练方法。

### 主要特点

1. **广泛的模型支持**
   - LLaMA/LLaMA2
   - Qwen/Qwen2
   - Baichuan/Baichuan2
   - ChatGLM/ChatGLM2/ChatGLM3
   - 其他开源模型

2. **多样化训练方法**
   - 全参数微调
   - LoRA/QLoRA
   - P-Tuning v2
   - 预训练

3. **数据处理能力**
   - 多格式数据支持
   - 数据清洗和预处理
   - 数据增强

## 二、环境配置

### 基本要求

```bash
# 系统要求
Python >= 3.8
CUDA >= 11.7 (推荐)
RAM >= 16GB
```

### 安装步骤

```bash
# 克隆仓库
git clone https://github.com/hiyouga/LLaMA-Factory.git
cd LLaMA-Factory

# 创建虚拟环境
conda create -n llama_factory python=3.10
conda activate llama_factory

# 安装依赖
pip install -r requirements.txt
```

## 三、模型训练

### 数据准备

1. **支持的数据格式**
```json
// 对话格式
{
    "conversations": [
        {
            "system": "你是一个有帮助的AI助手",
            "input": "请介绍一下自己",
            "output": "我是一个AI助手，可以帮助你解答问题..."
        }
    ]
}

// 指令格式
{
    "instruction": "写一首关于春天的诗",
    "output": "春风拂面暖，..."
}
```

2. **数据预处理**
```bash
# 数据转换脚本
python scripts/data_preprocess.py \
    --input_file raw_data.json \
    --output_file processed_data.json \
    --format conversations
```

### 训练配置

1. **LoRA训练**
```bash
# LoRA训练示例
python src/train_bash.py \
    --model_name_or_path Qwen/Qwen2-7B \
    --do_train \
    --dataset data.json \
    --finetuning_type lora \
    --output_dir output \
    --num_train_epochs 3 \
    --per_device_train_batch_size 4 \
    --learning_rate 3e-4 \
    --lora_rank 8
```

2. **全参数微调**
```bash
# 全参数微调示例
python src/train_bash.py \
    --model_name_or_path Qwen/Qwen2-7B \
    --do_train \
    --dataset data.json \
    --finetuning_type full \
    --output_dir output \
    --num_train_epochs 3 \
    --per_device_train_batch_size 2 \
    --learning_rate 1e-5
```

### 训练监控

1. **TensorBoard支持**
```bash
# 启动TensorBoard
tensorboard --logdir output/runs
```

2. **训练指标**
   - Loss曲线
   - 学习率变化
   - GPU利用率
   - 内存使用

## 四、模型评估

### 评估方法

1. **自动评估**
```bash
# 运行评估
python src/evaluate.py \
    --model_name_or_path output \
    --eval_dataset test_data.json \
    --metric accuracy
```

2. **人工评估**
   - 生成质量
   - 响应准确性
   - 语言流畅度

### 评估指标

1. **常用指标**
   - BLEU
   - ROUGE
   - Perplexity
   - 自定义指标

2. **结果分析**
   - 错误分析
   - 性能瓶颈
   - 改进方向

## 五、模型导出

### 模型合并

```bash
# 合并LoRA权重
python src/export_model.py \
    --model_name_or_path Qwen/Qwen2-7B \
    --adapter_name_or_path output \
    --export_dir merged_model \
    --export_size 7B
```

### 格式转换

1. **ONNX转换**
```bash
# 转换为ONNX格式
python src/export_model.py \
    --model_name_or_path merged_model \
    --export_format onnx \
    --export_dir onnx_model
```

2. **其他格式**
   - TorchScript
   - TensorRT
   - OpenVINO

## 六、部署优化

### 性能优化

1. **量化技术**
```bash
# bit量化
python src/export_model.py \
    --model_name_or_path merged_model \
    --quantization_bit 4 \
    --export_dir quantized_model
```

2. **推理加速**
   - Batch处理
   - 模型并行
   - 显存优化

### 服务部署

1. **FastAPI部署**
```python
from fastapi import FastAPI
from transformers import AutoModelForCausalLM, AutoTokenizer

app = FastAPI()
model = AutoModelForCausalLM.from_pretrained("merged_model")
tokenizer = AutoTokenizer.from_pretrained("merged_model")

@app.post("/generate")
async def generate(text: str):
    inputs = tokenizer(text, return_tensors="pt")
    outputs = model.generate(**inputs)
    return {"response": tokenizer.decode(outputs[0])}
```

2. **Docker部署**
```dockerfile
FROM pytorch/pytorch:2.0.0-cuda11.7-cudnn8-runtime

WORKDIR /app
COPY . /app

RUN pip install -r requirements.txt

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## 七、最佳实践

### 训练技巧

1. **数据质量控制**
   - 数据清洗
   - 数据增强
   - 数据平衡

2. **超参数调优**
   - 学习率选择
   - 批次大小
   - 训练轮数

### 常见问题

1. **内存管理**
   - 显存优化
   - 梯度累积
   - 混合精度训练

2. **训练稳定性**
   - 梯度裁剪
   - 学习率预热
   - 检查点保存

## 八、参考资源

### 官方资源
- [LLaMA-Factory GitHub](https://github.com/hiyouga/LLaMA-Factory)
- [文档](https://github.com/hiyouga/LLaMA-Factory/wiki)
- [示例代码](https://github.com/hiyouga/LLaMA-Factory/tree/main/examples)

### 相关项目
- [LLaMA](https://github.com/facebookresearch/llama)
- [Transformers](https://github.com/huggingface/transformers)
- [PEFT](https://github.com/huggingface/peft)

[Qwen2快速开始文档](https://qwen.readthedocs.io/zh-cn/latest/getting_started/quickstart.html)

[Qwen2-VL 全链路模型体验、下载、推理、微调实战！](https://mp.weixin.qq.com/s/y4ZRXOkDSCcUfeT4va68uw)

**Qwen2-VL 新功能？**

- 增强的图像理解能力：Qwen2-VL显著提高了模型理解和解释视觉信息的能力，为关键性能指标设定了新的基准

- 高级视频理解能力：Qwen2-VL具有卓越的在线流媒体功能，能够以很高的精度实时分析动态视频内容

- 集成的可视化agent功能：Qwen2-VL 现在无缝整合了复杂的系统集成，将 Qwen2-VL 转变为能够进行复杂推理和决策的强大可视化代理

- 扩展的多语言支持：Qwen2-VL 扩展了语言能力，以更好地服务于多样化的全球用户群，使 Qwen2-VL 在不同语言环境中更易于访问和有效

https://huggingface.co/Qwen/Qwen2-7B-Instruct



GIT_LFS_SKIP_SMUDGE=1 git clone https://huggingface.co/Qwen/Qwen2-7B-Instruct
cd Baichuan2-13B-Chat
wget "https://huggingface.co/baichuan-inc/Baichuan2-13B-Chat/resolve/main/pytorch_model-00001-of-00003.bin"
...