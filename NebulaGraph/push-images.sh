#!/bin/bash
# 将NebulaGraph官方镜像推送到用户自己的Docker仓库
# 用法: ./push-images.sh <your-registry>
# 例如: ./push-images.sh docker.io/yourusername

# 检查参数
if [ $# -lt 1 ]; then
  echo "错误: 缺少目标仓库参数"
  echo "用法: $0 <your-registry>"
  echo "例如: $0 docker.io/yourusername"
  exit 1
fi

TARGET_REGISTRY=$1
NEBULA_VERSION="v3.8.0"
STUDIO_VERSION="v3.10.0"
CONSOLE_VERSION="v3.8.0"

# 需要推送的镜像列表
IMAGES=(
  "vesoft/nebula-metad:${NEBULA_VERSION}"
  "vesoft/nebula-storaged:${NEBULA_VERSION}"
  "vesoft/nebula-graphd:${NEBULA_VERSION}"
  "vesoft/nebula-console:${CONSOLE_VERSION}"
  "vesoft/nebula-graph-studio:${STUDIO_VERSION}"
)

echo "准备将NebulaGraph镜像推送到: ${TARGET_REGISTRY}"
echo "这将处理以下镜像:"
for IMG in "${IMAGES[@]}"; do
  echo "  - $IMG"
done

echo -n "是否继续? [y/N] "
read -r CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "操作已取消"
  exit 0
fi

# 登录到目标仓库
echo "请登录到您的Docker仓库 ${TARGET_REGISTRY%/*}:"
docker login ${TARGET_REGISTRY%/*}

if [ $? -ne 0 ]; then
  echo "登录失败，操作中止"
  exit 1
fi

# 处理每个镜像
for IMG in "${IMAGES[@]}"; do
  echo "====== 处理镜像: $IMG ======"
  
  # 提取镜像名称和标签
  IMG_NAME=$(echo $IMG | cut -d: -f1)
  IMG_TAG=$(echo $IMG | cut -d: -f2)
  TARGET_IMG_NAME=$(echo $IMG_NAME | sed "s|vesoft|$TARGET_REGISTRY|")
  
  echo "1. 拉取镜像 $IMG"
  docker pull $IMG
  
  if [ $? -ne 0 ]; then
    echo "拉取镜像失败: $IMG, 跳过此镜像"
    continue
  fi
  
  echo "2. 标记镜像为 ${TARGET_IMG_NAME}:${IMG_TAG}"
  docker tag $IMG ${TARGET_IMG_NAME}:${IMG_TAG}
  
  echo "3. 推送镜像到 ${TARGET_IMG_NAME}:${IMG_TAG}"
  docker push ${TARGET_IMG_NAME}:${IMG_TAG}
  
  if [ $? -ne 0 ]; then
    echo "推送镜像失败: ${TARGET_IMG_NAME}:${IMG_TAG}"
  else
    echo "推送镜像成功: ${TARGET_IMG_NAME}:${IMG_TAG}"
  fi
  
  echo ""
done

echo "操作完成"
echo "您可以通过修改 nebula.sh 脚本中的镜像路径来使用您的私有镜像"
echo "例如: 将 vesoft/nebula-metad:${NEBULA_VERSION} 改为 ${TARGET_REGISTRY}/nebula-metad:${NEBULA_VERSION}" 