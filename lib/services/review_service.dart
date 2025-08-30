import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/herb.dart';
import '../utils/ebbinghaus.dart';

/// 复习服务，负责每日复习池的生成、进度管理和持久化
class ReviewService with ChangeNotifier {
  // 每日复习目标数量（可持久化）
  int _dailyTargetCount = 10;
  int get dailyTargetCount => _dailyTargetCount;
  Future<void> updateDailyTargetCount(int count) async {
    _dailyTargetCount = count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyTargetCount', count);
    notifyListeners();
  }

  // 获取所有已掌握的中药id集合
  Set<int> get allReviewedIds => allReviewedHerbs.keys.toSet();

  // 清空所有复习进度
  Future<void> clearAllRecords() async {
    allReviewedHerbs.clear();
    todayReviewIds.clear();
    reviewedToday.clear();
    todayDate = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('allReviewedHerbs');
    await prefs.remove('todayReviewIds');
    await prefs.remove('reviewedToday');
    await prefs.remove('todayDate');
    await prefs.remove('dailyTargetCount');
    notifyListeners();
  }

  // 总复习池（已学习并确认的中药id、入池时间、复习次数）
  // 结构：{herbId: {"added": DateTime, "reviewCount": int}}
  Map<int, Map<String, dynamic>> allReviewedHerbs = {};

  // 今日复习池（今日应复习的中药id）
  List<int> todayReviewIds = [];

  // 今日已掌握的中药id
  Set<int> reviewedToday = {};

  // 复习池生成日期
  DateTime? todayDate;

  /// 初始化，加载持久化数据
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    // 加载总复习池
    final allHerbsStr = prefs.getString('allReviewedHerbs');
    if (allHerbsStr != null) {
      final map = json.decode(allHerbsStr) as Map<String, dynamic>;
      allReviewedHerbs = map.map((k, v) {
        final value = v as Map<String, dynamic>;
        return MapEntry(
          int.parse(k),
          {
            "added": DateTime.parse(value["added"] as String),
            "reviewCount": value["reviewCount"] ?? 0,
          },
        );
      });
    }
    // 加载今日复习池
    final todayStr = prefs.getString('todayReviewIds');
    if (todayStr != null) {
      todayReviewIds =
          (json.decode(todayStr) as List).map((e) => e as int).toList();
    }
    // 加载今日已掌握
    final reviewedStr = prefs.getString('reviewedToday');
    if (reviewedStr != null) {
      reviewedToday =
          (json.decode(reviewedStr) as List).map((e) => e as int).toSet();
    }
    // 加载复习池生成日期
    final dateStr = prefs.getString('todayDate');
    if (dateStr != null) {
      todayDate = DateTime.tryParse(dateStr);
    }
    // 加载每日复习目标
    _dailyTargetCount = prefs.getInt('dailyTargetCount') ?? 10;
    notifyListeners();
  }

  /// 新增中药到总复习池
  Future<void> addToAllReviewed(int herbId) async {
    allReviewedHerbs[herbId] = {
      "added": DateTime.now(),
      "reviewCount": 0,
    };
    await _saveAllReviewed();
    notifyListeners();
  }

  /// 生成今日复习池（结合艾宾浩斯算法）
  Future<void> generateTodayReviewPool() async {
    final now = DateTime.now();
    todayDate = DateTime(now.year, now.month, now.day);
    todayReviewIds = allReviewedHerbs.entries
        .where((entry) => shouldReviewToday(
              entry.value["added"] as DateTime,
              now,
              entry.value["reviewCount"] ?? 0,
            ))
        .map((entry) => entry.key)
        .toList();
    reviewedToday.clear();
    await _saveTodayReview();
    notifyListeners();
  }

  /// 判断某中药是否应在 today 被复习（艾宾浩斯算法）
  bool shouldReviewToday(DateTime added, DateTime now, int reviewCount) {
    final nextReviewDate = Ebbinghaus.getNextReviewDate(reviewCount, added);
    return !now.isBefore(nextReviewDate);
  }

  /// 获取今日待复习的中药列表
  List<Herb> getTodayReviewList(Map<int, Herb> allHerbs) {
    return todayReviewIds
        .where((id) => !reviewedToday.contains(id))
        .map((id) => allHerbs[id])
        .whereType<Herb>()
        .toList();
  }

  /// 标记中药复习结果
  Future<void> markHerbReviewed(int id, bool mastered) async {
    if (mastered) {
      reviewedToday.add(id);
      // 增加reviewCount
      if (allReviewedHerbs.containsKey(id)) {
        allReviewedHerbs[id]?['reviewCount'] =
            (allReviewedHerbs[id]?['reviewCount'] ?? 0) + 1;
        await _saveAllReviewed();
      }
      await _saveReviewedToday();
      notifyListeners();
    }
    // 未掌握不做处理，卡片会继续出现
  }

  /// 重置今日复习进度
  Future<void> resetTodayReview() async {
    reviewedToday.clear();
    await _saveReviewedToday();
    notifyListeners();
  }

  // --- 持久化方法 ---
  Future<void> _saveAllReviewed() async {
    final prefs = await SharedPreferences.getInstance();
    final map = allReviewedHerbs.map((k, v) => MapEntry(k.toString(), {
          "added": (v["added"] as DateTime).toIso8601String(),
          "reviewCount": v["reviewCount"] ?? 0,
        }));
    await prefs.setString('allReviewedHerbs', json.encode(map));
  }

  Future<void> _saveTodayReview() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('todayReviewIds', json.encode(todayReviewIds));
    await prefs.setString('todayDate', todayDate?.toIso8601String() ?? '');
  }

  Future<void> _saveReviewedToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reviewedToday', json.encode(reviewedToday.toList()));
  }
}
