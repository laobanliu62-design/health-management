# 🐳 Health Management App - 构建镜像

# 阶段 1: 使用 Dart SDK 构建 Flutter Web
FROM dart:3.4

WORKDIR /app

# 复制依赖文件
COPY pubspec.yaml pubspec.lock ./

# 获取依赖
RUN dart pub get

# 复制源代码
COPY . .

# 构建 Flutter Web
RUN dart compile web build/web --web-renderer html

# 阶段 2: Nginx 运行
FROM nginx:alpine

# 复制构建产物
COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
