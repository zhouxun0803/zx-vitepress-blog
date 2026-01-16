#!/bin/bash

# Git 自动提交推送脚本 - 增强版
# 支持自定义提交类型、智能分析变更、自动推送

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认分支
BRANCH="main"

# 解析命令行参数
COMMIT_TYPE=""
CUSTOM_MESSAGE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            COMMIT_TYPE="$2"
            shift 2
            ;;
        -m|--message)
            CUSTOM_MESSAGE="$2"
            shift 2
            ;;
        -b|--branch)
            BRANCH="$2"
            shift 2
            ;;
        -h|--help)
            echo "用法: $0 [选项]"
            echo "选项:"
            echo "  -t, --type TYPE     指定提交类型 (feat/fix/docs/refactor/test/chore)"
            echo "  -m, --message MSG   自定义提交消息"
            echo "  -b, --branch NAME   指定分支名 (默认: main)"
            echo "  -h, --help          显示帮助信息"
            exit 0
            ;;
        *)
            echo "未知选项: $1"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}🔍 检查 git 仓库状态...${NC}"

# 检查是否有变更
if ! git diff-index --quiet HEAD --; then
    if [ -z "$(git status --porcelain)" ]; then
        echo -e "${GREEN}✨ 没有需要提交的变更${NC}"
        exit 0
    fi
fi

echo -e "${BLUE}📝 分析变更内容...${NC}"

# 获取变更统计
CHANGED=$(git status --porcelain | wc -l)
ADDED=$(git status --porcelain | grep "^??" | wc -l)
MODIFIED=$(git status --porcelain | grep "^ M" | wc -l)
DELETED=$(git status --porcelain | grep "^ D" | wc -l)

# 获取变更的文件列表
CHANGED_FILES=$(git status --porcelain | awk '{print $2}' | head -10)

# 生成提交消息
if [ -n "$CUSTOM_MESSAGE" ]; then
    COMMIT_MESSAGE="$CUSTOM_MESSAGE"
elif [ -n "$COMMIT_TYPE" ]; then
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
    COMMIT_MESSAGE="$COMMIT_TYPE: 更新 ($TIMESTAMP)"
else
    # 智能分析变更类型
    if [ "$ADDED" -gt 0 ] && [ "$MODIFIED" -eq 0 ] && [ "$DELETED" -eq 0 ]; then
        COMMIT_TYPE="feat"
        EMOJI="✨"
    elif [ "$MODIFIED" -gt 0 ] && [ "$ADDED" -eq 0 ]; then
        if echo "$CHANGED_FILES" | grep -q "\.md$"; then
            COMMIT_TYPE="docs"
            EMOJI="📝"
        elif echo "$CHANGED_FILES" | grep -q "package\.json$"; then
            COMMIT_TYPE="chore"
            EMOJI="🔧"
        else
            COMMIT_TYPE="refactor"
            EMOJI="♻️"
        fi
    elif [ "$DELETED" -gt 0 ]; then
        COMMIT_TYPE="del"
        EMOJI="🗑️"
    else
        COMMIT_TYPE="update"
        EMOJI="📦"
    fi

    TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
    COMMIT_MESSAGE="$EMOJI $COMMIT_TYPE: $(git status --porcelain | head -1 | awk '{print $2}' | xargs -I {} dirname {}) | head -1"
    # 简化消息
    if [ "$ADDED" -gt 0 ]; then
        COMMIT_MESSAGE="$EMOJI $COMMIT_TYPE: 新增 $ADDED 个文件"
    elif [ "$MODIFIED" -gt 0 ]; then
        COMMIT_MESSAGE="$EMOJI $COMMIT_TYPE: 修改 $MODIFIED 个文件"
    else
        COMMIT_MESSAGE="$EMOJI $COMMIT_TYPE: 批量更新"
    fi
    COMMIT_MESSAGE="$COMMIT_MESSAGE ($TIMESTAMP)"
fi

# 显示变更摘要
echo ""
echo -e "${YELLOW}📋 变更摘要：${NC}"
echo -e "  ${GREEN}新增: $ADDED${NC}  ${YELLOW}修改: $MODIFIED${NC}  ${RED}删除: $DELETED${NC}  ${BLUE}总计: $CHANGED${NC}"
echo ""
if [ -n "$CHANGED_FILES" ]; then
    echo -e "${YELLOW}主要变更文件：${NC}"
    echo "$CHANGED_FILES" | head -5 | while read file; do
        echo -e "  ${NC}- $file"
    done
    if [ "$CHANGED" -gt 5 ]; then
        echo "  ... 还有 $((CHANGED - 5)) 个文件"
    fi
fi
echo ""
echo -e "${YELLOW}💬 提交消息: ${NC}${GREEN}$COMMIT_MESSAGE${NC}"
echo ""

# 确认提交
read -p "是否继续提交并推送? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消操作"
    exit 0
fi

# 执行 git 操作
echo -e "${BLUE}🚀 开始提交...${NC}"

# 添加所有变更
git add .

# 提交
git commit -m "$COMMIT_MESSAGE"

# 推送到远程仓库
echo -e "${BLUE}📤 推送到远程仓库...${NC}"
git push origin "$BRANCH"

echo ""
echo -e "${GREEN}✅ 完成！提交已推送至远程仓库${NC}"
echo ""
echo -e "${BLUE}📊 最新提交：${NC}"
git log -1 --pretty=format:"%h - %s (%cr) <%an>"