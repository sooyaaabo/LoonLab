#!/bin/bash
# 一键重置 Git 仓库历史，只保留当前文件状态

set -e

TARGET_BRANCH=${1:-main}

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "❌ 当前目录不是 Git 仓库"
    exit 1
}

echo "⚠️ 警告：这将清空分支 [$TARGET_BRANCH] 的历史，只保留当前文件。"
read -p "确定继续吗？(Y/N): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "操作已取消"
    exit 1
fi

# 创建孤儿分支
git checkout --orphan latest_branch

# 清空索引并提交当前文件
git reset
git add -A

git commit -m "Initial commit with current files"

# 删除旧本地分支
if git show-ref --verify --quiet refs/heads/$TARGET_BRANCH; then
    git branch -D $TARGET_BRANCH
fi

# 重命名
git branch -m $TARGET_BRANCH

# 强制覆盖远程历史
git push --force origin $TARGET_BRANCH

echo "✅ 分支 [$TARGET_BRANCH] 历史已重置并推送完成"