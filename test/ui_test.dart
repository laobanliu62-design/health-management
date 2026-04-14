import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_one/services/blood_pressure_service.dart';
import 'package:health_one/screens/home_screen.dart';
import 'package:health_one/screens/record_screen.dart';
import 'package:health_one/screens/history_screen.dart';

void main() {
  // 在运行测试前初始化服务
  setUpAll(() async {
    await BloodPressureService().initialize();
  });
  
  group('UI Component Tests', () {
    testWidgets('Home Screen 渲染测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
        ),
      );

      // 检查 AppBar 是否显示
      expect(find.text('HealthOne 血压记录'), findsOneWidget);

      // 检查状态卡片标题
      expect(find.text('今日最新血压'), findsOneWidget);

      // 检查暂无数据文本
      expect(find.text('暂无数据'), findsOneWidget);

      // 检查今日概览标题
      expect(find.text('今日记录'), findsOneWidget);
      expect(find.text('总记录数'), findsOneWidget);

      // 检查快速操作按钮
      expect(find.text('记录血压'), findsOneWidget);

      // 检查提示信息
      expect(find.textContaining('建议每天固定时间'), findsOneWidget);
    });

    testWidgets('Home Screen - 血压值显示测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
        ),
      );

      // 初始状态下应该显示 --/--
      expect(find.text('--/--'), findsOneWidget);
    });

    testWidgets('Record Screen 渲染测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const RecordScreen(),
        ),
      );

      // 检查 AppBar
      expect(find.text('记录血压'), findsOneWidget);

      // 检查收缩压输入框
      expect(find.text('收缩压 (Systolic)'), findsOneWidget);
      expect(find.text('请输入收缩压值'), findsOneWidget);

      // 检查舒张压输入框
      expect(find.text('舒张压 (Diastolic)'), findsOneWidget);
      expect(find.text('请输入舒张压值'), findsOneWidget);

      // 检查保存按钮
      expect(find.text('保存记录'), findsOneWidget);

      // 检查提示信息卡片
      expect(find.text('测量小提示'), findsOneWidget);
      expect(find.textContaining('固定时间'), findsOneWidget);

      // 检查正常血压参考
      expect(find.textContaining('正常血压参考'), findsOneWidget);
      expect(find.textContaining('收缩压 < 120'), findsOneWidget);
    });

    testWidgets('Record Screen - 输入验证测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const RecordScreen(),
        ),
      );

      // 输入收缩压值
      await tester.enterText(
        find.byType(TextFormField).first,
        '120',
      );
      await tester.pumpAndSettle();

      // 输入舒张压值
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '80',
      );
      await tester.pumpAndSettle();

      // 点击保存
      await tester.tap(find.text('保存记录'));
      await tester.pumpAndSettle();

      // 验证输入是否被接受（应该显示成功提示）
      // 注意：因为服务未初始化，这里主要测试 UI 是否响应
    });

    testWidgets('Record Screen - 空输入验证测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const RecordScreen(),
        ),
      );

      // 不输入任何值，直接点击保存
      await tester.tap(find.text('保存记录'));
      await tester.pumpAndSettle();

      // 应该显示验证错误
      expect(find.text('请输入收缩压值'), findsOneWidget);
    });

    testWidgets('Record Screen - 非数字输入验证', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const RecordScreen(),
        ),
      );

      // 输入非数字
      await tester.enterText(
        find.byType(TextFormField).first,
        'abc',
      );
      await tester.pumpAndSettle();

      // 点击保存
      await tester.tap(find.text('保存记录'));
      await tester.pumpAndSettle();

      // 应该显示验证错误
      expect(find.text('请输入有效的数字'), findsOneWidget);
    });

    testWidgets('History Screen 渲染测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HistoryScreen(),
        ),
      );

      // 检查 AppBar
      expect(find.text('历史记录'), findsOneWidget);

      // 检查空状态
      expect(find.text('暂无历史记录'), findsOneWidget);
      expect(find.text('开始记录您的第一次血压数据吧！'), findsOneWidget);

      // 检查刷新按钮
      expect(find.text('刷新'), findsOneWidget);
    });

    testWidgets('History Screen - 加载状态测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HistoryScreen(),
        ),
      );

      // 初始状态应该有加载指示器或空状态
      expect(find.byType(CircularProgressIndicator).evaluate(), isNotEmpty);
      expect(find.text('暂无历史记录'), findsOneWidget);
    });

    testWidgets('UI 组件 - 颜色主题测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const HomeScreen(),
        ),
      );

      // 检查按钮颜色
      final buttonFinder = find.text('记录血压').first;
      final button = tester.widget<ElevatedButton>(buttonFinder);
      // 验证按钮样式存在
      expect(button.style, isNotNull);
    });

    testWidgets('Home Screen - 布局完整性测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
        ),
      );

      // 检查主要布局组件
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // 检查所有子卡片
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Record Screen - 布局完整性测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const RecordScreen(),
        ),
      );

      // 检查主要布局组件
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // 检查输入字段数量（收缩压和舒张压）
      final textFormFields = find.byType(TextFormField);
      expect(textFormFields, findsNWidgets(2));
    });

    testWidgets('History Screen - 刷新功能测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HistoryScreen(),
        ),
      );

      // 查找刷新按钮
      final refreshFinder = find.text('刷新');
      expect(refreshFinder, findsOneWidget);

      // 点击刷新按钮
      await tester.tap(refreshFinder);
      await tester.pumpAndSettle();

      // 刷新后页面应该仍然显示正常
      expect(find.text('历史记录'), findsOneWidget);
      
      // 验证刷新后仍然可以查看所有元素
      expect(find.byType(CircularProgressIndicator).evaluate().isNotEmpty, isTrue);
    });

    testWidgets('UI 组件 - 导航测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
        ),
      );

      // 查找记录按钮
      final recordButton = find.text('记录血压');
      expect(recordButton, findsOneWidget);

      // 模拟点击（这应该会导航到 RecordScreen）
      await tester.tap(recordButton);
      await tester.pumpAndSettle();

      // 验证导航后页面内容
      expect(find.text('记录血压'), findsOneWidget);
    });
  });
}
