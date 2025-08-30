import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/review_service.dart';
import '../widgets/progress_bar.dart';
import '../services/study_service.dart';
// 如果有调试面板，取消下一行注释
// import '../widgets/dev_time_test_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 触发Provider刷新，确保进度条数据最新
    // ignore: unused_local_variable
    final studyService = Provider.of<StudyService>(context, listen: false);
    // final reviewService = Provider.of<ReviewService>(context, listen: false);
    // 通知监听者刷新（如果Service有刷新方法可调用）
    // studyService.refresh();
    // reviewService.refresh();
    setState(() {});
  }

  // 实现“学习规划”功能：允许用户设置每日复习目标数量，并持久化到 ReviewService
  void _showPlanDialog(BuildContext context) {
    final reviewService = Provider.of<ReviewService>(context, listen: false);
    final controller = TextEditingController(
      text: reviewService.dailyTargetCount.toString(),
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
                int newCount = int.tryParse(controller.text) ??
                    reviewService.dailyTargetCount;
                reviewService.updateDailyTargetCount(newCount);
                Navigator.of(context).pop();
                setState(() {}); // 触发刷新
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
    final reviewService = Provider.of<ReviewService>(context);
    // 进度统计逻辑修正：
    // 进度 = 总复习池数量 / 数据库中中药总数
    // 数据库中中药总数（直接从 StudyService 获取）
    final int totalHerbCount = studyService.totalCount;
    // 总复习池数量
    final int reviewedCount = reviewService.allReviewedIds.length;
    // 进度百分比 = 总复习池数量 / 数据库中中药总数
    final double percent =
        totalHerbCount == 0 ? 0.0 : reviewedCount / totalHerbCount;
    final String percentText = (percent * 100).toStringAsFixed(1);
    final int todayTaskCount = studyService.todayTasks.length;

    return Scaffold(
      appBar: AppBar(title: const Text('中药学习')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            // mastered: 总复习池数量，total: 数据库中中药总数
            ProgressBar(
              mastered: reviewedCount,
              total: totalHerbCount,
            ),
            const SizedBox(height: 32),
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
                                  // 全部掌握或今日任务已完成才显示“恭喜你..."
                                  ? const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '今日任务',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
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
                                        // 显示今日学习池的中药数量
                                        Text(
                                          '剩余 ${studyService.todayTasks.length} 个中药待学习',
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
                                  content:
                                      const Text('此操作将清空所有本地学习和复习数据，无法恢复。'),
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
                                final reviewService =
                                    Provider.of<ReviewService>(context,
                                        listen: false);
                                final studyService = Provider.of<StudyService>(
                                    context,
                                    listen: false);
                                final mounted = context.mounted;
                                if (!mounted) return;
                                await reviewService.clearAllRecords();
                                await studyService.clearRecords();
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('一切重新开始')),
                                );
                              }
                            },
                            child: const Text('重置进度'),
                          ),
                        ],
                      ),
                    ),
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
