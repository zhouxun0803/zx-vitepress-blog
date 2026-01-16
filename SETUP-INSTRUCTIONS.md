# 🚀 Git 自动提交脚本 - 快速设置指南

## 📋 概述

本项目提供了一套完整的 Git 自动化脚本，支持每日自动提交功能。即使没有代码更新，也会自动更新 `aboutme.md` 的日期，确保你的 GitHub Contributions 每天都有记录。

---

## ⚡ 快速设置（3 步完成）

### 步骤 1：拉取代码

```bash
git clone <your-repo-url>
cd <your-repo-directory>
```

### 步骤 2：生成脚本

```bash
# 一键生成所有需要的脚本
./setup-git-scripts.sh
```

这将生成：
- ✅ `auto-commit.sh` - 智能分析提交
- ✅ `git-auto-push.sh` - 增强版提交
- ✅ `git-quick.sh` - 快速提交
- ✅ `daily-auto-commit.sh` - 每日自动提交核心
- ✅ `setup-daily-cron.sh` - Cron 设置
- ✅ `start-daemon.sh` - 守护进程启动
- ✅ `stop-daemon.sh` - 守护进程停止
- ✅ `test-daily-commit.sh` - 测试工具
- ✅ `install-global.sh` - 全局安装

### 步骤 3：选择使用方式

#### 方式 A：守护进程（推荐个人电脑）

```bash
# 启动守护进程（后台运行，每天随机时间执行）
./start-daemon.sh
```

#### 方式 B：Cron 定时任务（推荐服务器）

```bash
# 设置定时任务
./setup-daily-cron.sh
```

#### 方式 C：手动提交

```bash
# 日常使用
./auto-commit.sh
```

---

## 📖 详细文档

- **[README-SCRIPTS.md](README-SCRIPTS.md)** - 完整使用指南
- **[DAILY-COMMIT-GUIDE.md](DAILY-COMMIT-GUIDE.md)** - 每日自动提交详细说明

---

## ✨ 核心特性

### 🤖 智能检测
- **有代码变更** → 正常提交代码
- **无代码变更** → 自动更新 `aboutme.md` 的日期

### 📝 智能消息
- `✨ feat: 新增 X 个文件` - 新增文件
- `📝 docs: 更新文档` - 修改文档
- `♻️ refactor: 代码优化` - 代码修改
- `📅 chore: 更新 aboutme.md 日期` - 更新日期

### 🎲 随机时间
- 每天在 9:00-18:00 之间随机时间执行
- 模拟真实开发节奏

### 📊 可视化
- 彩色输出
- 详细日志
- 实时状态

---

## 🔧 自定义配置

### 修改 aboutme.md 路径

编辑 `daily-auto-commit.sh`：

```bash
ABOUTME_FILE="packages/blogpress/aboutme.md"  # 改为你的路径
```

### 修改执行时间范围

编辑 `start-daemon.sh` 或 `setup-daily-cron.sh`：

```bash
MIN_HOUR=9      # 最早时间
MAX_HOUR=18     # 最晚时间
```

### 修改默认分支

编辑 `daily-auto-commit.sh`：

```bash
git push origin main  # 改为你需要的分支
```

---

## 🛠️ 常用命令

### 日常管理

```bash
# 测试脚本
./test-daily-commit.sh

# 查看日志
tail -f daily-commit.log

# 停止守护进程
./stop-daemon.sh

# 删除定时任务
crontab -l | grep -v "daily-auto-commit.sh" | crontab -
```

### 查看状态

```bash
# 查看提交历史
git log --oneline --since="7 days ago"

# 查看守护进程
ps aux | grep start-daemon

# 查看定时任务
crontab -l
```

---

## ⚠️ 注意事项

1. **首次使用前确保**：
   - Git 已配置用户名和邮箱
   - 有远程仓库的推送权限
   - `.gitignore` 已正确配置

2. **安全提醒**：
   - 脚本会自动添加所有变更，请确保不要提交敏感文件
   - 建议配合 `.gitignore` 使用

3. **最佳实践**：
   - 定期检查日志
   - 重要变更前手动备份
   - 监控提交频率

---

## 📞 故障排除

### 推送失败

```bash
# 检查远程仓库
git remote -v

# 测试连接
ssh -T git@github.com

# 手动推送验证
git push origin main
```

### 权限错误

```bash
# 修复脚本权限
chmod +x *.sh

# 检查 git 配置
git config user.name
git config user.email
```

### 守护进程不执行

```bash
# 检查进程
ps aux | grep start-daemon

# 查看日志
tail -f auto-commit-daemon.log

# 重新启动
./start-daemon.sh
```

---

## 🎉 效果展示

使用后你的 GitHub Contributions 将呈现：

```
January 2026
Sun Mon Tue Wed Thu Fri Sat
          1  2  3  4
 5  6  7  8  9 10 11  ← 每天都有提交！
12 13 14 15 16 17 18
19 20 21 22 23 24 25
26 27 28 29 30 31
```

**提交记录示例：**

```
📅 2026-01-16  ✨ feat: 新增项目文档
📅 2026-01-15  📅 chore: 更新 aboutme.md 日期
📅 2026-01-14  📝 docs: 更新使用指南
📅 2026-01-13  ♻️ refactor: 优化代码结构
📅 2026-01-12  📅 chore: 更新 aboutme.md 日期
```

---

**每天都有提交，让你的代码活跃度满满！🚀**