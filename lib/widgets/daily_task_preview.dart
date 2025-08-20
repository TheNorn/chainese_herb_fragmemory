import 'package:flutter/material.dart';
import 'package:chinese_herb_framery/models/herb.dart';

class DailyTaskPreview extends StatelessWidget {
  final List<Herb> tasks;

  const DailyTaskPreview({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text('今日没有学习任务'));
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final herb = tasks[index];
        return ListTile(
          leading: const Icon(Icons.medical_services, color: Colors.green),
          title: Text(herb.name),
          subtitle: Text('分类: ${herb.category}'),
          trailing: Text('${index + 1}/${tasks.length}'),
        );
      },
    );
  }
}
