#!/usr/bin/env bash
# 一键提交并推送到 GitHub
# 用法：  ./push.sh "提交说明"
# 不带参数则用默认说明（含时间戳）
set -e
cd "$(dirname "$0")"          # 切到脚本所在目录（仓库根目录）

msg="${1:-update: $(date '+%Y-%m-%d %H:%M')}"

git add -A

if git diff --cached --quiet; then
  echo "ℹ️ 没有需要提交的改动"
  exit 0
fi

git commit -m "$msg"
git push
echo "✅ 已推送到 GitHub：$msg"
