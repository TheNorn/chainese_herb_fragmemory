// ...existing code...
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chinese_herb_framery/services/study_service.dart'; // Update the path if needed

@override
Widget build(BuildContext context) {
  final studyService = Provider.of<StudyService>(context);

  return Scaffold(
    appBar: AppBar(title: const Text('设置')),
    body: Column(
      children: [
        ListTile(
          title: const Text('每日学习数量'),
          trailing: DropdownButton<int>(
            value: studyService.dailyTaskCount,
            items: [5, 10, 15, 20]
                .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                studyService.dailyTaskCount = v;
                studyService.init();
              }
            },
          ),
        ),
        // 分类筛选等
      ],
    ),
  );
}
