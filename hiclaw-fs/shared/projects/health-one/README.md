# HealthOne - 血压记录 APP 🩺

> 一个让用户每天 1 分钟完成血压记录的 APP

---

## 🚀 快速开始

### 前置条件

- Flutter SDK >= 3.0.0
- Android Studio / Xcode
- Android 模拟器或 iOS 模拟器

### 安装和运行

```bash
# 1. 进入项目目录
cd health-one/app

# 2. 安装依赖
flutter pub get

# 3. 生成 Hive Adapter
flutter pub run build_runner build --delete-conflicting-outputs

# 4. 运行应用
flutter run
```

或者直接使用构建脚本：

```bash
cd health-one
chmod +x build.sh
./build.sh
```

---

## 📱 功能说明

### 首页
- 显示今日最新血压值
- 一键记录血压按钮

### 记录页
- 输入收缩压（高压）
- 输入舒张压（低压）
- 保存并返回首页

### 历史记录
- 查看所有历史血压记录
- 按时间倒序排列
- 正常/偏高状态标识

---

## 📊 数据结构

```dart
class BloodPressureRecord {
  String userId;      // 用户 ID
  int systolic;       // 收缩压
  int diastolic;      // 舒张压
  DateTime createdAt; // 记录时间
}
```

---

## 🛠️ 技术栈

- **Framework**: Flutter
- **Storage**: Hive (本地 NoSQL 数据库)
- **Notifications**: flutter_local_notifications (待实现)

---

## 📝 开发计划

### Phase 1 ✅ (已完成)
- 项目初始化
- 核心 UI 页面
- Hive 数据存储

### Phase 2 ⏳ (待开发)
- 每日提醒功能
- 数据导出
- 图表趋势分析

---

## 🎯 成功标准

- ✅ 能记录血压
- ✅ 重新打开还能看到数据
- ⏳ 每天能收到提醒

---

## 📄 许可

MIT License

---

**先做出来，再变优秀** 🚀
