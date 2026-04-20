# 📚 OpenClaw 系统开发 - 8大核心技能学习笔记

> 学习日期: 2026-04-20
> 学习者: 来福 🐕

---

## 1️⃣ Docker 容器

### 现状
- WSL 环境未安装 Docker（Windows Docker Desktop 也未装）
- OpenClaw 当前直接跑在 Node.js 上，非容器化
- 之前 Docker 学习已完成 Day 1-7（基础已掌握）

### OpenClaw 中的 Docker
- `docker-setup.sh` - Docker 启动脚本 (500行)
- `Dockerfile` 存在于 `/opt/openclaw/` 
- 关键逻辑:
  - 读取 `openclaw.json` 获取 gateway token
  - 支持 Python3/Node.js 两种方式解析 JSON
  - 支持 sandbox 模式（容器内嵌套容器）
  - 环境变量: `OPENCLAW_IMAGE`, `OPENCLAW_HOME_VOLUME`, `OPENCLAW_SANDBOX`

### 待实操
- [ ] 安装 Docker Desktop / WSL2 Docker
- [ ] 用 docker-setup.sh 跑通 OpenClaw 容器版

---

## 2️⃣ WSL/Linux 命令

### 关键发现
- 系统: Ubuntu 22.04 on WSL2 (Linux 6.6.87.2-microsoft-standard-WSL2)
- 没有 systemd（服务管理用 crontab @reboot 替代）
- 进程管理: `ps aux`, `kill`, `pkill`
- 端口查看: `lsof -ti:端口`, `fuser 端口/tcp`

### 常用命令速查
```bash
# 进程
ps aux | grep xxx      # 查进程
kill -9 PID            # 强杀
pkill -f "关键字"      # 按名杀

# 端口
lsof -ti:8091          # 查占用端口的进程
fuser -k 8091/tcp      # 直接杀占用端口的进程
curl -s localhost:端口  # 快速测端口

# 服务自启 (无 systemd)
crontab -l             # 查定时任务
echo "@reboot /path/start.sh" | crontab -  # 开机启动

# 网络诊断
curl -v url            # 详细请求
getent hosts domain    # DNS 解析
```

---

## 3️⃣ JSON 配置

### OpenClaw 配置结构 (`/root/.openclaw/openclaw.json`)
```
顶层配置项:
├── models          # AI 模型配置 (provider + 模型列表)
├── agents          # Agent 配置 (默认模型 + 各agent)
├── commands        # 命令配置
├── session         # 会话配置
├── channels        # 通道配置 (Matrix等)
├── gateway         # 网关配置 (端口/认证/远程)
├── plugins         # 插件配置
└── meta            # 元信息
```

### 关键配置详解
```json
// 模型 Provider
"providers": {
  "fcloud": {
    "baseUrl": "http://223.167.85.184:3000/v1",  // OpenAI 兼容接口
    "apiKey": "sk-xxx",
    "api": "openai-completions",                   // 协议类型
    "models": [
      { "id": "qwen-35b", "name": "Qwen 35B", "reasoning": false },
      { "id": "glm-5", "name": "GLM-5.1", "reasoning": true }
    ]
  }
}

// Gateway
"gateway": {
  "port": 18799,           // 网关端口
  "mode": "local",         // 本地模式
  "auth": { "token": "xxx" },  // 认证令牌
  "remote": { "token": "xxx" } // 远程访问令牌
}
```

### 配置修改方式
1. `gateway config.patch` - 部分更新（推荐）
2. `gateway config.apply` - 全量替换
3. 修改后自动重启生效

---

## 4️⃣ Gateway 网关原理

### 架构
```
用户消息 → Matrix/Telegram等 → Gateway(18799) → Agent → AI模型 → 返回
```

### 核心进程
- `openclaw` (PID 4299) - 主进程
- `openclaw-gateway` (PID 5220) - 网关进程

### Gateway 功能
1. **消息路由**: 接收各 Channel 消息，分发给 Agent
2. **模型调度**: 根据 Agent 配置选择 AI 模型
3. **会话管理**: 创建/销毁/切换会话
4. **工具调用**: Agent 调用工具的中间层
5. **认证鉴权**: token 验证
6. **Cron调度**: 定时任务管理

