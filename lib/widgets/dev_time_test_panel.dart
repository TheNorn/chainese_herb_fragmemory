import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/study_service.dart';

/// 开发测试面板，用于模拟不同的学习时间和复习任务
/// 仅在 debug 模式下显示

class DevTimeTestPanel extends StatelessWidget {
  const DevTimeTestPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final studyService = Provider.of<StudyService>(context, listen: false);

    return Card(
      color: Colors.orange[50],
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '【开发测试面板】',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // 模拟第一个已学中药为1天前
                if (studyService.records.isNotEmpty) {
                  studyService.records[0].lastStudied = DateTime.now().subtract(
                    const Duration(days: 1),
                  );
                  studyService.records[0].mastered = false;
                  studyService.init(); // 重新生成复习池
                }
              },
              child: const Text('模拟1天前学习（触发1日复习）'),
            ),
            ElevatedButton(
              onPressed: () {
                // 模拟第一个已学中药为2天前
                if (studyService.records.isNotEmpty) {
                  studyService.records[0].lastStudied = DateTime.now().subtract(
                    const Duration(days: 2),
                  );
                  studyService.records[0].mastered = false;
                  studyService.init();
                }
              },
              child: const Text('模拟2天前学习（触发2日复习）'),
            ),
            ElevatedButton(
              onPressed: () {
                // 模拟所有已学中药都为4天前
                for (var r in studyService.records) {
                  r.lastStudied = DateTime.now().subtract(
                    const Duration(days: 4),
                  );
                  r.mastered = false;
                }
                studyService.init();
              },
              child: const Text('模拟全部4天前学习（触发4日复习）'),
            ),
            ElevatedButton(
              onPressed: () {
                // 恢复所有记录为今天
                for (var r in studyService.records) {
                  r.lastStudied = DateTime.now();
                }
                studyService.init();
              },
              child: const Text('恢复为今日学习'),
            ),
          ],
        ),
      ),
    );
  }
}
