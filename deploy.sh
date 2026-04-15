#!/bin/bash
# 自动化部署脚本
# 功能：创建 GitHub 仓库、推送代码、验证部署

set -e

echo "========================================"
echo "🚀 自动化 GitHub 仓库创建和推送"
echo "========================================"

# 配置信息
GITHUB_USER="laobanliu62-design"
REPO_NAME="health-mgmt"
REMOTE_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

# 1. 检查本地 Git 状态
echo ""
echo "📁 检查本地 Git 状态..."
cd ~/health-management
git status
git log --oneline -1

# 2. 删除已存在的远程（如果存在）
echo ""
echo "🔗 配置远程仓库..."
git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTE_URL"
git remote -v

# 3. 重命名分支为 main
echo ""
echo "📝 确保分支名为 main..."
git branch -M main

# 4. 尝试推送（会提示需要认证）
echo ""
echo "🚀 准备推送代码..."
echo "注意：需要使用 GitHub Token 进行认证"
echo ""
echo "请执行以下命令之一进行推送："
echo ""
echo "方案 1: 使用 Token"
echo "  git push -u origin main"
echo "  输入 GitHub Username: $GITHUB_USER"
echo "  输入 Token: (你的 GitHub Personal Access Token)"
echo ""
echo "方案 2: 使用 SSH (需要先配置 SSH Key)"
echo "  git remote set-url origin git@github.com:${GITHUB_USER}/${REPO_NAME}.git"
echo "  git push -u origin main"
echo ""

# 5. 验证脚本
echo "========================================"
echo "📋 后续步骤验证"
echo "========================================"
echo ""
echo "✅ 1. 代码推送成功："
echo "   访问：https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo ""
echo "✅ 2. 配置 Docker Hub Secrets:"
echo "   访问：https://github.com/${GITHUB_USER}/${REPO_NAME}/settings/secrets/actions"
echo "   添加："
echo "   - DOCKER_USERNAME: 你的 Docker Hub 用户名"
echo "   - DOCKER_PASSWORD: 你的 Docker Hub Access Token"
echo ""
echo "✅ 3. 触发工作流:"
echo "   访问：https://github.com/${GITHUB_USER}/${REPO_NAME}/actions"
echo "   查看 'Docker Build and Push' 工作流"
echo ""
