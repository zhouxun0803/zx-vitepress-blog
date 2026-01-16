#!/bin/bash

# 停止每日自动提交守护进程

PID_FILE="auto-commit-daemon.pid"

if [ ! -f "$PID_FILE" ]; then
    echo "❌ 未找到 PID 文件，守护进程可能未运行"
    exit 1
fi

PID=$(cat "$PID_FILE")

if ! ps -p $PID > /dev/null 2>&1; then
    echo "❌ 进程 $PID 不存在"
    rm -f "$PID_FILE"
    exit 1
fi

echo "🛑 正在停止守护进程 (PID: $PID)..."
kill $PID

# 等待进程结束
for i in {1..5}; do
    if ! ps -p $PID > /dev/null 2>&1; then
        echo "✅ 守护进程已停止"
        rm -f "$PID_FILE"
        exit 0
    fi
    sleep 1
done

# 如果还没结束，强制杀死
echo "⚠️  进程未响应，强制终止..."
kill -9 $PID 2>/dev/null || true
rm -f "$PID_FILE"
echo "✅ 守护进程已强制停止"