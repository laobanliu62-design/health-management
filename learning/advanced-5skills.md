# 📚 OpenClaw 系统开发 - 进阶5大技能学习笔记

> 学习日期: 2026-04-21
> 学习者: 来福 🐕
> 模式: 头悬梁锥刺股 💀

---

## 1️⃣ Shell 脚本编程

### 基础语法速查
```bash
# 变量
NAME="来福"
echo "我是$NAME"          # 我是来福
echo "我是${NAME}🐕"      # 我是来福🐕

# 条件
if [ -f "/tmp/test" ]; then
    echo "文件存在"
elif [ -d "/tmp/dir" ]; then
    echo "目录存在"
else
    echo "都不存在"
fi

# 循环
for i in 1 2 3; do echo $i; done
for f in *.log; do rm $f; done
while read line; do echo $line; done < file.txt

# 函数
check_port() {
    local port=$1
    lsof -ti:$port >/dev/null 2>&1
}

# 常用技巧
set -euo pipefail          # 严格模式: 任何错误立即退出
trap 'echo "出错在$LINENO行"' ERR  # 错误捕获
local var="局部变量"        # 函数内局部变量
```

### 实战: 系统健康检查脚本
```bash
#!/bin/bash
set -euo pipefail

# 颜色
RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' NC='\033[0m'

check_service() {
    local name=$1 port=$2
    if curl -s --connect-timeout 2 "http://localhost:$port/health" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $name (:$port) 正常${NC}"
    else
        echo -e "${RED}❌ $name (:$port) 异常${NC}"
    fi
}

echo "=== HiClaw 系统健康检查 $(date '+%Y-%m-%d %H:%M:%S') ==="
check_service "Gateway" 18799
check_service "雷达" 8091
check_service "Higress" 8080
check_service "MinIO" 9001
check_service "Matrix" 6167

# 磁盘
usage=$(df -h / | awk 'NR==2{print $5}' | tr -d '%')
if [ "$usage" -gt 80 ]; then
    echo -e "${RED}❌ 磁盘使用 ${usage}%${NC}"
else
    echo -e "${GREEN}✅ 磁盘使用 ${usage}%${NC}"
fi

# Docker
if docker ps >/dev/null 2>&1; then
    containers=$(docker ps -q | wc -l)
    echo -e "${GREEN}✅ Docker: ${containers} 个容器运行中${NC}"
else
    echo -e "${RED}❌ Docker 未运行${NC}"
fi
```

---

## 2️⃣ CI/CD (GitHub Actions)

### 核心概念
```
Push代码 → GitHub触发 → Runner执行 → 测试/构建/部署
```

### 工作流文件结构
```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [master]
  pull_request:
    branches: [master]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.10' }
      - run: pip install -r requirements.txt
      - run: pytest

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/build-push-action@v5
        with:
          context: .
          push: false
          tags: hiclaw/company-search:latest
```

### 关键配置项
```yaml
# 触发条件
on:
  push:                    # 推送触发
  schedule:                # 定时触发
    - cron: '0 0 * * *'   # 每天0点
  workflow_dispatch:       # 手动触发

# 环境变量
env:
  DOCKER_REGISTRY: ghcr.io

# Secrets (敏感信息)
- run: docker login -u ${{ secrets.DOCKER_USER }} -p ${{ secrets.DOCKER_PASS }}

# 产物
- uses: actions/upload-artifact@v4
  with: { path: dist/ }

# 缓存 (加速构建)
- uses: actions/cache@v4
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
```

---

## 3️⃣ Nginx 反向代理

### hiclaw-manager 中的 Nginx 配置
```nginx
# 典型反向代理配置
upstream gateway {
    server 127.0.0.1:18799;
}

upstream radar {
    server 127.0.0.1:8091;
}

server {
    listen 8080;
    server_name _;

    # Gateway API
    location /v1/ {
        proxy_pass http://gateway;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # 雷达服务
    location /radar/ {
        proxy_pass http://radar/;
    }

    # 静态文件
    location /static/ {
        alias /var/www/static/;
        expires 30d;
    }

    # WebSocket
    location /ws/ {
        proxy_pass http://gateway;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### 常用操作
```bash
nginx -t                    # 测试配置
nginx -s reload             # 热重载
nginx -s stop               # 停止

# 性能调优
worker_processes auto;       # CPU核心数
worker_connections 1024;     # 每个worker连接数
gzip on;                    # 压缩
gzip_types text/plain application/json;  # 压缩类型

# 负载均衡
upstream backend {
    least_conn;             # 最少连接
    server 10.0.0.1:8000 weight=3;
    server 10.0.0.2:8000 weight=1;
    server 10.0.0.3:8000 backup;  # 备用
}
```

---

## 4️⃣ SSL/TLS 证书

### 证书类型
```
DV (域名验证)   - 最快，自动签发
OV (组织验证)   - 需要公司证明
EV (扩展验证)   - 最严格，浏览器绿标
```

### Let's Encrypt 免费证书
```bash
# 安装 certbot
apt install certbot

# 获取证书
certbot certonly --standalone -d example.com

# 证书位置
/etc/letsencrypt/live/example.com/fullchain.pem  # 证书链
/etc/letsencrypt/live/example.com/privkey.pem    # 私钥

# 自动续期 (certbot 自带定时器)
certbot renew --dry-run    # 测试续期

# Nginx 配置 HTTPS
server {
    listen 443 ssl http2;
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
}

# HTTP → HTTPS 重定向
server {
    listen 80;
    return 301 https://$host$request_uri;
}
```

### 自签名证书 (开发用)
```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem \
    -days 365 -nodes -subj "/CN=localhost"
```

---

## 5️⃣ 监控告警 (Prometheus)

### 架构
```
被监控服务 → /metrics → Prometheus → 告警规则 → Alertmanager → 通知
                                    → Grafana → 可视化面板
```

### Python FastAPI 接入 Prometheus
```python
from prometheus_client import Counter, Histogram, generate_latest
from fastapi import Response

REQUEST_COUNT = Counter('http_requests_total', 'Total requests', ['method', 'endpoint'])
REQUEST_TIME = Histogram('http_request_duration_seconds', 'Request duration', ['endpoint'])

@app.get("/metrics")
async def metrics():
    return Response(content=generate_latest(), media_type="text/plain")
```

### Prometheus 配置
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'radar'
    static_configs:
      - targets: ['localhost:8091']
  
  - job_name: 'gateway'
    static_configs:
      - targets: ['localhost:18799']

# 告警规则
rule_files:
  - alerts.yml
```

```yaml
# alerts.yml
groups:
  - name: hiclaw
    rules:
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels: { severity: critical }
        annotations:
          summary: "服务 {{ $labels.job }} 宕机"
      
      - alert: HighMemory
        expr: process_resident_memory_bytes > 1073741824
        for: 5m
        labels: { severity: warning }
        annotations:
          summary: "{{ $labels.job }} 内存超过1GB"
```

---

## 📊 学习进度

| 技能 | 理论 | 实操 | 掌握度 |
|------|------|------|--------|
| Shell 脚本 | ✅ | ⏳ | 70% |
| CI/CD | ✅ | ⏳ | 60% |
| Nginx | ✅ | ⏳ | 65% |
| SSL/TLS | ✅ | ⏳ | 60% |
| 监控告警 | ✅ | ⏳ | 55% |

---

*来福 🐕 2026-04-21 11:27 北京时间*