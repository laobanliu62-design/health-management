import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/blood_pressure_service.dart';
import '../models/blood_pressure_record.dart';
import 'home_screen.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final BloodPressureService _service = BloodPressureService();
  
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  
  bool _isSaving = false;

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final systolic = int.parse(_systolicController.text.trim());
      final diastolic = int.parse(_diastolicController.text.trim());

      // 验证收缩压和舒张压的合理性
      if (systolic <= 0 || diastolic <= 0) {
        _showError('血压值必须是正整数');
        return;
      }

      if (diastolic > systolic) {
        _showError('舒张压不能大于收缩压');
        return;
      }

      if (systolic > 300 || diastolic > 200) {
        _showError('血压值超出合理范围');
        return;
      }

      // 创建记录
      final record = BloodPressureRecord(
        userId: 'user_001', // 临时用户 ID
        systolic: systolic,
        diastolic: diastolic,
        createdAt: DateTime.now(),
      );

      // 保存记录
      await _service.saveRecord(record);

      if (mounted) {
        _showSuccess('记录保存成功！');
        
        // 延迟返回，让用户看到成功提示
        await Future.delayed(const Duration(milliseconds: 1000));
        
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('保存失败：$e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录血压'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 说明卡片
              _buildInfoCard(),
              
              const SizedBox(height: 24),
              
              // 收缩压输入框
              _buildInputField(
                controller: _systolicController,
                label: '收缩压 (Systolic)',
                hint: '请输入收缩压值',
                prefix: Text('mmHg'),
                icon: Icons.trending_up,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入收缩压值';
                  }
                  final double? parsedSystolic = double.tryParse(value.trim());
                  if (parsedSystolic == null) {
                    return '请输入有效的数字';
                  }
                  if (parsedSystolic <= 0 || parsedSystolic > 300) {
                    return '收缩压范围：1-300 mmHg';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 舒张压输入框
              _buildInputField(
                controller: _diastolicController,
                label: '舒张压 (Diastolic)',
                hint: '请输入舒张压值',
                prefix: Text('mmHg'),
                icon: Icons.trending_down,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入舒张压值';
                  }
                  final double? parsedDiastolic = double.tryParse(value.trim());
                  if (parsedDiastolic == null) {
                    return '请输入有效的数字';
                  }
                  if (parsedDiastolic <= 0 || parsedDiastolic > 200) {
                    return '舒张压范围：1-200 mmHg';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // 保存按钮
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _saveRecord,
                      icon: const Icon(Icons.save, size: 24),
                      label: const Text(
                        '保存记录',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
              
              const SizedBox(height: 16),
              
              // 小提示
              _buildTips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '测量小提示',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '建议每天在固定时间测量，保持坐姿休息 5 分钟后再测，结果更准确。',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Widget prefix,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        // 只允许输入数字
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.isEmpty) {
            return newValue;
          }
          final validChars = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
          return newValue.copyWith(text: validChars);
        }),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: 'mmHg ',
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                '正常血压参考',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '✅ 正常：收缩压 < 120 mmHg 且 舒张压 < 80 mmHg\n'
            '⚠️ 正常高值：收缩压 120-139 或 舒张压 80-89 mmHg\n'
            '🔴 偏高：收缩压 ≥ 140 或 舒张压 ≥ 90 mmHg',
            style: TextStyle(fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}
