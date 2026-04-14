import 'package:flutter_test/flutter_test.dart';
import 'package:health_one/models/blood_pressure_record.dart';

void main() {
  group('BloodPressureRecord Service Integration Tests', () {
    test('数据模型序列化测试', () {
      final record = BloodPressureRecord(
        userId: 'user_test_001',
        systolic: 125,
        diastolic: 82,
        createdAt: DateTime(2024, 4, 13, 14, 30),
      );

      // 验证基本属性
      expect(record.userId, equals('user_test_001'));
      expect(record.systolic, equals(125));
      expect(record.diastolic, equals(82));
      expect(record.createdAt, equals(DateTime(2024, 4, 13, 14, 30)));

      // 验证计算属性
      expect(record.isNormal, isFalse);
      expect(record.status, equals('正常高值'));
    });

    test('极端值处理', () {
      // 最小值
      final minRecord = BloodPressureRecord(
        userId: 'user_001',
        systolic: 1,
        diastolic: 1,
        createdAt: DateTime.now(),
      );
      expect(minRecord.isNormal, isTrue);

      // 最大值
      final maxRecord = BloodPressureRecord(
        userId: 'user_001',
        systolic: 300,
        diastolic: 200,
        createdAt: DateTime.now(),
      );
      expect(maxRecord.isNormal, isFalse);
      expect(maxRecord.status, equals('偏高'));
    });

    test('边界值测试', () {
      // 刚好在正常范围内
      final boundaryNormal = BloodPressureRecord(
        userId: 'user_001',
        systolic: 119,
        diastolic: 79,
        createdAt: DateTime.now(),
      );
      expect(boundaryNormal.isNormal, isTrue);

      // 刚好超过正常范围
      final boundaryHigh = BloodPressureRecord(
        userId: 'user_001',
        systolic: 120,
        diastolic: 80,
        createdAt: DateTime.now(),
      );
      expect(boundaryHigh.isNormal, isFalse);
      expect(boundaryHigh.status, equals('正常高值'));
    });

    test('多个记录的排序', () {
      // 使用固定时间来避免时区问题
      final now = DateTime(2024, 4, 14, 12, 0);
      final records = [
        BloodPressureRecord(
          userId: 'user_001',
          systolic: 120,
          diastolic: 80,
          createdAt: now.subtract(const Duration(hours: 3)), // 09:00
        ),
        BloodPressureRecord(
          userId: 'user_001',
          systolic: 130,
          diastolic: 85,
          createdAt: now.subtract(const Duration(hours: 1)), // 11:00
        ),
        BloodPressureRecord(
          userId: 'user_001',
          systolic: 115,
          diastolic: 75,
          createdAt: now.subtract(const Duration(hours: 2)), // 10:00
        ),
      ];

      // 按时间倒序排序（最新在前）
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 验证排序正确：11:00 > 10:00 > 09:00
      expect(records.first.createdAt.hour, 11);
      expect(records[1].createdAt.hour, 10);
      expect(records.last.createdAt.hour, 9);
    });

    test('记录状态分类测试', () {
      final testCases = [
        {'systolic': 110, 'diastolic': 70, 'expectedStatus': '正常'},
        {'systolic': 118, 'diastolic': 78, 'expectedStatus': '正常'},
        {'systolic': 120, 'diastolic': 75, 'expectedStatus': '正常高值'},
        {'systolic': 125, 'diastolic': 80, 'expectedStatus': '正常高值'},
        {'systolic': 130, 'diastolic': 85, 'expectedStatus': '正常高值'},
        {'systolic': 140, 'diastolic': 90, 'expectedStatus': '偏高'},
        {'systolic': 150, 'diastolic': 95, 'expectedStatus': '偏高'},
        {'systolic': 135, 'diastolic': 90, 'expectedStatus': '偏高'},
      ];

      for (final testCase in testCases) {
        final record = BloodPressureRecord(
          userId: 'user_001',
          systolic: testCase['systolic']! as int,
          diastolic: testCase['diastolic']! as int,
          createdAt: DateTime.now(),
        );

        expect(
          record.status,
          equals(testCase['expectedStatus']),
          reason: '收缩压${testCase['systolic']},舒张压${testCase['diastolic']}的状态应该是${testCase['expectedStatus']}',
        );
      }
    });

    test('显示格式测试', () {
      final record = BloodPressureRecord(
        userId: 'user_001',
        systolic: 120,
        diastolic: 80,
        createdAt: DateTime(2024, 3, 5, 9, 5),
      );

      // 完整显示
      final fullDisplay = record.displayText();
      expect(fullDisplay, contains('🩺'));
      expect(fullDisplay, contains('120/80'));
      expect(fullDisplay, contains('mmHg'));
      expect(fullDisplay, contains('2024-03-05'));
      expect(fullDisplay, contains('09:05'));
      expect(fullDisplay, contains('偏高'));

      // 简化显示
      final shortDisplay = record.shortDisplay;
      expect(shortDisplay, contains('120/80'));
      expect(shortDisplay, contains('03/05'));
      expect(shortDisplay, contains('偏高'));
    });

    test('copyWith 方法验证', () {
      final original = BloodPressureRecord(
        userId: 'original_user',
        systolic: 120,
        diastolic: 80,
        createdAt: DateTime(2024, 1, 1),
      );

      final modified1 = original.copyWith(systolic: 130);
      expect(modified1.systolic, equals(130));
      expect(modified1.userId, equals('original_user'));
      expect(modified1.createdAt, equals(DateTime(2024, 1, 1)));

      final modified2 = original.copyWith(
        diastolic: 85,
        createdAt: DateTime(2024, 2, 1),
      );
      expect(modified2.diastolic, equals(85));
      expect(modified2.createdAt, equals(DateTime(2024, 2, 1)));
      expect(modified2.userId, equals('original_user'));
      expect(modified2.systolic, equals(120));

      // 不修改任何字段，应该完全相同
      final modified3 = original.copyWith();
      expect(modified3.userId, equals(original.userId));
      expect(modified3.systolic, equals(original.systolic));
      expect(modified3.diastolic, equals(original.diastolic));
      expect(modified3.createdAt, equals(original.createdAt));
    });

    test('时间格式验证', () {
      final record1 = BloodPressureRecord(
        userId: 'user_001',
        systolic: 120,
        diastolic: 80,
        createdAt: DateTime(2024, 1, 1, 0, 0),
      );
      expect(record1.displayText(), contains('01-01'));
      expect(record1.displayText(), contains('00:00'));

      final record2 = BloodPressureRecord(
        userId: 'user_001',
        systolic: 120,
        diastolic: 80,
        createdAt: DateTime(2024, 12, 31, 23, 59),
      );
      expect(record2.displayText(), contains('12-31'));
      expect(record2.displayText(), contains('23:59'));
    });

    test('多个用户 ID 测试', () {
      final records = [
        BloodPressureRecord(
          userId: 'user_A',
          systolic: 110,
          diastolic: 70,
          createdAt: DateTime.now(),
        ),
        BloodPressureRecord(
          userId: 'user_B',
          systolic: 140,
          diastolic: 90,
          createdAt: DateTime.now(),
        ),
        BloodPressureRecord(
          userId: 'user_C',
          systolic: 125,
          diastolic: 85,
          createdAt: DateTime.now(),
        ),
      ];

      expect(records.where((r) => r.userId == 'user_A').first.isNormal, isTrue);
      expect(records.where((r) => r.userId == 'user_B').first.isNormal, isFalse);
      expect(records.where((r) => r.userId == 'user_C').first.isNormal, isFalse);
    });
  });
}
