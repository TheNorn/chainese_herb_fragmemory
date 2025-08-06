import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/study_service.dart';
import '../widgets/progress_bar.dart';
// 如果有调试面板，取消下一行注释
// import '../widgets/dev_time_test_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _showPlanDialog(BuildContext context) {
    final studyService = Provider.of<StudyService>(context, listen: false);
    TextEditingController controller = TextEditingController(
      text: studyService.dailyTaskCount.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('学习规划'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '每日计划学习的中药数量'),
            controller: controller,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('保存'),
              onPressed: () {
                int newDailyTaskCount =
                    int.tryParse(controller.text) ??
                    studyService.dailyTaskCount;
                studyService.updateDailyTaskCount(newDailyTaskCount);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final studyService = Provider.of<StudyService>(context);

    final percent = studyService.totalCount == 0
        ? 0.0
        : studyService.masteredCount / studyService.totalCount;
    final percentText = (percent * 100).toStringAsFixed(1);

    final int todayTaskCount = studyService.todayTasks.length;

    return Scaffold(
      appBar: AppBar(title: const Text('中药学习')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 如需全局调试面板，取消下一行注释
            //if (!bool.fromEnvironment('dart.vm.product')) const DevTimeTestPanel(),
            // 百分比
            Align(
              alignment: Alignment.center,
              child: Text(
                '完成度：$percentText%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 总进度条
            ProgressBar(
              mastered: studyService.masteredCount,
              total: studyService.totalCount,
            ),
            const SizedBox(height: 32),

            // 方案一：IntrinsicHeight + stretch + spaceBetween
            // ...省略前面代码...
            Expanded(
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 左侧：今日任务卡片贴左下角
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 2,
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 100),
                              padding: const EdgeInsets.all(16.0),
                              child: todayTaskCount == 0
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '今日任务',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          '恭喜你，今日学习任务已完成！',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '今日任务',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '剩余 $todayTaskCount 个中药待学习',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 右侧：按钮列，学习规划按钮与卡片上缘对齐
                    // ...前略...
                    SizedBox(
                      width: 120,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end, // 让按钮都贴底
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => _showPlanDialog(context),
                            child: Text(todayTaskCount == 0 ? '再学一点' : '学习规划'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFDEDEC),
                              foregroundColor: const Color(0xFF884A39),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('确定重置吗？'),
                                  content: const Text('此操作将清空所有学习进度，无法恢复。'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('不是'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('是的'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await Provider.of<StudyService>(
                                  context,
                                  listen: false,
                                ).clearRecords();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('学习进度已重置')),
                                  );
                                }
                              }
                            },
                            child: const Text('重置进度'),
                          ),
                        ],
                      ),
                    ),
                    // ...后略...
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
