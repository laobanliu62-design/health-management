# Docker 学习 - Day 4

## 目标
1. 创建 `.dockerignore` 文件
2. 学习 docker-compose 基础
3. 一键编排多容器应用

---

## 📝 实践 1: .dockerignore 文件

排除不需要的文件，减小镜像大小、加快构建、避免泄露敏感信息。

```bash
# 标准内容
.DS_Store
*.log
*.tmp
node_modules/
.git/
Dockerfile*
.dockerignore
test/
```

---

## 🏗️ 实践 2: docker-compose 基础

```yaml
version: '3.8'

services:
  frontend:
    build: ./hello-app
    ports:
      - "9090:80"
    networks:
      - app-network

  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - app-network

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: myapp
    volumes:
      - mysql-data:/var/lib/mysql
    networks:
      - app-network

volumes:
  redis-data:
  mysql-data:

networks:
  app-network:
    driver: bridge
```

### 常用命令

```bash
docker-compose up -d        # 启动所有服务
docker-compose ps            # 查看状态
docker-compose logs -f       # 查看日志
docker-compose down          # 停止
docker-compose down -v       # 停止并删除数据卷
```

---

*创建时间：2026-04-14 05:54 UTC*