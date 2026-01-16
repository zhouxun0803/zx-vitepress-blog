#!/bin/bash

# 设置每日自动提交定时任务
# 每天在随机时间（9:00-18:00之间）执行自动提交

set -e

SCRIPT_PATH="/Users/zhouxun/Desktop/shenghong/gengma/project/zx-vitepress-blog/daily-auto-commit.sh"
CRON_COMMENT="# Daily auto commit for zx-vitepress-blog"
PROJECT_DIR="/Users/zhouxun/Desktop/shenghong/gengma/project/zx-vitepress-blog"

echo "🚀 设置每日自动提交定时任务"
echo "================================"
echo ""

# 检查脚本是否存在
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ 错误：找不到脚本文件 $SCRIPT_PATH"
    exit 1
fi

# 生成随机时间（9:00-18:00之间）
MIN_HOUR=9
MAX_HOUR=18

# 生成随机小时和分钟
RANDOM_HOUR=$((MIN_HOUR + RANDOM % (MAX_HOUR - MIN_HOUR + 1)))
RANDOM_MINUTE=$((RANDOM % 60))

# 格式化时间
CRON_MINUTE=$RANDOM_MINUTE
CRON_HOUR=$RANDOM_HOUR

# 生成 cron 表达式：每天在随机时间执行
CRON_EXPRESSION="$CRON_MINUTE $CRON_HOUR * * *"

echo "📅 每日执行时间: ${CRON_HOUR}:${CRON_MINUTE}"
echo ""

# 检查是否已存在该 cron 任务
EXISTING_CRON=$(crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH" || true)

if [ -n "$EXISTING_CRON" ]; then
    echo "⚠️  检测到已存在的定时任务："
    echo "$EXISTING_CRON"
    echo ""
    read -p "是否要替换现有任务？(y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "已取消操作"
        exit 0
    fi

    # 删除现有任务
    (crontab -l 2>/dev/null | grep -v -F "$SCRIPT_PATH") | crontab -
    echo "✅ 已删除现有任务"
fi

# 创建新的 cron 任务
NEW_CRON="$CRON_EXPRESSION $SCRIPT_PATH >> $PROJECT_DIR/daily-commit.log 2>&1 # $CRON_COMMENT"

# 添加到 crontab
(crontab -l 2>/dev/null; echo "$NEW_CRON") | crontab -

echo "✅ 定时任务设置成功！"
echo ""
echo "📋 任务详情："
echo "   执行时间: 每天 ${CRON_HOUR}:${CRON_MINUTE}"
echo "   脚本路径: $SCRIPT_PATH"
echo "   日志文件: $PROJECT_DIR/daily-commit.log"
echo ""
echo "🔍 查看当前定时任务："
echo "   crontab -l"
echo ""
echo "📊 查看执行日志："
echo "   tail -f $PROJECT_DIR/daily-commit.log"
echo ""
echo "❌ 删除定时任务："
echo "   crontab -l | grep -v '$SCRIPT_PATH' | crontab -"
echo ""

# 提供手动触发选项
echo "💡 现在可以："
echo "   1. 等待定时任务自动执行"
echo "   2. 手动执行一次测试: $SCRIPT_PATH"
echo ""
read -p "是否现在手动执行一次测试？(y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 手动执行中..."
    cd "$PROJECT_DIR"
    "$SCRIPT_PATH"
fi