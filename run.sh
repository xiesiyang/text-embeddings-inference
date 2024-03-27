#!/bin/bash

# 指定目标路径
model_dir_path="/models/embeddings"

# 检查目标路径是否存在
if [ ! -d "$model_dir_path" ]; then
    echo "未识别到指定的模型,退出"
    exit 1
fi

# 获取子目录数量
subdir_count=$(find "$model_dir_path" -maxdepth 1 -type d | wc -l)

# 检查子目录数量
if [ "$subdir_count" -ne 2 ]; then
    echo "识别到多个模型,退出"
    exit 1
fi

# 获取唯一的子目录名
unique_subdir=$(find "$model_dir_path" -maxdepth 1 -type d -not -path "$model_dir_path" -exec basename {} \;)

echo "需要加载的模型: $unique_subdir"

if ! command -v nvidia-smi &> /dev/null; then
    echo "Error: 'nvidia-smi' command not found."
    exit 1
fi

compute_cap=$(nvidia-smi --query-gpu=compute_cap --format=csv | sed -n '2p' | sed 's/\.//g')

if [ ${compute_cap} -eq 75 ]
then
    exec text-embeddings-router-75 --model-id  $model_dir_path/$unique_subdir  --json-output "$@"
elif [ ${compute_cap} -ge 80 -a ${compute_cap} -lt 90 ]
then
    exec text-embeddings-router-80 --model-id  $model_dir_path/$unique_subdir  --json-output "$@"
elif [ ${compute_cap} -eq 90 ]
then
    exec text-embeddings-router-90 --model-id  $model_dir_path/$unique_subdir  --json-output "$@"
else
    echo "cuda compute cap ${compute_cap} is not supported"; exit 1
fi



