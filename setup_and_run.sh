#!/bin/bash

# =================================================================================================
# EM_SLOT 项目一键安装与运行脚本
#
# 该脚本会自动完成以下所有任务:
# 1. 检查并创建名为 'SLOT_EMIFS' 的 Conda 环境。
# 2. 在环境中安装所有必要的 Python 依赖包。
# 3. 检查并下载 Qwen2-7B-Instruct 模型。
# 4. 检查并下载 gsm8k 数据集。
# 5. 赋予 run.sh 执行权限并启动评估程序。
#
# 使用方法:
# 1. 将此脚本放置在项目根目录 (与 run.sh 同级)。
# 2. 赋予执行权限: chmod +x setup_and_run.sh
# 3. 运行脚本: ./setup_and_run.sh
# =================================================================================================

# --- 配置 ---
ENV_NAME="SLOT_EMIFS"
PYTHON_VERSION="3.10"
MODEL_NAME="Qwen/Qwen2-7B-Instruct"
MODEL_DIR="./Qwen2-7B-Instruct"
DATASET_NAME="openai/gsm8k"
DATASET_DIR="./gsm8k_dataset"

# --- 脚本开始 ---
set -e # 如果任何命令失败，则立即退出

# 检查 Conda 是否安装
if ! command -v conda &> /dev/null; then
    echo "错误: Conda 未安装或未在 PATH 中。请先安装 Conda。"
    exit 1
fi

# 检查 Conda 环境是否存在
if conda env list | grep -q "^$ENV_NAME\s"; then
    echo "Conda 环境 '$ENV_NAME' 已存在。"
else
    echo "Conda 环境 '$ENV_NAME' 不存在，现在开始创建..."
    conda create -y -n "$ENV_NAME" python="$PYTHON_VERSION"
    echo "环境 '$ENV_NAME' 创建成功。"
fi

# 激活 Conda 环境
echo "正在激活 Conda 环境 '$ENV_NAME'..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "$ENV_NAME"

# 安装依赖
echo "正在安装必要的 Python 依赖包..."
pip install torch transformers datasets accelerate sentencepiece huggingface_hub pyarrow --extra-index-url https://pypi.tuna.tsinghua.edu.cn/simple

echo "依赖安装完成。"

# 检查并下载模型
if [ -d "$MODEL_DIR" ]; then
    echo "模型目录 '$MODEL_DIR' 已存在，跳过下载。"
else
    echo "模型目录 '$MODEL_DIR' 不存在，现在开始下载..."
    # 使用 huggingface-cli 下载，速度更快
    huggingface-cli download "$MODEL_NAME" --local-dir "$MODEL_DIR" --local-dir-use-symlinks False
    echo "模型下载完成。"
fi

# 检查并下载数据集
if [ -d "$DATASET_DIR" ]; then
    echo "数据集目录 '$DATASET_DIR' 已存在，跳过下载。"
else
    echo "数据集目录 '$DATASET_DIR' 不存在，现在开始下载..."
    # 创建一个临时 Python 脚本来下载数据集
    cat > download_ds.py << EOL
from datasets import load_dataset
print(f"正在下载数据集 '{DATASET_NAME}'...")
dataset = load_dataset('$DATASET_NAME', 'main')
dataset.save_to_disk('$DATASET_DIR')
print(f"数据集已成功保存到 '{DATASET_DIR}'")
EOL
    python download_ds.py
    rm download_ds.py # 删除临时脚本
    echo "数据集下载完成。"
fi

# 检查 run.sh 是否存在
if [ ! -f "run.sh" ]; then
    echo "错误: 'run.sh' 脚本未找到。请确保它与本脚本位于同一目录。"
    exit 1
fi

# 赋予 run.sh 执行权限并运行
echo "准备就绪，正在启动评估脚本 'run.sh'..."
chmod +x run.sh
./run.sh

echo "脚本执行完毕。" 