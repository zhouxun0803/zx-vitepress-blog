#!/bin/bash
# 全局安装 git-auto 命令到系统

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="git-auto"
SOURCE_SCRIPT="/Users/zhouxun/Desktop/shenghong/gengma/project/zx-vitepress-blog/git-auto-push.sh"

echo "🚀 开始安装 git-auto 命令..."

# 检查是否有 sudo 权限
if [ "$EUID" -ne 0 ] && [ ! -w "$INSTALL_DIR" ]; then
    echo "⚠️  需要 sudo 权限来安装到 $INSTALL_DIR"
    echo "请运行: sudo $0"
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