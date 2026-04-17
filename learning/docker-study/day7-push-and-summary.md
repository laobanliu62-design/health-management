# 📚 Docker 学习 Day 7 - 镜像推送 + 完整项目演练

**学习时间**: 2026-04-17 13:48 北京时间

---

## 🎯 学习目标

1. Docker Hub 镜像推送
2. 完整项目演练
3. Week 1 总结

---

## 📝 实践 1: Docker Hub 镜像推送

### 步骤 1: 登录 Docker Hub
```bash
docker login -u YOUR_USERNAME
# 输入密码完成登录
```

### 步骤 2: 给镜像打标签
```bash
# 格式: docker tag IMAGE_ID username/repository:tag
docker tag my-first-docker-image:latest yourname/hello-app:v1.0
```

### 步骤 3: 推送镜像
```bash
docker push yourname/hello-app:v1.0
```

### 完整示例
```bash
# 1. 登录
docker login

# 2. 打标签 (假设镜像ID是 abc123)
docker tag my-first-docker-image:latest laobanliu62/hello-app:v1.2

# 3. 推送
docker push laobanliu62/hello-app:v1.2

# 4. 在其他机器拉取
docker pull laobanliu62/hello-app:v1.2
```

### 多平台镜像 (Buildx)
```bash
# 启用 buildx
docker buildx install
docker buildx create --name mybuilder
docker buildx use mybuilder

# 构建多平台镜像
docker buildx build --platform linux/amd64,linux/arm64 \
  -t yourname/app:latest --push .
```

---

## 📝 实践 2: 从零部署完整项目

### 项目结构
```
my-app/
├── Dockerfile
├── docker-compose.yml
├── .env
├── nginx/
│   └── nginx.conf
└── app/
    └── index.php (或 .js, .py 等)
```

### 1. 应用代码 (app/index.html)
```html
<!DOCTYPE html>
<html>
<head>
  <title>Docker Demo</title>
  <style>
    body { font-family: sans-serif; text-align: center; padding: 50px; }
    .container { max-width: 600px; margin: 0 auto; }
    h1 { color: #2496ed; }
  </style>
</head>
<body>
  <div class="container">
    <h1>🐳 Docker 部署成功!</h1>
    <p>欢迎访问我的应用</p>
    <p>当前版本: v1.2</p>
  </div>
</body>
</html>
```

### 2. Dockerfile (多阶段构建优化版)
```dockerfile
# 构建阶段
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# 运行阶段
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

### 3. docker-compose.yml (生产级配置)
```yaml
version: '3.8'

services:
  app:
    image: myapp:latest
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=postgres
    depends_on:
      postgres:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=secret
    volumes:
      - postgres-data:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
      interval: 10s
      timeout: 5s
      retries: 5
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - app
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 5s
      retries: 3

volumes:
  postgres-data:

networks:
  default:
    driver: bridge
```

### 4. 一键部署命令
```bash
# 开发环境
docker-compose up -d --build

# 生产环境
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 停止
docker-compose down
```

---

## 📝 实践 3: Week 1 知识总结

### Docker 核心概念
| 概念 | 说明 |
|------|------|
| 镜像 (Image) | 模板，类似于类 |
| 容器 (Container) | 镜像的运行实例，类似于对象 |
| 仓库 (Registry) | 存放镜像的地方 (Docker Hub) |

### 常用命令速查
```bash
# 镜像操作
docker build -t name:tag .          # 构建镜像
docker images                       # 列出镜像
docker rmi name:tag                # 删除镜像
docker pull name:tag               # 拉取镜像
docker push name:tag               # 推送镜像

# 容器操作
docker run -d -p 8080:80 name      # 运行容器
docker ps                          # 运行中的容器
docker ps -a                       # 所有容器
docker stop/rm name                # 停止/删除容器
docker logs -f name                # 查看日志
docker exec -it name sh            # 进入容器

# Compose 操作
docker-compose up -d               # 启动服务
docker-compose down               # 停止服务
docker-compose logs -f            # 查看日志
docker-compose ps                 # 查看状态
```

### Dockerfile 最佳实践
1. ✅ 使用官方镜像作为基础
2. ✅ 减少层数，合并 RUN 指令
3. ✅ 使用 .dockerignore 排除无关文件
4. ✅ 多阶段构建减小镜像体积
5. ✅ 明确指定版本 tag，不要用 latest
6. ✅ 设置健康检查
7. ✅ 使用非 root 用户

### Compose 最佳实践
1. ✅ 使用 .env 文件管理环境变量
2. ✅ 配置健康检查确保依赖可用
3. ✅ 使用 depends_on + condition 控制启动顺序
4. ✅ 设置资源限制防止容器占满资源
5. ✅ 配置日志轮转防止磁盘爆满
6. ✅ 使用 restart: unless-stopped 保证可用性

---

## 🎓 知识点总结

### 镜像推送流程
1. `docker login` 登录 Docker Hub
2. `docker tag` 给镜像打标签
3. `docker push` 推送到仓库
4. 其他机器 `docker pull` 拉取

### 生产部署检查清单
- [ ] 多阶段构建减小镜像体积
- [ ] 环境变量使用 .env 文件
- [ ] 健康检查确保服务可用
- [ ] 资源限制防止资源占满
- [ ] 日志轮转防止磁盘爆满
- [ ] restart 策略保证自启动

---

## 🏆 Week 1 成就

- [x] Day 1: Docker 基础 + Hello World
- [x] Day 2: 自定义 Dockerfile
- [x] Day 3: 缓存机制 + 多阶段构建
- [x] Day 4: docker-compose + Redis
- [x] Day 5: 自定义网络 + 数据卷
- [x] Day 6: Compose 进阶 + 环境变量 + 健康检查
- [x] Day 7: 镜像推送 + 完整项目演练

**🎉 Week 1 Docker 学习完成！**

---

## 🚀 下一步建议

1. **实践练习**: 在本地搭建 Docker 环境实操
2. **进阶内容**: 
   - Docker Swarm / Kubernetes
   - CI/CD 集成 Docker
   - Docker Security
   - 数据备份与恢复

---

*完成时间：2026-04-17 13:48 北京时间*
*状态：Day 7 完成 ✅*
*进度：7/7 (100%)*
*Week 1: 100% 完成！🎉*