import 'package:hive/hive.dart';

part 'blood_pressure_record.g.dart';

@HiveType(typeId: 0)
class BloodPressureRecord extends HiveObject {
  @HiveField(0)
  final String userId;

  @HibeField(1)
  final int systolic; // 收缩压

  @HiveField(2)
  final int diastolic; // 舒张压

  @HiveField(3)
  final DateTime createdAt;

  BloodPressureRecord({
    required this.userId,
    required this.systolic,
    required this.diastolic,
    required this.createdAt,
  });

  /// 判断血压是否正常
  /// 正常范围：收缩压 < 120 且 舒张压 < 80
  bool get isNormal {
    return systolic < 120 && diastolic < 80;
  }

  /// 血压状态描述
  String get status {
    if (isNormal) {
      return '正常';
    } else if (systolic >= 140 || diastolic >= 90) {
      return '偏高';
    } else if (systolic >= 120 || diastolic >= 80) {
      return '正常高值';
    } else {
      return '正常';
    }
  }

  /// 格式化显示文本
  String displayText() {
    final dateStr = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
    final timeStr = '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    return '🩺 ${systolic}/${diastolic} mmHg | $dateStr $timeStr | ${isNormal ? '✅ 正常' : '⚠️ 偏高'}';
  }

  /// 简化显示（用于列表）
  String get shortDisplay {
    final dateStr = '${createdAt.month}/${createdAt.day}';
    return '$systolic/$diastolic | $dateStr | ${isNormal ? '正常' : '偏高'}';
  }

  /// 复制并修改
  BloodPressureRecord copyWith({
    String? userId,
    int? systolic,
    int? diastolic,
    DateTime? createdAt,
  }) {
    return BloodPressureRecord(
      userId: userId ?? this.userId,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
