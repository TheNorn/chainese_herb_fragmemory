import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/herb.dart';

/// 加载 assets/data/herbs.json 并转为 Map<int, Herb>
Future<Map<int, Herb>> loadAllHerbs() async {
  final jsonStr = await rootBundle.loadString('assets/data/herbs.json');
  final List<dynamic> list = json.decode(jsonStr);
  // 只保留有 id 字段的条目，避免崩溃
  return {
    for (var item in list)
      if (item is Map && item['id'] != null)
        item['id'] as int: Herb.fromJson(Map<String, dynamic>.from(item))
  };
}
