# 🧠 MEMORY.md - 来福的长期记忆

> **这是来福的经验总结与核心记忆**

---

## ⚙️ 配置偏好

### 时间设置
- **时区**: 北京时间 (UTC+8, Asia/Shanghai)
- **格式**: 2026-04-15 10:27 北京时间
- **说明**: 所有时间都用北京时间

### GitHub 仓库
- **仓库**: https://github.com/laobanliu62-design/health-management
- **SSH Key**: github_deploy 密钥对已配置
- **分支**: master

---

## ⏰ 定时任务

### Docker 每日自动学习
- **执行时间**: 每天 07:00 北京时间 (Asia/Shanghai)
- **任务 ID**: c254dd50-5ffd-4a0b-bb92-ced24e388db2
- **状态**: 🟢 已启用
- **当前进度**: Day 5/7 完成
- **下次**: Day 6 (Docker Compose 进阶 + 环境变量 + 健康检查)

### Git 自动备份
- **执行时间**: 每 3 小时 (00:09, 03:09, 06:09, 09:09, 12:09, 15:09, 18:09, 21:09 UTC)
- **任务 ID**: ca360614-a58e-44c1-a0f5-443a7199ca8c
- **状态**: 🟢 已启用
- **仓库**: https://github.com/laobanliu62-design/health-management

### Worker 状态监控
- Worker 进度检查: 每 1 小时
- Worker 状态汇报: 每 1 小时
- 上下文监控: 每 30 分钟

---

## 📝 规定与偏好

### 核心原则
- **先做出来，再变优秀** 🚀
- 先行动后汇报，不反复确认
- 发现问题直接修复，修完再报
- 所有时间用北京时间
- 不加复杂功能，先跑通流程

### 清理策略
- 100k tokens 立即预警
- 80% 预警 / 95% 清理
- 每日自动清理 >3 天日志
- 清理前先备份关键信息到 memory/

### Token 管理
- 模型上限 131k tokens
- 预警线 100k (76%)
- 避免日志堆积导致超限（教训：2026-04-13 超限 150k>131k）

---

## 📋 项目记录

### 1. HealthOne 血压记录APP
- **项目ID**: health-one
- **状态**: development（核心完成，测试中）
- **技术栈**: Flutter + Hive (本地存储)
- **一句话**: 让用户每天1分钟完成血压记录
- **核心流程**: 打开APP→首页→记录→输入→保存→返回（3秒完成）
- **页面**: 首页（最新血压+记录按钮）、记录页（收缩压/舒张压）、历史页
- **数据模型**: BloodPressureRecord {userId, systolic, diastolic, createdAt}
- **开发进度**: Phase 1-2 完成，Phase 3（提醒）待做
- **成功标准**: 能记录血压 ✅、重开能看数据 ✅、每天提醒 ⏳

### 2. 健康管理系统
- **项目ID**: health-system
- **状态**: planning
- **Worker**: @data-manager
- **模块**: 运动追踪、饮食管理、睡眠监测、体重追踪、报告生成

### 3. health-management (Flutter项目)
- **状态**: testing (6/6 任务完成)
- **文件**: 22 个 Dart 文件
- **CI/CD**: GitHub Actions 已配置（flutter test + analyze + build apk）

---

## 🤖 Worker 系统记录

### 9 个 Worker 配置
| Worker | 角色 | 创建时间 | Matrix房间 |
|--------|------|----------|-----------|
| flutter-dev | Flutter 开发专家 | 04-09 | !flutter-dev-room |
| doc-writer | 文档工程师 | 04-14 | !doc-writer-room |
| qa-tester | 测试工程师 | 04-14 | !qa-tester-room |
| learning-specialist | 学习专家 | 04-14 | - |
| devops-engineer | DevOps 工程师 | 04-14 09:22 | !devops-engineer-room |
| docker-expert | Docker 容器化专家 | 04-14 09:18 | !g6WaFq9Yk7vybIbeYU |
| chat-companion | 闲聊陪伴 Worker | 04-14 10:23 | !BFdL3iD0dFMWlvdvkO |
| data-engineer | 数据工程师 | - | - |
| test-runner | 测试运行器 | - | !test-runner-room |

### Worker 人格设定
- chat-companion: 来福风格，幽默+专业+周到，主动问候+分享趣闻+情绪支持
- 所有Worker都是AI Agent，不需要休息，时间单位是分钟和小时

