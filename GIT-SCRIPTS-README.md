# Git 自动提交脚本集合 🚀

这个脚本集合提供了多种自动化 git 提交和推送的方式，让你告别繁琐的手动操作。

## 📦 脚本列表

### 1. `auto-commit.sh` - 智能分析版 ⭐️ 推荐
**功能最完整，自动分析变更内容生成合适的 commit 消息**

```bash
./auto-commit.sh
```

**特性：**
- ✨ 自动检测新增、修改、删除的文件
- 🤖 智能生成 commit 消息（feat/docs/refactor/del）
- 📊 显示详细的变更统计
- 🎯 根据文件类型自动分类

---

### 2. `git-auto-push.sh` - 增强版
**功能最强大，支持自定义参数和交互确认**

```bash
# 基本使用
./git-auto-push.sh

# 指定提交类型
./git-auto-push.sh -t feat

# 自定义消息
./git-auto-push.sh -m "添加新功能"

# 指定分支
./git-auto-push.sh -b develop

# 查看帮助
./git-auto-push.sh -h
```

**参数说明：**
- `-t, --type` - 指定提交类型 (feat/fix/docs/refactor/test/chore)
- `-m, --message` - 自定义提交消息
- `-b, --branch` - 指定分支名（默认: main）
- `-h, --help` - 显示帮助信息

---

### 3. `git-quick.sh` - 极简版
**一行命令，快速提交**

```bash
./git-quick.sh
```

**生成消息格式：** `update: YYYY-MM-DD HH:MM`

---

### 4. `install-global.sh` - 全局安装
**将 git-auto 命令安装到系统，在任何项目中使用**

```bash
# 安装
./install-global.sh

# 安装后使用
git-auto -t feat
git-auto -m "自定义消息"
```

---

## 🎨 智能消息类型

脚本会根据变更内容自动生成合适的 commit 消息：

| 消息类型 | 触发条件 | 示例 |
|---------|---------|------|
| `feat:` | 新增文件 | `feat: 新增文件 (2026-01-16 13:33)` |
| `docs:` | 修改 .md 文件 | `docs: 更新文档 (2026-01-16 13:33)` |
| `refactor:` | 修改代码文件 | `refactor: 更新代码 (2026-01-16 13:33)` |
| `del:` | 删除文件 | `del: 删除文件 (2026-01-16 13:33)` |
| `update:` | 其他修改 | `update: 修改文件 (2026-01-16 13:33)` |

---

## 💡 使用建议

### 日常开发推荐流程：

1. **开发完成后：**
   ```bash
   ./auto-commit.sh
   ```

2. **功能开发：**
   ```bash
   ./git-auto-push.sh -t feat -m "添加用户登录功能"
   ```

3. **文档更新：**
   ```bash
   ./git-auto-push.sh -t docs -m "更新 API 文档"
   ```

4. **快速提交测试：**
   ```bash
   ./git-quick.sh
   ```

---

## 🔧 自定义配置

你可以通过修改脚本来满足个性化需求：

### 修改默认分支
编辑脚本，将 `BRANCH="main"` 改为你的默认分支。

### 添加更多文件类型判断
在智能分析部分添加文件扩展名判断：

```bash
elif echo "$CHANGED_FILES" | grep -q "\.css$"; then
    COMMIT_TYPE="style"
```

### 自定义提交消息格式
修改 `COMMIT_MESSAGE` 变量来调整消息格式。

---

## ⚠️ 注意事项

1. **首次使用前请确保：**
   - Git 仓库已初始化
   - 远程仓库已配置
   - 有推送权限

2. **安全提醒：**
   - 脚本会自动添加所有变更，请确保不要提交敏感文件
   - 建议配合 `.gitignore` 使用

3. **最佳实践：**
   - 提交前先 `git status` 检查变更
   - 大型变更建议手动编写 commit 消息
   - 定期拉取远程更新：`git pull origin main`

---

## 📝 示例输出

```
🔍 检查 git 仓库状态...
📝 分析变更内容...

📋 变更摘要：
  新增文件:
    - packages/blogpress/ai/coze/index.md
    - packages/blogpress/ai/doubao/index.md

  💬 提交消息: feat: 新增文件 (2026-01-16 13:33)

🚀 开始提交...
[main 49646d1] feat: 新增文件 (2026-01-16 13:33)
 3 files changed, 45 insertions(+)

📤 推送到远程仓库...
To github.com:username/repo.git
   f4a1f72..49646d1  main -> main

✅ 完成！提交已推送至远程仓库
```

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这些脚本！

---

**Happy Coding! 🎉**