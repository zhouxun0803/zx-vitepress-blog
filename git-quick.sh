#!/bin/bash
# 最简版 git 自动提交 - 一键执行
git add . && git commit -m "update: $(date '+%Y-%m-%d %H:%M')" && git push origin main