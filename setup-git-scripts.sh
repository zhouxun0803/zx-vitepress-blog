#!/bin/bash

# Git 自动提交脚本 - 一键生成工具
# 运行此脚本会生成所有需要的提交脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=================================="
echo "🚀 Git 自动提交脚本生成器"
echo -e "==================================${NC}"
echo ""

# 检查是否已存在脚本
EXISTING_SCRIPTS=()
for script in daily-auto-commit.sh setup-daily-cron.sh start-daemon.sh stop-daemon.sh test-daily-commit.sh install-global.sh; do
    if [ -f "$script" ]; then
        EXISTING_SCRIPTS+=("$script")
    fi
done

if [ ${#EXISTING_SCRIPTS[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  检测到已存在的脚本：${NC}"
    printf '   - %s\n' "${EXISTING_SCRIPTS[@]}"
    echo ""
    read -p "是否覆盖并重新生成？(y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "已取消操作"
        exit 0
    fi
fi

echo "📝 正在生成脚本文件..."
echo ""

# 1. 生成 daily-auto-commit.sh
cat > daily-auto-commit.sh << 'EOF'
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
        COMMIT_MESSAGE="✨ feat: 新增 $ADDED 个文件 ($TODAY)"
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
EOF

echo -e "${GREEN}✅ 生成 daily-auto-commit.sh${NC}"

# 2. 生成 setup-daily-cron.sh
cat > setup-daily-cron.sh << 'EOF'
#!/bin/bash

# 设置每日自动提交定时任务
# 每天在随机时间（9:00-18:00之间）执行自动提交

set -e

SCRIPT_PATH="$(pwd)/daily-auto-commit.sh"
CRON_COMMENT="# Daily auto commit for zx-vitepress-blog"
PROJECT_DIR="$(pwd)"

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
EOF

echo -e "${GREEN}✅ 生成 setup-daily-cron.sh${NC}"

# 3. 生成 start-daemon.sh
cat > start-daemon.sh << 'EOF'
#!/bin/bash

# 后台守护进程版本的每日自动提交
# 每24小时在随机时间执行一次（不需要 cron）

SCRIPT_PATH="$(pwd)/daily-auto-commit.sh"
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
        cd "$(dirname "$SCRIPT_PATH")"
        bash "$SCRIPT_PATH" | tee -a "$LOG_FILE"
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
EOF

echo -e "${GREEN}✅ 生成 start-daemon.sh${NC}"

# 4. 生成 stop-daemon.sh
cat > stop-daemon.sh << 'EOF'
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
EOF

echo -e "${GREEN}✅ 生成 stop-daemon.sh${NC}"

# 5. 生成 test-daily-commit.sh
cat > test-daily-commit.sh << 'EOF'
#!/bin/bash

# 测试每日自动提交脚本

echo "🧪 测试每日自动提交脚本"
echo "=================================="
echo ""

echo "1️⃣ 检查脚本权限..."
if [ -x "daily-auto-commit.sh" ]; then
    echo "   ✅ 脚本可执行"
else
    echo "   ❌ 脚本不可执行，正在修复..."
    chmod +x daily-auto-commit.sh
fi
echo ""

echo "2️⃣ 检查 git 状态..."
git status --short
echo ""

echo "3️⃣ 准备运行脚本..."
echo "   注意：实际执行时会真实提交代码"
echo ""
read -p "是否继续执行？(y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 0
fi

echo ""
echo "🚀 开始执行..."
./daily-auto-commit.sh

echo ""
echo "✅ 测试完成"
echo ""
echo "📊 最新提交："
git log -1 --pretty=format:"%h - %s (%cr)"
EOF

echo -e "${GREEN}✅ 生成 test-daily-commit.sh${NC}"

# 6. 生成 install-global.sh
cat > install-global.sh << 'EOF'
#!/bin/bash
# 全局安装 git-auto 命令到系统

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="git-auto"
SOURCE_SCRIPT="$(pwd)/git-auto-push.sh"

echo "🚀 开始安装 git-auto 命令..."

# 检查是否有 sudo 权限
if [ "$EUID" -ne 0 ] && [ ! -w "$INSTALL_DIR" ]; then
    echo "⚠️  需要 sudo 权限来安装到 $INSTALL_DIR"
    echo "请运行: sudo $0"
    exit 1
fi

# 检查源脚本是否存在
if [ ! -f "$SOURCE_SCRIPT" ]; then
    echo "❌ 错误：找不到 $SOURCE_SCRIPT"
    echo "请确保 git-auto-push.sh 存在"
    exit 1
fi

# 复制脚本到系统目录
sudo cp "$SOURCE_SCRIPT" "$INSTALL_DIR/$SCRIPT_NAME"
sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

echo "✅ 安装完成！"
echo ""
echo "使用方法："
echo "  git-auto                    # 自动分析并提交"
echo "  git-auto -t feat            # 指定提交类型"
echo "  git-auto -m '自定义消息'     # 自定义提交消息"
echo "  git-auto -h                 # 显示帮助"
echo ""
echo "现在你可以在任何 git 项目中使用 'git-auto' 命令了！"
EOF

echo -e "${GREEN}✅ 生成 install-global.sh${NC}"

# 设置执行权限
chmod +x daily-auto-commit.sh setup-daily-cron.sh start-daemon.sh stop-daemon.sh test-daily-commit.sh install-global.sh

echo ""
echo -e "${GREEN}=================================="
echo "✅ 所有脚本生成完成！"
echo -e "==================================${NC}"
echo ""
echo "📦 已生成的脚本："
echo "  1. daily-auto-commit.sh       - 每日自动提交核心脚本"
echo "  2. setup-daily-cron.sh       - 设置 Cron 定时任务"
echo "  3. start-daemon.sh           - 启动守护进程"
echo "  4. stop-daemon.sh            - 停止守护进程"
echo "  5. test-daily-commit.sh      - 测试脚本"
echo "  6. install-global.sh         - 全局安装工具"
echo ""
echo "📖 查看使用说明："
echo "  cat README-SCRIPTS.md"
echo "  cat DAILY-COMMIT-GUIDE.md"
echo ""
echo "🚀 快速开始："
echo "  1. 测试脚本: ./test-daily-commit.sh"
echo "  2. 启动守护: ./start-daemon.sh"
echo "  或设置 Cron: ./setup-daily-cron.sh"
echo ""
