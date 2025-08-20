import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:chinese_herb_framery/models/herb.dart';
import 'package:chinese_herb_framery/services/study_service.dart';
import 'package:chinese_herb_framery/widgets/herb_card.dart';

class DailyTaskPage extends StatefulWidget {
  const DailyTaskPage({super.key});

  @override
  State<DailyTaskPage> createState() => _DailyTaskPageState();
}

class _DailyTaskPageState extends State<DailyTaskPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final studyService = Provider.of<StudyService>(context);
    final dailyTasks = studyService.todayTasks;

    if (dailyTasks.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('今日学习')),
        body: const Center(child: Text('恭喜！今日没有学习任务')),
      );
    }

    final currentHerb = dailyTasks[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('今日学习')),
      body: Column(
        children: [
          Expanded(child: HerbCard(herb: currentHerb)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0)
                  ElevatedButton(
                    onPressed: () => setState(() => _currentIndex--),
                    child: const Text('上一个'),
                  ),
                const Spacer(),
                if (_currentIndex < dailyTasks.length - 1)
                  ElevatedButton(
                    onPressed: () => setState(() => _currentIndex++),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      '下一个',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      studyService.markAsMastered(currentHerb.id);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      '完成学习',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
