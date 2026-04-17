# 📚 Docker 学习 Day 6 - Compose进阶 + 环境变量 + 健康检查

**学习时间**: 2026-04-17 11:24 北京时间

---

## 🎯 学习目标

1. Docker Compose 进阶配置
2. 环境变量管理 (.env + env_file)
3. 健康检查 (healthcheck) 配置
4. 实战：完整的多服务应用编排

---

## 📝 实践 1: 环境变量管理

### 方式1: .env 文件
```bash
# 创建 .env 文件
cat > /root/learning/docker-study/hello-app/.env << 'EOF'
APP_VERSION=1.2
APP_PORT=9094
REDIS_PORT=6379
NODE_ENV=production
EOF
```

### 方式2: docker-compose.yml 中引用
```yaml
version: '3.8'

services:
  frontend:
    image: my-first-docker-image:${APP_VERSION}
    ports:
      - "${APP_PORT}:80"
    environment:
      - NODE_ENV=${NODE_ENV}
    networks:
      - docker-study-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s

  redis:
    image: redis:alpine
    ports:
      - "${REDIS_PORT}:6379"
    volumes:
      - redis-data:/data
    networks:
      - docker-study-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 15s
      timeout: 3s
      retries: 3

networks:
  docker-study-network:
    driver: bridge

volumes:
  redis-data:
```

### 方式3: env_file 引用外部文件
```yaml
services:
  frontend:
    env_file:
      - .env
      - .env.local  # 可以叠加多个
```

---

## 📝 实践 2: 健康检查 (Healthcheck)

### Dockerfile 中的健康检查
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 --start-period=10s \
  CMD curl -f http://localhost/ || exit 1
```

### docker-compose.yml 中的健康检查
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost/"]
  interval: 30s    # 检查间隔
  timeout: 5s      # 超时时间
  retries: 3       # 重试次数
  start_period: 10s # 启动等待期
```

### 健康状态
- **healthy** ✅ — 健康检查通过
- **unhealthy** ❌ — 连续retries次失败
- **starting** 🔄 — 在start_period内
- **none** ⬜ — 没有配置健康检查

### 查看健康状态
```bash
docker inspect --format='{{.State.Health.Status}}' container_name
docker inspect --format='{{json .State.Health}}' container_name | python3 -m json.tool
```

---

## 📝 实践 3: Compose 进阶

### depends_on + 健康依赖
```yaml
services:
  frontend:
    depends_on:
      redis:
        condition: service_healthy  # 等redis健康才启动
    restart: unless-stopped

  redis:
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
```

### 资源限制
```yaml
services:
  frontend:
    deploy:
      resources:
        limits:
          cpus: '0.5'      # 最多用0.5核
          memory: 256M     # 最多256MB内存
        reservations:
          cpus: '0.1'      # 保底0.1核
          memory: 64M      # 保底64MB
```

### 日志配置
```yaml
services:
  frontend:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"    # 单个日志文件最大10MB
        max-file: "3"      # 最多保留3个日志文件
```

---

## 📝 实践 4: 实战演练

### 创建完整的docker-compose-prod.yml
```yaml
version: '3.8'

services:
  frontend:
    image: my-first-docker-image:${APP_VERSION:-1.2}
    ports:
      - "${APP_PORT:-9094}:80"
    networks:
      - docker-study-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  redis:
    image: redis:alpine
    ports:
      - "${REDIS_PORT:-6379}:6379"
    volumes:
      - redis-data:/data
    networks:
      - docker-study-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 15s
      timeout: 3s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: '0.3'
          memory: 128M
    logging:
      driver: "json-file"
      options:
        max-size: "5m"
        max-file: "2"

networks:
  docker-study-network:
    driver: bridge

volumes:
  redis-data:
```

---

## 🎓 知识点总结

### 环境变量三种方式
| 方式 | 使用场景 | 优先级 |
|------|----------|--------|
| .env文件 | compose自动加载 | 低 |
| environment | 直接在YAML中写 | 中 |
| docker run -e | 命令行覆盖 | 高 |

### 健康检查参数
| 参数 | 说明 | 默认值 |
|------|------|--------|
| interval | 检查间隔 | 30s |
| timeout | 超时时间 | 30s |
| retries | 重试次数 | 3 |
| start_period | 启动等待 | 0s |

### Compose进阶功能
- ✅ depends_on + condition: 精确控制启动顺序
- ✅ deploy.resources: CPU/内存限制
- ✅ logging: 日志轮转防磁盘爆满
- ✅ ${VAR:-default}: 环境变量带默认值

---

## 🚀 下一步 (Day 7)

- [ ] 镜像推送到 Docker Hub
- [ ] 完整项目演练：从零部署一个应用
- [ ] Week 1 总结

---

*完成时间：2026-04-17 11:24 北京时间*
*状态：Day 6 完成 ✅*
*进度：6/7 (86%)*