### 历史问题
- flutter-dev Worker 曾失联 17 小时（僵尸进程 PID 43403）
- test-runner 22 个编译错误（@HibeField→@HiveField, CardTheme→CardThemeData, num变量冲突）
- Matrix 房间兼容性问题，6 个旧房间已重建
- Matrix 消息发送失败 (M_FORBIDDEN)

---

## 📚 Docker 学习进度

### 已完成 (Day 1-5)
- Day 1: Docker 环境检查(v29.1.3) + Hello World + Nginx ✅
- Day 2: 自定义 Dockerfile (62.2MB, nginx:alpine, 8层构建) ✅
- Day 3: 缓存机制(30s→3s) + 多阶段构建 ✅
- Day 4: .dockerignore + docker-compose + Redis(6379) ✅
- Day 5: 自定义网络(docker-study-network) + 数据卷(redis-data) + 容器间通信(ping<1ms) ✅

### 已完成 (Day 1-6)
- Day 1: Docker 环境检查(v29.1.3) + Hello World + Nginx ✅
- Day 2: 自定义 Dockerfile (62.2MB, nginx:alpine, 8层构建) ✅
- Day 3: 缓存机制(30s→3s) + 多阶段构建 ✅
- Day 4: .dockerignore + docker-compose + Redis(6379) ✅
- Day 5: 自定义网络(docker-study-network) + 数据卷(redis-data) + 容器间通信(ping<1ms) ✅
- Day 6: Compose进阶 + 环境变量(.env/env_file) + 健康检查(healthcheck) + 资源限制 + 日志轮转 ✅

### 已完成 (Day 1-7)
- Day 1: Docker 环境检查(v29.1.3) + Hello World + Nginx ✅
- Day 2: 自定义 Dockerfile (62.2MB, nginx:alpine, 8层构建) ✅
- Day 3: 缓存机制(30s→3s) + 多阶段构建 ✅
- Day 4: .dockerignore + docker-compose + Redis(6379) ✅
- Day 5: 自定义网络(docker-study-network) + 数据卷(redis-data) + 容器间通信(ping<1ms) ✅
- Day 6: Compose进阶 + 环境变量(.env/env_file) + 健康检查(healthcheck) + 资源限制 + 日志轮转 ✅
- Day 7: 镜像推送(Docker Hub) + 完整项目演练 + Week 1 总结 ✅

### Docker 学习进度

### Week 1 已完成 ✅
| 版本 | 大小 | 构建时间 | 特点 |
|------|------|----------|------|
| v1.0 | 62.2MB | ~30s | 初始版本 |
| v1.1 | 62.2MB | ~3s | 利用缓存 |
| optimized | 62.2MB | ~5s | 多阶段构建 |
| v1.2 | 62.2MB | ~3s | .dockerignore |

### 学习文件位置
/root/learning/docker-study/
- hello-app/ (index.html, Dockerfile, .dockerignore)
- day1-summary.md, day2-summary.md, day3-practice.md, day4-practice.md, day5-summary.md

---

## 🔄 仓库架构

- 2026-04-16 合并双仓库为单仓库
- hiclaw-fs 合并到主仓库
- 统一使用 /root/ 作为唯一仓库

---

## 📊 能力评分 (2026-04-14)
- Docker/K8s: 8.5
- CI/CD: 9.0
- 自动化: 9.5
- 总分: 8.7

---

## 💡 教训与经验

1. **Worker 僵尸进程**：超过 12 小时无响应需要人工介入
2. **Token 超限**：日志堆积导致，100k tokens 设预警线
3. **编译错误**：拼写错误和类型错误要仔细检查
4. **双仓库复杂**：合并后更简单
5. **先做出来再变优秀**：项目核心原则 🚀
6. **备份不够及时**：4月15-16日的记忆没来得及提交到GitHub就丢了

---

## 📝 待办事项

### 高优先级
- [ ] 启动 test-runner Worker
- [ ] 重新分配 flutter-dev 任务
- [ ] Docker 学习 Day 6-7
- [ ] 修复 Flutter 编译错误

### 中优先级
- [ ] doc-writer 编写 Flutter 文档
- [ ] qa-tester 编写测试用例
- [ ] Flutter 应用最终测试
- [ ] 重新配置定时任务（新环境）

### 低优先级
- [ ] devops-engineer Docker/K8s 部署
- [ ] docker-expert 镜像优化
- [ ] 配置远程访问（WSL 网络问题待解决）
- [ ] 健康管理系统项目启动

---

*最后更新：2026-04-17 (记忆全面恢复)*