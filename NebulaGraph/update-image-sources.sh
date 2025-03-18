#!/bin/bash
# 更新NebulaGraph脚本中的镜像源
# 用法: ./update-image-sources.sh <your-registry>
# 例如: ./update-image-sources.sh docker.io/yourusername

# 检查参数
if [ $# -lt 1 ]; then
  echo "错误: 缺少目标仓库参数"
  echo "用法: $0 <your-registry>"
  echo "例如: $0 docker.io/yourusername"
  exit 1
fi

TARGET_REGISTRY=$1
NEBULA_SCRIPT="nebula.sh"

# 检查脚本是否存在
if [ ! -f "$NEBULA_SCRIPT" ]; then
  echo "错误: 找不到 nebula.sh 脚本文件"
  exit 1
fi

# 备份原始脚本
cp "$NEBULA_SCRIPT" "${NEBULA_SCRIPT}.bak"
echo "已创建原始脚本备份: ${NEBULA_SCRIPT}.bak"

# 替换镜像源
echo "更新脚本中的镜像源到: $TARGET_REGISTRY"

# 替换metad镜像
sed -i '' "s|vesoft/nebula-metad:|$TARGET_REGISTRY/nebula-metad:|g" "$NEBULA_SCRIPT"

# 替换storaged镜像
sed -i '' "s|vesoft/nebula-storaged:|$TARGET_REGISTRY/nebula-storaged:|g" "$NEBULA_SCRIPT"

# 替换graphd镜像
sed -i '' "s|vesoft/nebula-graphd:|$TARGET_REGISTRY/nebula-graphd:|g" "$NEBULA_SCRIPT"

# 替换console镜像
sed -i '' "s|vesoft/nebula-console:|$TARGET_REGISTRY/nebula-console:|g" "$NEBULA_SCRIPT"

# 替换studio镜像
sed -i '' "s|vesoft/nebula-graph-studio:|$TARGET_REGISTRY/nebula-graph-studio:|g" "$NEBULA_SCRIPT"

echo "镜像源已更新完成"
echo "您可以检查 $NEBULA_SCRIPT 文件确认更改"
echo "如需恢复原始设置，请运行: cp ${NEBULA_SCRIPT}.bak $NEBULA_SCRIPT" 