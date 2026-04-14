import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/blood_pressure_service.dart';
import 'screens/main_tab_screen.dart';
import 'screens/worker_manager_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Hive
  await Hive.initFlutter();
  
  // 初始化血压服务
  final service = BloodPressureService();
  await service.initialize();
  
  runApp(const HealthManagementApp());
}

class HealthManagementApp extends StatelessWidget {
  const HealthManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '健康管理',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const MainTabScreen(),
      routes: {
        '/worker-manager': (context) => const WorkerManagerScreen(),
      },
    );
  }
}
