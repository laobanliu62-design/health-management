# GitHub Actions 配置指南

## 🚀 自动构建和推送流程

本工作流实现：
1. **代码检查** → 静态分析 + 测试
2. **构建镜像** → 多阶段构建
3. **推送镜像** → Docker Hub
4. **更新 Helm** → 自动更新 Helm Chart 版本
5. **发送通知** → 构建状态通知

---

## 📋 配置步骤

### Step 1: 创建 GitHub 仓库

```bash
cd ~/health-management
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin <your-repo-url>
git push -u origin main
```

### Step 2: 配置 Docker Hub Secrets

在 GitHub Repository Settings → Secrets and variables → Actions 添加：

| Secret Name | Value |
|-------------|-------|
| `DOCKER_USERNAME` | 你的 Docker Hub 用户名 |
| `DOCKER_PASSWORD` | Docker Hub 访问令牌 |

**获取访问令牌**:
1. 登录 Docker Hub
2. 进入 Account Settings
3. 点击 Security
4. 生成 Access Token
5. 复制 Token 到 GitHub Secrets

### Step 3: 推送代码触发 CI/CD

```bash
git push origin main
```

工作流会自动触发！

---

## 🔧 工作流说明

### Job 1: test
- 运行代码静态分析
- 执行测试用例
- 失败则停止后续步骤

### Job 2: build-and-push
- 构建 Docker 镜像
- 使用多标签策略：
  - `latest` (main 分支)
  - `branch-name` (开发分支)
  - `sha` (commit SHA)

### Job 3: update-helm
- 自动更新 Helm Chart 版本号
- 提交到仓库

### Job 4: notify
- 发送构建状态通知
- 记录部署信息

---

## 📊 镜像标签策略

| 触发条件 | 生成的标签 |
|----------|-----------|
| 推送 main 分支 | `latest`, `branch-main`, `<sha>` |
| 推送 develop 分支 | `branch-develop`, `<sha>` |
| Pull Request | `<sha>` |

---

## 🎯 自定义配置

### 修改分支

```yaml
on:
  push:
    branches: [main, develop, release/*]
```

### 修改镜像仓库

```yaml
env:
  REGISTRY: ghcr.io  # GitHub Container Registry
  IMAGE_NAME: ${{ github.repository }}
```

### 添加多架构支持

```yaml
- name: Build and push multi-arch
  uses: docker/build-push-action@v5
  with:
    platforms: linux/amd64,linux/arm64
    push: true
```

---

## ✅ 验证部署

工作流运行后，验证：

```bash
# 查看镜像
docker pull health-mgmt:<tag>

# 运行容器
docker run -d -p 8080:80 health-mgmt:<tag>

# 访问应用
curl http://localhost:8080
```

---

## 🔍 故障排查

### 问题 1: 登录失败

```
Error: failed to authenticate
```

**解决**:
- 检查 DOCKER_USERNAME 和 DOCKER_PASSWORD 是否正确
- 确保使用 Access Token 而不是密码
- 重新生成 Token

### 问题 2: 构建失败

```
Build context too large or file missing
```

**解决**:
- 检查 .dockerignore 配置
- 确保 Dockerfile 路径正确
- 清理未使用的 Docker 资源

### 问题 3: Push 失败

```
denied: requested access to the resource is denied
```

**解决**:
- 检查 Docker Hub 账号权限
- 确认用户名和 Token 正确
- 检查仓库是否公开或已授权

---

*配置完成！准备开始自动化构建！*
