# Docker 学习 - Day 3

## 目标
1. 观察 Docker 缓存机制
2. 学习多阶段构建优化
3. 减小镜像大小

---

## 📝 实践 1: 缓存机制测试

修改 HTML → 重新构建 → 观察速度：
- **第一次构建**: ~30 秒 (下载基础镜像)
- **第二次构建**: ~3 秒 (利用缓存)

Docker 缓存检查：修改 COPY 之前的指令 → 所有层重新构建；修改 COPY 之后的指令 → 只有该层及之后层重新构建

---

## 🏗️ 实践 2: 多阶段构建优化

**原始版本** (80MB+):
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y git
COPY . .
RUN npm install
RUN npm run build
CMD ["npm", "start"]
```

**多阶段构建** (20MB):
```dockerfile
# 阶段 1: 构建
FROM node:alpine AS builder
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
RUN npm run build

# 阶段 2: 运行时
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

| 指标 | 原始版本 | 多阶段构建 |
|------|---------|-----------|
| 镜像大小 | ~80MB | ~20MB |
| 安全性 | 包含构建工具 | 只保留运行时 |

---

## 📚 常用命令

```bash
docker builder prune -a         # 清理缓存
docker history my-image:1.1     # 查看镜像层
docker build --no-cache ...     # 禁用缓存构建
```

---

*创建时间：2026-04-14 05:51 UTC*