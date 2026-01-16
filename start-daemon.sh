#!/bin/bash

# 后台守护进程版本的每日自动提交
# 每24小时在随机时间执行一次（不需要 cron）

SCRIPT_PATH="/Users/zhouxun/Desktop/shenghong/gengma/project/zx-vitepress-blog/daily-auto-commit.sh"
PID_FILE="auto-commit-daemon.pid"
LOG_FILE="auto-commit-daemon.log"

# 生成随机小时（9-18点）
RANDOM_HOUR=$((9 + RANDOM % 10))
RANDOM_MINUTE=$((RANDOM % 60))

echo "==================================="
echo "🚀 启动每日自动提交守护进程"
echo "==================================="
echo ""

# 检查是否已在运行
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p $OLD_PID > /dev/null 2>&1; then
        echo "⚠️  守护进程已在运行 (PID: $OLD_PID)"
        echo "如需重启，请先停止："
        echo "  kill $OLD_PID && rm $PID_FILE"
        exit 1
    else
        echo "🧹 清理旧的 PID 文件"
        rm -f "$PID_FILE"
    fi
fi

# 获取距离明天随机时间的秒数
TOMORROW=$(date -v "+1d" "+%Y-%m-%d")
TARGET_TIME="$TOMORROW $RANDOM_HOUR:$RANDOM_MINUTE"
TARGET_EPOCH=$(date -j -f "%Y-%m-%d %H:%M" "$TARGET_TIME" "+%s")
NOW_EPOCH=$(date "+%s")
SLEEP_TIME=$((TARGET_EPOCH - NOW_EPOCH))

if [ $SLEEP_TIME -lt 0 ]; then
    # 如果时间已过，调整到明天
    TARGET_EPOCH=$((TARGET_EPOCH + 86400))
    SLEEP_TIME=$((TARGET_EPOCH - NOW_EPOCH))
fi

HOURS=$((SLEEP_TIME / 3600))
MINUTES=$(( (SLEEP_TIME % 3600) / 60 ))

echo "📅 下次执行时间: $TARGET_TIME"
echo "⏰ 等待时间: ${HOURS}小时${MINUTES}分钟"
echo "📝 脚本路径: $SCRIPT_PATH"
echo "📊 日志文件: $LOG_FILE"
echo ""

# 创建后台进程函数
run_daemon() {
    while true; do
        # 每次执行后，计算到明天随机时间的间隔
        RANDOM_HOUR=$((9 + RANDOM % 10))
        RANDOM_MINUTE=$((RANDOM % 60))

        TOMORROW=$(date -v "+1d" "+%Y-%m-%d")
        TARGET_TIME="$TOMORROW $RANDOM_HOUR:$RANDOM_MINUTE"
        TARGET_EPOCH=$(date -j -f "%Y-%m-%d %H:%M" "$TARGET_TIME" "+%s")
        NOW_EPOCH=$(date "+%s")
        SLEEP_TIME=$((TARGET_EPOCH - NOW_EPOCH))

        if [ $SLEEP_TIME -lt 0 ]; then
            TARGET_EPOCH=$((TARGET_EPOCH + 86400))
            SLEEP_TIME=$((TARGET_EPOCH - NOW_EPOCH))
        fi

        HOURS=$((SLEEP_TIME / 3600))
        MINUTES=$(( (SLEEP_TIME % 3600) / 60 ))

        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 守护进程启动，等待 ${HOURS}小时${MINUTES}分钟..." | tee -a "$LOG_FILE"

        # 睡眠到执行时间
        sleep $SLEEP_TIME

        # 执行每日提交脚本
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始执行每日提交..." | tee -a "$LOG_FILE"
        cd "/Users/zhouxun/Desktop/shenghong/gengma/project/zx-vitepress-blog"
        "$SCRIPT_PATH" | tee -a "$LOG_FILE"
        echo "" | tee -a "$LOG_FILE"
    done
}

# 启动后台进程
run_daemon &
DAEMON_PID=$!

# 保存 PID
echo $DAEMON_PID > "$PID_FILE"

echo "✅ 守护进程已启动 (PID: $DAEMON_PID)"
echo ""
echo "📋 管理命令："
echo "  查看日志: tail -f $LOG_FILE"
echo "  停止守护: kill $DAEMON_PID && rm $PID_FILE"
echo "  检查状态: ps -p $DAEMON_PID"
echo ""
echo "守护进程将在后台运行，每天自动提交代码"
echo "按 Ctrl+C 退出（守护进程继续运行）"
echo ""

# 等待用户中断
wait $DAEMON_PID