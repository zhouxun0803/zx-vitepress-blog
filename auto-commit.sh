#!/bin/bash

# 自动 git 提交脚本
# 根据修改内容自动生成 commit 消息并提交推送

set -e

echo "🔍 检查 git 仓库状态..."

# 检查是否有变更
if ! git diff-index --quiet HEAD --; then
    if [ -z "$(git status --porcelain)" ]; then
        echo "✨ 没有需要提交的变更"
        exit 0
    fi
fi

echo "📝 分析变更内容..."

# 获取变更的文件列表
CHANGED_FILES=$(git status --porcelain | awk '{print $2}' | sort)

# 初始化变量
ADDED_FILES=""
MODIFIED_FILES=""
DELETED_FILES=""
RENAMED_FILES=""

# 分类变更类型
while IFS= read -r file; do
    if [ -z "$file" ]; then continue; fi

    STATUS=$(git status --porcelain | grep "^$file$" | awk '{print $1}')
    FILE_STATUS=$(git status --porcelain | grep "^[^ ]*[ ]*$file$" | cut -c1-2)

    if [[ "$FILE_STATUS" == "??" ]]; then
        ADDED_FILES="$ADDED_FILES\n  - $file (新增)"
    elif [[ "$FILE_STATUS" =~ ^M ]]; then
        MODIFIED_FILES="$MODIFIED_FILES\n  - $file (修改)"
    elif [[ "$FILE_STATUS" =~ ^D ]]; then
        DELETED_FILES="$DELETED_FILES\n  - $file (删除)"
    elif [[ "$FILE_STATUS" =~ ^R ]]; then
        RENAMED_FILES="$RENAMED_FILES\n  - $file (重命名)"
    fi
done <<< "$CHANGED_FILES"

# 生成 commit 消息
COMMIT_MESSAGE=""

# 检查是否有新增文件
if [ -n "$ADDED_FILES" ]; then
    COMMIT_MESSAGE="feat: 新增文件"
    if [ -n "$MODIFIED_FILES" ]; then
        COMMIT_MESSAGE="feat: 新增及修改文件"
    fi
    if [ -n "$DELETED_FILES" ]; then
        COMMIT_MESSAGE="feat: 文件变更"
    fi
elif [ -n "$MODIFIED_FILES" ]; then
    # 分析修改的文件类型
    if echo "$MODIFIED_FILES" | grep -q "\.md$"; then
        if echo "$MODIFIED_FILES" | grep -q "config"; then
            COMMIT_MESSAGE="docs: 更新配置"
        else
            COMMIT_MESSAGE="docs: 更新文档"
        fi
    elif echo "$MODIFIED_FILES" | grep -q "package\.json$\|\.js$\|\.ts$"; then
        COMMIT_MESSAGE="refactor: 更新代码"
    else
        COMMIT_MESSAGE="update: 修改文件"
    fi
elif [ -n "$DELETED_FILES" ]; then
    COMMIT_MESSAGE="del: 删除文件"
elif [ -n "$RENAMED_FILES" ]; then
    COMMIT_MESSAGE="refactor: 重命名文件"
else
    COMMIT_MESSAGE="update: 更新文件"
fi

# 添加时间戳
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
COMMIT_MESSAGE="$COMMIT_MESSAGE ($TIMESTAMP)"

echo "📋 变更摘要："
echo -e "新增文件: $ADDED_FILES"
echo -e "修改文件: $MODIFIED_FILES"
echo -e "删除文件: $DELETED_FILES"
echo -e "重命名文件: $RENAMED_FILES"
echo ""
echo "💬 提交消息: $COMMIT_MESSAGE"
echo ""

# 执行 git 操作
echo "🚀 开始提交..."

# 添加所有变更
git add .

# 提交
git commit -m "$COMMIT_MESSAGE"

# 推送到远程仓库
echo "📤 推送到远程仓库..."
git push origin main

echo ""
echo "✅ 完成！提交已推送至远程仓库"
echo "📊 提交信息："
git log -1 --pretty=format:"%h - %s (%cr)"