# 📚 Docker 学习 Day 5 - 网络和卷管理

**学习时间**: 2026-04-15 01:45 UTC  
**学习时长**: ~15 分钟

---

## 🎯 学习目标

1. ✅ 创建自定义 Docker 网络
2. ✅ 配置数据卷实现数据持久化
3. ✅ 容器间通信测试
4. ✅ 使用 docker-compose 编排多容器

---

## ✅ Day 5-1: 创建自定义网络

### 操作步骤

```bash
# 创建自定义网络
docker network create docker-study-network

# 查看网络列表
docker network ls | grep docker-study
```

**结果**: 
- ✅ 网络 ID: `6fb32d62de8b`
- ✅ 网络名称: `docker-study-network`
- ✅ 网络驱动：`bridge`

### 网络类型说明

| 类型 | 说明 | 使用场景 |
|------|------|----------|
| **bridge** (默认) | 容器间私有网络 | 单主机容器通信 |
| **host** | 使用宿主机网络 | 高性能网络需求 |
| **overlay** | 跨主机网络 | Docker Swarm 集群 |
| **macvlan** | 直接连接物理网络 | 容器需要物理网络地址 |
| **none** | 无网络 | 隔离容器 |

---

## ✅ Day 5-2: 连接容器到网络

### 操作步骤

```bash
# 连接 redis 到网络
docker network connect docker-study-network docker-study-redis

# 连接前端到网络
docker network connect docker-study-network docker-study-frontend
```

**结果**: 
- ✅ 两个容器都在同一网络中
- ✅ 可以通过容器名互相通信

---

## ✅ Day 5-3: 容器间通信测试

同网络的容器可以直接用容器名访问，网络隔离保证安全性。

遇到的问题：
1. ❌ 端口冲突: 8080 端口已被占用
2. ❌ 容器重启: 容器需要重新配置网络
解决方案：使用新端口（9094 和 9092）

---

## ✅ Day 5-4: Docker Volumes 数据卷管理

```bash
docker volume create redis-data
docker volume ls | grep redis
```

数据卷作用：数据持久化、数据共享、备份恢复

---

## ✅ Day 5-5: docker-compose 进阶配置

### docker-compose-v2.yml

```yaml
version: '3.8'

services:
  frontend:
    image: my-first-docker-image:v1.2
    ports:
      - "9094:80"
    networks:
      - docker-study-network
    restart: unless-stopped

  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - docker-study-network
    restart: unless-stopped

networks:
  docker-study-network:
    driver: bridge

volumes:
  redis-data:
```

---

*完成时间：2026-04-15 01:45 UTC*