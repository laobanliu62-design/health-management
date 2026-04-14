import 'dart:async';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/blood_pressure_record.dart';

class BloodPressureService {
  static BloodPressureService? _instance;
  Box<String>? _recordBox;
  bool _isInitialized = false;

  // 单例模式
  factory BloodPressureService() {
    _instance ??= BloodPressureService._internal();
    return _instance!;
  }

  BloodPressureService._internal();

  /// 获取实例（需要先调用 initialize）
  BloodPressureService? get instance {
    if (!_isInitialized) {
      throw Exception('BloodPressureService not initialized. Call initialize() first.');
    }
    return this;
  }

  /// 初始化 Hive
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 注册 Hive 适配器
    // Hive 代码生成器会自动生成适配器，这里直接注册类型

    // 获取应用文档目录
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final boxPath = '${documentsDirectory.path}/blood_pressure_box';

    // 打开 Hive box
    _recordBox = await Hive.openBox<String>(boxPath);

    // 注册类型适配器（如果代码生成器还没生成）
    // Hive.registerAdapter(BloodPressureRecordAdapter());

    _isInitialized = true;
  }

  /// 检查是否已初始化
  bool get isInitialized => _isInitialized;

  /// 保存记录
  Future<void> saveRecord(BloodPressureRecord record) async {
    final service = instance;
    if (service == null || _recordBox == null) {
      throw Exception('Service not initialized');
    }

    // 使用 userId + createdAt 作为键
    final key = '${record.userId}_${record.createdAt.millisecondsSinceEpoch}';
    
    // 序列化对象为 JSON
    final jsonRecord = {
      'userId': record.userId,
      'systolic': record.systolic,
      'diastolic': record.diastolic,
      'createdAt': record.createdAt.toIso8601String(),
    };

    await _recordBox!.put(key, jsonRecord.toString());
  }

  /// 获取所有记录
  Future<List<BloodPressureRecord>> getAllRecords() async {
    final service = instance;
    if (service == null || _recordBox == null) {
      throw Exception('Service not initialized');
    }

    final records = <BloodPressureRecord>[];

    for (final key in _recordBox!.keys) {
      final jsonStr = _recordBox!.get(key);
      if (jsonStr != null) {
        try {
          final jsonData = jsonStr.substring(1, jsonStr.length - 1); // 移除 {}
          // 简单解析 JSON 字符串
          final jsonMap = _parseJsonString(jsonStr);
          if (jsonMap != null) {
            final record = BloodPressureRecord(
              userId: jsonMap['userId'] as String,
              systolic: jsonMap['systolic'] as int,
              diastolic: jsonMap['diastolic'] as int,
              createdAt: DateTime.parse(jsonMap['createdAt'] as String),
            );
            records.add(record);
          }
        } catch (e) {
          print('Error parsing record: $e');
        }
      }
    }

    // 按时间倒序排序
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return records;
  }

  /// 解析 JSON 字符串为 Map
  Map<String, dynamic>? _parseJsonString(String jsonStr) {
    try {
      // 移除首尾的 {}
      if (jsonStr.startsWith('{') && jsonStr.endsWith('}')) {
        jsonStr = jsonStr.substring(1, jsonStr.length - 1);
      }

      final Map<String, dynamic> map = {};

      // 简单解析键值对
      final RegExp regex = RegExp(r'"([^"]+)":\s*"([^"]*)"');
      final Iterable<RegExpMatch> matches = regex.allMatches(jsonStr);

      for (final match in matches) {
        final key = match.group(1);
        final value = match.group(2);
        if (key != null && value != null) {
          map[key] = value;
        }
      }

      return map;
    } catch (e) {
      return null;
    }
  }

  /// 获取最新一条记录
  Future<BloodPressureRecord?> getLatestRecord() async {
    final records = await getAllRecords();
    return records.isNotEmpty ? records.first : null;
  }

  /// 清空所有记录（测试用）
  Future<void> clearAll() async {
    final service = instance;
    if (service == null || _recordBox == null) {
      throw Exception('Service not initialized');
    }

    await _recordBox!.clear();
  }

  /// 获取记录数量
  Future<int> getCount() async {
    final service = instance;
    if (service == null || _recordBox == null) {
      throw Exception('Service not initialized');
    }

    return _recordBox!.length;
  }

  /// 关闭 Hive
  Future<void> close() async {
    if (_recordBox != null) {
      await _recordBox!.close();
      _isInitialized = false;
    }
  }
}
