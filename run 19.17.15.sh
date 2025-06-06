#!/bin/bash

# =================================================================================================
# 重要提示:
# 1. 在运行此脚本之前，请确保您已经按照之前的指示，下载了 'Qwen/Qwen2-7B-Instruct' 模型。
# 2. 将下载好的模型文件夹 (应该名为 'Qwen2-7B-Instruct') 放置于此脚本所在的目录 (`/root/EM_SLOT/`)。
# =================================================================================================

# export HF_ENDPOINT=https://hf-mirror.com ## if you have no vpn
export HF_HOME=/ssdwork/huyang/r1  ## set to yours huggingface home

# 设置模型和数据集的本地路径
export model_path=./Qwen2-7B-Instruct
export dataset_path=./gsm8k_dataset

# 检查模型和数据集目录是否存在
if [ ! -d "$model_path" ]; then
    echo "错误: 模型目录 '$model_path' 不存在!"
    exit 1
fi

if [ ! -d "$dataset_path" ]; then
    echo "错误: 数据集目录 '$dataset_path' 不存在!"
    exit 1
fi

echo "使用本地模型进行评估: $model_path"
echo "使用本地数据集进行评估: $dataset_path"

# 运行评估脚本
python eval_only_slot.py \
    --model_path $model_path \
    --dataset_path $dataset_path \
    --use_em_inf \
    --do_sample