### 入口文件链
```
openclaw.mjs → dist/entry.js → src/gateway/
```

---

## 5️⃣ OpenAI 兼容接口

### 当前配置
- Provider: fcloud
- BaseURL: `http://223.167.85.184:3000/v1`
- 协议: openai-completions

### 接口格式
```bash
# Chat Completions
POST /v1/chat/completions
{
  "model": "glm-5",
  "messages": [{"role": "user", "content": "你好"}],
  "temperature": 0.7,
  "stream": true
}

# 响应
{
  "choices": [{
    "message": {"role": "assistant", "content": "..."}
  }],
  "usage": {"prompt_tokens": 10, "completion_tokens": 20}
}
```

### 可用模型
| 模型 | 推理 | 输入 | 用途 |
|------|------|------|------|
| qwen-35b | ❌ | text | 日常对话 |
| glm-5 | ✅ | text | 深度思考 |
| kimi-k25 | ✅ | text+image | 多模态 |
| minimax-m25 | ✅ | text | 推理 |

---

## 6️⃣ Python 后端

### 环境信息
- Python 3.10.12
- 已安装: fastapi, uvicorn, httpx, beautifulsoup4, lxml
- pip 26.0.1

### 在 OpenClaw 中的应用
- `docker-setup.sh` 用 Python3 解析 JSON 配置
- Skills 中可能有 Python 脚本
- 雷达(企业搜索)服务: FastAPI + httpx + BeautifulSoup

### 已完成项目
- 📡 雷达企业搜索服务 (端口 8091)
  - FastAPI 框架
  - 多源聚合爬取
  - 标准 JSON 输出

---

## 7️⃣ 服务启动时序

### OpenClaw 启动链
```
1. Node.js v22.22.1 检查
2. openclaw.mjs 入口
3. 加载 dist/entry.js
4. 读取 ~/.openclaw/openclaw.json
5. 启动 Gateway (端口 18799)
6. 连接 Channels (Matrix等)
7. 加载 Skills
8. Agent 就绪，等待消息
```

### 雷达服务启动链
```
1. crontab @reboot 触发 start.sh
2. start.sh while 循环保证存活
3. python3 main.py 启动 FastAPI
4. uvicorn 监听 0.0.0.0:8091
5. 健康检查: GET /health
```

---

## 8️⃣ Docker 日志排查

### 常用命令 (待 Docker 安装后实操)
```bash
# 基础
docker logs <container>           # 查看日志
docker logs -f <container>        # 实时跟踪
docker logs --tail 100 <c>        # 最后100行
docker logs --since 1h <c>        # 最近1小时

# Compose
docker compose logs               # 所有服务日志
docker compose logs gateway       # 指定服务
docker compose logs -f --tail 50  # 实时+最后50行

# 排查流程
1. docker ps -a                   # 查容器状态
2. docker logs <container>        # 看日志
3. docker inspect <container>     # 查配置
4. docker exec -it <c> bash       # 进入容器
5. docker stats                   # 资源使用
```

### OpenClaw 日志
```bash
# Gateway 日志
journalctl -u openclaw-gateway    # systemd 环境

# 当前环境
cat /tmp/hiclaw-company-search.log  # 雷达服务日志
```

---

## 📊 学习进度

| 技能 | 理论 | 实操 | 掌握度 |
|------|------|------|--------|
| Docker 容器 | ✅ | ⏳(需安装) | 60% |
| WSL/Linux 命令 | ✅ | ✅ | 80% |
| JSON 配置 | ✅ | ✅ | 85% |
| Gateway 原理 | ✅ | ⏳ | 70% |
| OpenAI 兼容接口 | ✅ | ✅ | 80% |
| Python 后端 | ✅ | ✅ | 85% |
| 服务启动时序 | ✅ | ✅ | 80% |
| Docker 日志排查 | ✅ | ⏳(需Docker) | 50% |

---

*来福 🐕 2026-04-20 16:45 北京时间*