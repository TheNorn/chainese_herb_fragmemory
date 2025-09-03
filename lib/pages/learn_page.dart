import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/herb.dart';
import '../services/study_service.dart';
import '../services/review_service.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  // 当前学习卡片索引
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 只依赖 StudyService，所有今日学习池相关状态由 service 统一管理
    final studyService = Provider.of<StudyService>(context);
    final todayTasks = studyService.todayTasks;

    // 今日任务池为空时，显示“已完成”界面

    if (todayTasks.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('中药学习')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('今日任务已完成或暂无任务'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // 直接调用 StudyService 的“再学一点”功能，自动补充未掌握中药
                  final allHerbs = studyService.allHerbs;
                  final existingIds = todayTasks.map((h) => h.id).toSet();
                  final unmastered = allHerbs
                      .where((herb) => !existingIds.contains(herb.id))
                      .toList();
                  unmastered.shuffle(Random());
                  final nextFive = unmastered.take(5).toList();
                  studyService.addToTodayTasks(nextFive);
                  setState(() {
                    _currentIndex = 0;
                  });
                },
                child: const Text('再学一点'),
              ),
            ],
          ),
        ),
      );
    }

    // 防止索引越界
    if (_currentIndex >= todayTasks.length) {
      _currentIndex = 0;
    }

    final Herb herb = todayTasks[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('中药学习'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentIndex > 0) {
                setState(() => _currentIndex--);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: SizedBox(
            width: double.infinity,
            height: 400,
            child: Padding(
              // UI调整：整体内容与卡片边缘留出距离
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ...existing code...
                  Center(
                    child: Column(
                      children: [
                        Text(
                          herb.name,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // 新增：大问号
                        const SizedBox(height: 16),
                        const Text(
                          '?',
                          style: TextStyle(
                            fontSize: 128, // 32 * 4 = 128
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ...existing code...
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // UI调整：按钮增大并与边缘留出距离
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              _goToDetail(context, herb, true);
                            },
                            child: const Text(
                              '我知道',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24), // 按钮间距
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              _goToDetail(context, herb, false);
                            },
                            child: const Text(
                              '不知道',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 只在“我知道”+“记住了”时移除当前中药，其他情况保留
  void _goToDetail(BuildContext context, Herb herb, bool know) async {
    final remembered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _LearnDetailPage(herb: herb, know: know),
      ),
    );

    final studyService = Provider.of<StudyService>(context, listen: false);
    final reviewService = Provider.of<ReviewService>(context, listen: false);
    if (know && remembered == true) {
      studyService.markAsMastered(herb.id);
      await reviewService.addToAllReviewed(herb.id); // 同步进入复习池
      setState(() {
        if (_currentIndex >= studyService.todayTasks.length &&
            studyService.todayTasks.isNotEmpty) {
          _currentIndex = studyService.todayTasks.length - 1;
        }
      });
    } else {
      setState(() {
        if (studyService.todayTasks.isNotEmpty) {
          _currentIndex = (_currentIndex + 1) % studyService.todayTasks.length;
        }
      });
    }
  }
}

class _LearnDetailPage extends StatelessWidget {
  final Herb herb;
  final bool know;

  const _LearnDetailPage({required this.herb, required this.know});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('中药详情')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              herb.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('功效: ${herb.effect}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('性味归经: ${herb.taste}', style: const TextStyle(fontSize: 18)),
            const Spacer(),
            Padding(
              // UI调整：按钮区与卡片边缘留出距离
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true); // 记住了
                        },
                        child: const Text(
                          '记住了',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, false); // 记错了
                        },
                        child: const Text(
                          '记错了',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 你需要在 StudyService 中添加如下方法和 getter：
// List<Herb> get allHerbs => _allHerbs;
// void addToTodayTasks(List<Herb> herbs) {
//   _todayTasks.addAll(herbs);
//   notifyListeners();
// }
