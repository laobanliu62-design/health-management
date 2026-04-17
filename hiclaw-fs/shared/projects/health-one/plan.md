# Project: HealthOne 血压记录 APP

**ID**: health-one  
**Status**: development  
**Room**: (pending)  
**Created**: 2026-04-09T02:40:00Z  

## 项目一句话
**HealthOne = 一个让用户每天 1 分钟完成血压记录的 APP**

---

## 🎯 核心理念
**先做出来，再变优秀**

---

## 一、项目只做 4 件事

1. ✅ **记录数据**（血压）
2. ✅ **显示数据**（列表）
3. ⏳ **展示趋势**（后续版本）
4. ⏳ **提醒用户**（每天）

---

## 二、用户核心流程

**打开 APP → 首页 → 点击记录 → 输入 → 保存 → 返回首页**

**目标：3 秒完成操作**

---

## 三、页面结构

### ✅ 首页
- 今日血压（最新一条）
- 按钮：「记录血压」

### ✅ 记录页
- 输入收缩压
- 输入舒张压
- 点击保存

### ✅ 历史页
- 血压记录列表

---

## 四、数据结构

```dart
class BloodPressureRecord {
  String userId;           // 用户 ID
  int systolic;            // 收缩压（高压）
  int diastolic;           // 舒张压（低压）
  DateTime createdAt;      // 创建时间
}
```

---

## 五、技术方案

| 项目 | 方案 |
|------|------|
| 前端 | Flutter |
| 存储 | 本地 Hive |
| 提醒 | flutter_local_notifications（后续） |
| 原则 | **能跑优先** |

---

## 六、开发进度

### ✅ Phase 1: 项目初始化 (DONE)
- [x] 创建 Flutter 项目结构
- [x] pubspec.yaml 配置
- [x] 项目目录创建

### ✅ Phase 2: 核心功能开发 (IN PROGRESS)
- [x] 输入页面（血压）✅
- [x] 本地存储（Hive）✅
- [x] 首页展示 ✅
- [x] 历史记录列表 ✅
- [ ] 生成 Hive Adapter

### ⏳ Phase 3: 提醒功能 (TODO)
- [ ] 每日提醒设置
- [ ] 通知功能

---

## 七、文件结构

```
health-one/app/
├── pubspec.yaml              # 依赖配置
├── analysis_options.yaml     # Lint 配置
└── lib/
    ├── main.dart             # 入口文件
    ├── models/
    │   └── blood_pressure_record.dart  # 数据模型
    ├── screens/
    │   ├── home_screen.dart          # 首页
    │   ├── record_screen.dart        # 记录页
    │   └── history_screen.dart       # 历史页
    └── services/
        └── blood_pressure_service.dart  # 存储服务
```

---

## 八、下一步任务

### 1. 生成 Hive Adapter
```bash
cd app
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. 运行应用
```bash
cd app
flutter pub get
flutter run
```

### 3. 测试功能
- 记录血压 → 查看是否保存
- 重新打开 → 查看最新数据
- 历史列表 → 查看所有记录

---

## 九、成功标准

- ✅ **能记录血压** - 已实现
- ✅ **重新打开还能看到数据** - 已实现
- ⏳ **每天能收到提醒** - 待实现

---

## 十、执行原则

- ❌ 不加复杂功能
- ❌ 不优化设计
- ✅ **先跑通流程**
- ✅ **一步一步做**

---

## Change Log

- **2026-04-09T02:40:00Z**: 项目初始化，创建 Flutter 项目结构
- **2026-04-09T02:40:00Z**: 完成核心功能开发（首页、记录页、历史页、Hive 存储）
- **2026-04-09T02:40:00Z**: 项目代码已同步到 MinIO
