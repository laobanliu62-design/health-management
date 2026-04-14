import 'package:flutter_test/flutter_test.dart';
import 'package:health_one/models/blood_pressure_record.dart';

void main() {
  group('BloodPressureRecord Tests', () {
    test('创建正常的血压记录', () {
      final record = BloodPressureRecord(
        userId: 'user_001',
        systolic: 110,
        diastolic: 70,
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      expect(record.userId, 'user_001');
      expect(record.systolic, 110);
      expect(record.diastolic, 70);
      expect(record.isNormal, true);
      expect(record.status, '正常');
    });

    test('创建偏高的血压记录', () {
      final record = BloodPressureRecord(
        userId: 'user_001',
        systolic: 145,
        diastolic: 95,
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      expect(record.userId, 'user_001');
      expect(record.systolic, 145);
      expect(record.diastolic, 95);
      expect(record.isNormal, false);
      expect(record.status, '偏高');
    });

    test('判断血压正常 (收缩压<120 且 舒张压<80)', () {
      final record = BloodPressureRecord(
        userId: 'user_001',
        systolic: 119,
        diastolic: 79,
        createdAt: DateTime.now(),
      );
      expect(record.isNormal, true);
    });

    test('判断血压偏高 (收缩压>=140)', () {
      final record = BloodPressureRecord(
        userId: 'user_001',
        systolic: 140,
        diastolic: 75,
        createdAt: DateTime.now(),
      );
      expect(record.isNormal, false);
      expect(record.status, '偏高');
    });

    test('判断血压偏高 (舒张压>=90)', () {
      final record = BloodPressureRecord(
        userId: 'user_001',
        systolic: 115,
        diastolic: 90,
        createdAt: DateTime.now(),
      );
      expect(record.isNormal, false);
      expect(record.status, '偏高');
    });

    test('测试正常高值 (收缩压 120-139)', () {
      final record = BloodPressureRecord(
        userId: 'user_001',
        systolic: 130,
        diastolic: 75,
        createdAt: DateTime.now(),
      );
      expect(record.isNormal, false);
      expect(record.status, '正常高值');
    });

    test('测试正常高值 (舒张压 80-89)', () {
      final record = BloodPressureRecord(
        userId: 'user_001',
        systolic: 115,
        diastolic: 85,
        createdAt: DateTime.now(),
      );
      expect(record.isNormal, false);
      expect(record.status, '正常高值');
    });

    test('displayText 格式化测试', () {
      final record = BloodPressureRecord(
        userId: 'user_001',
        systolic: 120,
        diastolic: 80,
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );
      final display = record.displayText();
      expect(display.contains('🩺'), true);
      expect(display.contains('120/80'), true);
      expect(display.contains('2024-01-15'), true);
      expect(display.contains('10:30'), true);
    });

    test('shortDisplay 简化显示测试', () {
      final record = BloodPressureRecord(
        userId: 'user_001',
        systolic: 120,
        diastolic: 80,
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );
      final short = record.shortDisplay;
      expect(short.contains('120/80'), true);
      expect(short.contains('01/15'), true);
    });

    test('copyWith 方法测试', () {
      final original = BloodPressureRecord(
        userId: 'user_001',
        systolic: 120,
        diastolic: 80,
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      final modified = original.copyWith(
        systolic: 130,
        diastolic: 85,
      );

      expect(original.systolic, 120);
      expect(original.diastolic, 80);
      expect(modified.systolic, 130);
      expect(modified.diastolic, 85);
      expect(modified.userId, original.userId);
      expect(modified.createdAt, original.createdAt);
    });
  });
}
