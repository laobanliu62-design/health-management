# GitHub Actions - 快速启动指南

## 🚀 一键启动流程

### 1️⃣ 初始化 Git 仓库

```bash
cd ~/health-management
git init
git add .
git commit -m "Initial commit: Flutter health management app with Docker/K8s"
git branch -M main
```

### 2️⃣ 创建 GitHub 仓库

访问 https://github.com/new 创建新仓库
- Repository name: `health-mgmt`
- Visibility: Public 或 Private
- 不要初始化 README (已有项目)

### 3️⃣ 连接远程仓库

```bash
git remote add origin https://github.com/YOUR_USERNAME/health-mgmt.git
git push -u origin main
```

### 4️⃣ 配置 Docker Hub Secrets

**步骤**:
1. 访问 https://github.com/YOUR_USERNAME/health-mgmt/settings/secrets/actions
2. 点击 "New repository secret"
3. 添加以下 Secrets:

```
DOCKER_USERNAME=你的 Docker Hub 用户名
DOCKER_PASSWORD=你的 Docker Hub 访问令牌
```

**获取访问令牌**:
1. 登录 https://hub.docker.com
2. Account Settings → Security
3. Access Tokens → Generate Token
4. 复制 Token 备用

### 5️⃣ 推送代码触发 CI/CD

```bash
git push origin main
```

### 6️⃣ 查看构建状态

1. 访问 https://github.com/YOUR_USERNAME/health-mgmt/actions
2. 查看 "Docker Build and Push" 工作流
3. 等待构建完成

---

## 📊 预期结果

成功后你会看到:
- ✅ Docker 镜像构建完成
- ✅ 镜像推送到 Docker Hub
- ✅ Helm Chart 自动更新
- ✅ 通知消息发送

**镜像地址**: `docker.io/health-mgmt:<tag>`

---

## 🎯 配置清单

- [x] Dockerfile 创建 (多阶段构建)
- [x] GitHub Actions 工作流配置
- [x] CI/CD 流程文档
- [x] Helm Chart 准备
- [ ] GitHub 仓库创建
- [ ] Docker Hub Secrets 配置
- [ ] 首次推送测试

---

**配置完成！开始自动化之旅！** 🎉
