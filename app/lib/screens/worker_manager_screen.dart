import 'package:flutter/material.dart';

class WorkerManagerScreen extends StatelessWidget {
  const WorkerManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Worker 管理'),
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 统计卡片
            _buildStatsRow(),
            
            const SizedBox(height: 24),
            
            // Worker 列表
            const Text(
              '🤖 Worker 列表',
              style: TextStyle(
                color: Color(0xFF00D9FF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView(
                children: const [
                  _WorkerCard(
                    id: 'WD-001',
                    name: 'Flutter Developer',
                    workerId: 'flutter-dev',
                    status: 'active',
                    skills: ['Flutter', 'Dart', 'Hive', 'Material Design'],
                    completedTasks: 7,
                    totalTasks: 7,
                    workspace: '/root/hiclaw-fs/shared/projects/health-management/app',
                    roomUrl: 'https://matrix.to/#/!azbxnR5xMubLraL9IV:matrix-local.hiclaw.io:18080',
                  ),
                  SizedBox(height: 16),
                  _WorkerCard(
                    id: 'WD-002',
                    name: 'Data Engineer',
                    workerId: 'data-engineer',
                    status: 'active',
                    skills: ['SQL', 'Python', 'Data Pipeline', 'Database'],
                    completedTasks: 0,
                    totalTasks: 3,
                    workspace: '/root/hiclaw-fs/shared/projects/health-management/data',
                    roomUrl: 'https://matrix.to/#/!1ULwz1r7wy5MRiOJdT:matrix-local.hiclaw.io:18080',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16213E), Color(0xFF0F3460)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('2', '总 Worker', Icons.business),
          const VerticalDivider(width: 30, color: Color(0xFF00D9FF)),
          _buildStatItem('2', '活跃中', Icons.accessibility),
          const VerticalDivider(width: 30, color: Color(0xFF00D9FF)),
          _buildStatItem('7', '完成任务', Icons.check_circle),
          const VerticalDivider(width: 30, color: Color(0xFF00D9FF)),
          _buildStatItem('10', '总任务', Icons.list_alt),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00D9FF), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00D9FF),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _WorkerCard extends StatelessWidget {
  final String id;
  final String name;
  final String workerId;
  final String status;
  final List<String> skills;
  final int completedTasks;
  final int totalTasks;
  final String workspace;
  final String roomUrl;

  const _WorkerCard({
    required this.id,
    required this.name,
    required this.workerId,
    required this.status,
    required this.skills,
    required this.completedTasks,
    required this.totalTasks,
    required this.workspace,
    required this.roomUrl,
  });

  @override
  Widget build(BuildContext context) {
    final progress = completedTasks / totalTasks * 100;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0F3460)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF00D9FF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: $id • $workerId',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D9FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00D9FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '活跃',
                      style: TextStyle(
                        color: Color(0xFF00D9FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // 技能
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: skills
                  .map((skill) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D9FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          skill,
                          style: TextStyle(
                            color: const Color(0xFF00D9FF),
                            fontSize: 11,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
          
          // 进度
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '进度',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              Text(
                '$completedTasks/$totalTasks = ${progress.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Color(0xFF00D9FF),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: const Color(0xFF0F3460),
              valueColor: const AlwaysStoppedAnimation<Color>(0xFF00D9FF),
              minHeight: 6,
            ),
          ),
          
          // 工作区
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    workspace,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // 操作按钮
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: 打开 Matrix 房间
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('打开 Worker 房间')),
                    );
                  },
                  icon: const Icon(Icons.chat, size: 16),
                  label: const Text('进入房间', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00D9FF),
                    side: const BorderSide(color: Color(0xFF00D9FF)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
