import '../models/herb.dart';
import '../services/herb_service.dart';

class TaskGenerator {
  static Future<List<Herb>> generateDailyTasks({
    required int newCount,
    required int reviewCount,
    String? category,
    List<Herb> unmasteredHerbs = const [],
  }) async {
    // 添加 async 关键字
    final allHerbs = await HerbService().loadHerbs(); // 添加 await

    // 获取未掌握的中药
    final reviewPool = unmasteredHerbs.isNotEmpty
        ? unmasteredHerbs
        : _getWeakHerbs(allHerbs);

    // 随机选择复习项
    reviewPool.shuffle(); // 先打乱顺序
    final reviewTasks = reviewPool.take(reviewCount).toList(); // 然后取指定数量

    // 获取新学习项
    List<Herb> newPool = [];
    if (category != null) {
      newPool = allHerbs.where((h) => h.category == category).toList();
    } else {
      newPool = allHerbs;
    }

    newPool.shuffle(); // 先打乱顺序
    final newTasks = newPool.take(newCount).toList(); // 然后取指定数量

    return [...reviewTasks, ...newTasks];
  }

  static List<Herb> _getWeakHerbs(List<Herb> allHerbs) {
    // 实现基于掌握程度的筛选逻辑
    // 暂时返回空列表（实际开发中替换为真实逻辑）
    return []; // 确保始终返回列表
  }
}
