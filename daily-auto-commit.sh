#!/bin/bash

# 每日自动提交脚本
# 如果没有代码变更，自动更新 aboutme.md 的日期以保持每日提交记录

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ABOUTME_FILE="packages/blogpress/aboutme.md"
LOG_FILE="daily-commit.log"

# 获取今天的日期
TODAY=$(date "+%Y-%m-%d")
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 日志函数
log() {
    echo -e "${BLUE}[$TIMESTAMP]${NC} $1" | tee -a "$LOG_FILE"
}

log "=== 每日自动提交任务开始 ==="

# 检查 git 仓库状态
log "🔍 检查 git 仓库状态..."

# 获取变更状态
HAS_CHANGES=false

# 检查是否有未提交的变更
if ! git diff-index --quiet HEAD --; then
    HAS_CHANGES=true
    log "✅ 发现代码变更"
elif [ -n "$(git status --porcelain)" ]; then
    HAS_CHANGES=true
    log "✅ 发现文件变更"
fi

# 获取变更统计
CHANGED_FILES=$(git status --porcelain | wc -l)
ADDED=$(git status --porcelain | grep "^??" | wc -l)
MODIFIED=$(git status --porcelain | grep "^ M" | wc -l)

if [ "$HAS_CHANGES" = true ]; then
    log "📝 检测到 $CHANGED_FILES 个文件变更（新增: $ADDED, 修改: $MODIFIED）"
    log "🚀 执行正常提交流程..."

    # 执行标准提交
    git add .

    # 智能生成提交消息
    if [ "$ADDED" -gt 0 ] && [ "$MODIFIED" -eq 0 ]; then
        COMMIT_MESSAGE="✨ feat: 新增 $ADD 个文件 ($TODAY)"
    elif [ "$MODIFIED" -gt 0 ]; then
        if git status --porcelain | grep -q "\.md$"; then
            COMMIT_MESSAGE="📝 docs: 更新文档 ($TODAY)"
        else
            COMMIT_MESSAGE="♻️ refactor: 代码优化 ($TODAY)"
        fi
    else
        COMMIT_MESSAGE="📦 update: 批量更新 ($TODAY)"
    fi

    git commit -m "$COMMIT_MESSAGE"
    log "✅ 代码提交完成: $COMMIT_MESSAGE"

else
    log "ℹ️  没有检测到代码变更"

    # 检查 aboutme.md 是否存在
    if [ -f "$ABOUTME_FILE" ]; then
        log "📅 将更新 aboutme.md 的日期为今天: $TODAY"

        # 备份原文件
        cp "$ABOUTME_FILE" "${ABOUTME_FILE}.backup"

        # 使用 sed 更新日期
        # 匹配 date: 2021-12-11 格式，替换为今天的日期
        sed -i '' "s/^date: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}$/date: $TODAY/" "$ABOUTME_FILE"

        # 验证更新是否成功
        NEW_DATE=$(grep "^date: " "$ABOUTME_FILE" | awk '{print $2}')
        if [ "$NEW_DATE" = "$TODAY" ]; then
            log "✅ 日期更新成功: $NEW_DATE"
        else
            log "❌ 日期更新失败，恢复备份"
            mv "${ABOUTME_FILE}.backup" "$ABOUTME_FILE"
            exit 1
        fi

        # 提交更改
        git add "$ABOUTME_FILE"
        COMMIT_MESSAGE="📅 chore: 更新 aboutme.md 日期 ($TODAY)"
        git commit -m "$COMMIT_MESSAGE"
        log "✅ 日期更新提交完成: $COMMIT_MESSAGE"

        # 清理备份文件
        rm -f "${ABOUTME_FILE}.backup"

    else
        log "⚠️  aboutme.md 文件不存在，跳过日期更新"
        exit 0
    fi
fi

# 推送到远程仓库
log "📤 推送到远程仓库..."
if git push origin main; then
    log "✅ 推送成功"
else
    log "❌ 推送失败，请检查网络或权限"
    exit 1
fi

# 显示最新提交
log "📊 最新提交："
git log -1 --pretty=format:"   %h - %s (%cr) <%an>" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

log "=== 每日自动提交任务完成 ==="
echo ""

exit 0