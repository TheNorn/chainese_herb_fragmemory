import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/herb.dart';

class HerbService {
  Future<List<Herb>> loadHerbs() async {
    // 加载 assets/data/herbs.json 文件
    final String jsonStr = await rootBundle.loadString(
      'assets/data/herbs.json',
    );
    final List<dynamic> jsonList = jsonDecode(jsonStr);

    // 解析为 Herb 列表，过滤掉字段不完整的条目
    return jsonList
        .where(
          (item) =>
              item['id'] != null &&
              item['name'] != null &&
              item['category'] != null &&
              item['effect'] != null &&
              item['taste'] != null &&
              item['image'] != null,
        )
        .map((item) => Herb.fromJson(item))
        .toList();
  }

  Herb? getHerbById(int id, List<Herb> herbs) {
    // 根据 id 查找 Herb
    try {
      return herbs.firstWhere((herb) => herb.id == id);
    } catch (e) {
      return null;
    }
  }
}
