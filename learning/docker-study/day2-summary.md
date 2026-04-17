# Docker 学习 - Day 2 完成报告

## ✅ 今日完成

### 1. 创建第一个 Dockerfile
- ✅ 创建独立学习目录 `/root/learning/docker-study/hello-app/`
- ✅ 编写 `index.html` (静态网页)
- ✅ 编写 `Dockerfile` (自定义镜像构建脚本)

### 2. 构建自定义镜像
- ✅ 镜像名称：`my-first-docker-image:1.0`
- ✅ 镜像大小：62.2MB (比原版 nginx 稍微大一点)
- ✅ 镜像 ID: `f628e8b24ac8`

### 3. 运行容器测试
- ✅ 容器名称：`docker-day2-test`
- ✅ 端口映射：9092 → 80
- ✅ HTTP 200 响应

---

## 📊 技术细节

### 镜像分层构建
```
Step 1/8 : FROM nginx:alpine          # 基础镜像层
Step 2/8 : LABEL maintainer="..."     # 元数据层
Step 3/8 : LABEL version="1.0"        # 元数据层
Step 4/8 : LABEL description="..."    # 元数据层
Step 5/8 : COPY index.html ...        # 内容层
Step 6/8 : EXPOSE 80                  # 配置层
Step 7/8 : HEALTHCHECK ...            # 配置层
Step 8/8 : CMD ["nginx", ...]         # 启动命令层
```

### 重要指令

**FROM**: 指定基础镜像 (`FROM nginx:alpine`)
**LABEL**: 添加元数据
**COPY**: 复制文件到镜像
**EXPOSE**: 声明端口
**HEALTHCHECK**: 健康检查
**CMD**: 默认启动命令

---

## 💡 优化技巧

- 使用 `alpine` 精简版镜像
- 多阶段构建 (后续学习)
- 利用缓存机制

---

*完成时间：2026-04-14 03:21 UTC*