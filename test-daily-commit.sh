#!/bin/bash

# 测试每日自动提交脚本

echo "🧪 测试每日自动提交脚本"
echo "=================================="
echo ""

cd "/Users/zhouxun/Desktop/shenghong/gengma/project/zx-vitepress-blog"

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

echo "3️⃣ 模拟运行脚本（添加 --dry-run 参数）..."
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