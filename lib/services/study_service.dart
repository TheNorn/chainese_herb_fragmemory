import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/herb.dart';
import '../models/study_record.dart';
import 'herb_service.dart';
//import '../models/review_schedule.dart';
import 'dart:math';
import 'dart:convert';
import '../utils/ebbinghaus.dart';

class StudyService extends ChangeNotifier {
  List<Herb> _allHerbs = [];
  final List<StudyRecord> _records = [];
  List<Herb> _todayTasks = [];
  List<Herb> _todayReviews = [];
  int dailyTaskCount = 10;
  String? categoryFilter;
  DateTime? _todayDate; // 记录今日任务生成日期

  // 第二次修改：新增复习池持久化
  List<int> _reviewPool = [];

  StudyService() {
    init();
  }

  /// 初始化，加载本地数据
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    dailyTaskCount = prefs.getInt('dailyTaskCount') ?? 10;
    await _loadRecords(); // 加载本地学习记录
    _allHerbs = await HerbService().loadHerbs();
    await _loadTodayTasks(); // 第一次修改：加载今日任务池
    // 第二次修改：加载复习池
    await _loadReviewPool();
    if (_todayTasks.isEmpty) {
      _generateTodayTasksIfNeeded(force: true);
      await _saveTodayTasks(); // 第一次修改：首次生成后保存
    }
    _generateTodayReviews();
    notifyListeners();
  }

  /// 保存学习记录到本地
  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = _records.map((r) => r.toJson()).toList();
    await prefs.setString('study_records', jsonEncode(recordsJson));
  }

  /// 加载学习记录
  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsStr = prefs.getString('study_records');
    _records.clear();
    if (recordsStr != null) {
      final List recordsJson = jsonDecode(recordsStr);
      _records.addAll(recordsJson.map((item) => StudyRecord.fromJson(item)));
    }
  }

  /// 第一次修改：保存今日任务池到本地
  Future<void> _saveTodayTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = _todayTasks.map((h) => h.id).toList();
    await prefs.setString(
      'today_tasks',
      jsonEncode({'date': _todayDate?.toIso8601String(), 'ids': ids}),
    );
  }

  /// 第一次修改：加载今日任务池
  Future<void> _loadTodayTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('today_tasks');
    if (str != null) {
      final map = jsonDecode(str);
      final dateStr = map['date'] as String?;
      final ids = (map['ids'] as List).cast<int>();
      if (dateStr != null) {
        final date = DateTime.parse(dateStr);
        final now = DateTime.now();
        // 只在同一天恢复
        if (date.year == now.year &&
            date.month == now.month &&
            date.day == now.day) {
          _todayDate = date;
          _todayTasks = ids
              .map(
                (id) => _allHerbs.firstWhere(
                  (h) => h.id == id,
                  orElse: () => Herb(
                    id: -1,
                    name: '未知中药',
                    category: '',
                    effect: '',
                    taste: '',
                    image: '',
                  ),
                ),
              )
              .whereType<Herb>()
              .toList();
        }
      }
    }
  }

  /// 第二次修改：保存复习池到本地
  Future<void> _saveReviewPool() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'review_pool',
      _reviewPool.map((id) => id.toString()).toList(),
    );
  }

  /// 第二次修改：加载复习池
  Future<void> _loadReviewPool() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('review_pool');
    if (ids != null) {
      _reviewPool = ids.map(int.parse).toList();
    }
  }

  /// 第二次修改：将herb加入复习池
  Future<void> addToReviewPool(int herbId) async {
    if (!_reviewPool.contains(herbId)) {
      _reviewPool.add(herbId);
      await _saveReviewPool();
    }
  }

  /// 第二次修改：移除复习池
  Future<void> removeFromReviewPool(int herbId) async {
    _reviewPool.remove(herbId);
    await _saveReviewPool();
  }

  /// 清空学习记录
  Future<void> clearRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('study_records');
    await prefs.remove('today_tasks'); // 第一次修改：清空今日任务池
    // 第二次修改：清空复习池
    await prefs.remove('review_pool');
    _records.clear();
    _todayTasks.clear(); // 第一次修改：清空内存中的今日任务池
    // 第二次修改：清空内存中的复习池
    _reviewPool.clear();
    _generateTodayTasksIfNeeded(force: true);
    _generateTodayReviews();
    notifyListeners();
  }

  // 只在每天首次或计划变更时生成今日任务池
  void _generateTodayTasksIfNeeded({bool force = false}) {
    final now = DateTime.now();
    if (force || _todayTasks.isEmpty || !_isSameDay(_todayDate, now)) {
      _todayDate = DateTime(now.year, now.month, now.day);
      // 生成今日任务池
      List<Herb> filteredHerbs = _allHerbs;
      if (categoryFilter != null && categoryFilter!.isNotEmpty) {
        filteredHerbs = _allHerbs
            .where((herb) => herb.category == categoryFilter)
            .toList();
      }
      final masteredIds = _records
          .where((r) => r.mastered)
          .map((r) => r.herbId)
          .toSet();
      filteredHerbs = filteredHerbs
          .where((herb) => !masteredIds.contains(herb.id))
          .toList();
      filteredHerbs.shuffle(Random());
      _todayTasks = filteredHerbs.take(dailyTaskCount).toList();
      _saveTodayTasks(); // 第一次修改：生成后立即保存
    }
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 第二次修改：生成今日复习池，结合艾宾浩斯算法和复习池持久化
  void _generateTodayReviews() {
    final now = DateTime.now();
    _todayReviews = _reviewPool
        .map((herbId) {
          final record = _records.firstWhere(
            (r) => r.herbId == herbId,
            orElse: () => StudyRecord(
              herbId: herbId,
              mastered: false,
              reviewCount: 0,
              lastStudied: DateTime(2000), // 或其它合适的默认值
            ),
          );
          // if (record == null || record.mastered) return null;
          // 计算下次复习日期
          final nextReviewDate = Ebbinghaus.getNextReviewDate(
            record.reviewCount - 1,
            record.lastStudied,
          );
          // 如果今天 >= 下次复习日期，则需要复习
          // ...existing code...
          if (!now.isBefore(
            DateTime(
              nextReviewDate.year,
              nextReviewDate.month,
              nextReviewDate.day,
            ),
          )) {
            return _allHerbs.firstWhere(
              (h) => h.id == herbId,
              orElse: () => Herb(
                id: -1,
                name: '未知中药',
                category: '',
                effect: '',
                taste: '',
                image: '',
              ),
            );
          }
          // ...existing code...
        })
        .whereType<Herb>()
        .toList();
  }

  List<Herb> get todayTasks => _todayTasks;
  List<Herb> get todayReviews => _todayReviews;
  List<Herb> get allHerbs => _allHerbs;

  int get masteredCount => _records.where((r) => r.mastered).length;
  int get totalCount => _allHerbs.length;

  /// 修改学习记录并保存
  void updateRecord(int herbId, {bool mastered = false}) async {
    final recordIndex = _records.indexWhere(
      (record) => record.herbId == herbId,
    );

    if (recordIndex != -1) {
      _records[recordIndex].mastered = mastered;
      _records[recordIndex].lastStudied = DateTime.now();
      // 第二次修改：复习次数+1
      _records[recordIndex].reviewCount =
          (_records[recordIndex].reviewCount) + 1;
    } else {
      _records.add(
        StudyRecord(
          herbId: herbId,
          lastStudied: DateTime.now(),
          mastered: mastered,
          // 第二次修改：初始化复习次数
          reviewCount: 1,
        ),
      );
    }

    // 第二次修改：如果彻底掌握，移出复习池
    if (mastered) {
      await removeFromReviewPool(herbId);
    }

    _generateTodayReviews();
    await _saveRecords(); // 保存
    notifyListeners();
  }

  /// 标记为已掌握并保存
  void markAsMastered(int herbId) async {
    final recordIndex = _records.indexWhere(
      (record) => record.herbId == herbId,
    );

    if (recordIndex != -1) {
      _records[recordIndex].mastered = true;
      _records[recordIndex].lastStudied = DateTime.now();
    } else {
      _records.add(
        StudyRecord(
          herbId: herbId,
          lastStudied: DateTime.now(),
          mastered: true,
          reviewCount: 1, // 第二次修改：初始化复习次数
        ),
      );
    }

    _todayTasks.removeWhere((herb) => herb.id == herbId);
    await _saveTodayTasks(); // 第一次修改：每次移除后保存今日任务池
    // 第二次修改：加入复习池
    await addToReviewPool(herbId);
    _generateTodayReviews();
    await _saveRecords(); // 保存
    notifyListeners();
  }

  /// 增加“再学一点”功能：向今日任务池添加新的未掌握中药
  void addToTodayTasks(List<Herb> herbs) {
    final existingIds = _todayTasks.map((h) => h.id).toSet();
    final toAdd = herbs.where((h) => !existingIds.contains(h.id)).toList();
    _todayTasks.addAll(toAdd);
    _saveTodayTasks(); // 第一次修改：添加后保存
    notifyListeners();
  }

  /// 修改每日学习任务数量，并保存到本地
  Future<void> updateDailyTaskCount(int count) async {
    dailyTaskCount = count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyTaskCount', count);
    _generateTodayTasksIfNeeded(force: true); // 重新生成今日任务池
    _generateTodayReviews();
    notifyListeners();
  }

  List<StudyRecord> get records => _records;
}
