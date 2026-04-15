#!/bin/bash
# 自动创建 GitHub 仓库并推送代码

set -e

echo "🚀 自动创建 GitHub 仓库..."

# 配置
GITHUB_USER="laobanliu62-design"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
REPO_NAME="health-mgmt"

if [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  未设置 GITHUB_TOKEN 环境变量"
    echo ""
    echo "请获取 GitHub Personal Access Token:"
    echo "1. 访问 https://github.com/settings/tokens"
    echo "2. 生成新的 Token (scope: repo)"
    echo "3. 设置环境变量：export GITHUB_TOKEN=your_token_here"
    echo ""
    echo "或者使用 GitHub CLI 登录:"
    echo "  gh auth login"
    exit 1
fi

# 创建仓库
echo "📝 创建仓库..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -d "{\"name\":\"$REPO_NAME\",\"private\":false}" \
  "https://api.github.com/user/repos")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" == "201" ]; then
    echo "✅ 仓库创建成功！"
    echo "🔗 仓库地址：https://github.com/${GITHUB_USER}/${REPO_NAME}"
elif [ "$HTTP_CODE" == "200" ]; then
    echo "⚠️  仓库已存在"
    echo "🔗 仓库地址：https://github.com/${GITHUB_USER}/${REPO_NAME}"
else
    echo "❌ 创建仓库失败，HTTP 代码：$HTTP_CODE"
    echo "响应：$BODY"
    exit 1
fi

# 配置 Git
echo ""
echo "🔧 配置 Git..."
cd ~/health-management
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

# 推送代码
echo ""
echo "🚀 推送代码..."
git push -u origin main 2>&1

echo ""
echo "========================================"
echo "✅ 完成！访问仓库查看："
echo "https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo "========================================"
