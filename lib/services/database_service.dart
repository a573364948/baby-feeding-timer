import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feeding_record.dart';

/// 数据库服务类 (使用SharedPreferences实现，兼容Web)
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  SharedPreferences? _prefs;
  static const String _recordsKey = 'feeding_records';
  int _nextId = 1;

  /// 初始化存储
  Future<void> _init() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      // 初始化下一个ID
      final records = await getAllFeedingRecords();
      if (records.isNotEmpty) {
        _nextId = records.map((r) => r.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      }
    }
  }

  /// 插入喂奶记录
  Future<int> insertFeedingRecord(FeedingRecord record) async {
    await _init();

    final records = await getAllFeedingRecords();
    final newRecord = record.copyWith(id: _nextId);
    records.add(newRecord);

    // 按时间倒序排序
    records.sort((a, b) => b.startTime.compareTo(a.startTime));

    await _saveRecords(records);
    return _nextId++;
  }

  /// 获取所有喂奶记录
  Future<List<FeedingRecord>> getAllFeedingRecords() async {
    await _init();

    final recordsJson = _prefs!.getString(_recordsKey);
    if (recordsJson == null) return [];

    final List<dynamic> recordsList = json.decode(recordsJson);
    return recordsList.map((json) => FeedingRecord.fromMap(json)).toList();
  }

  /// 获取指定日期的喂奶记录
  Future<List<FeedingRecord>> getFeedingRecordsByDate(DateTime date) async {
    final allRecords = await getAllFeedingRecords();
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return allRecords.where((record) {
      return record.startTime.isAfter(startOfDay.subtract(const Duration(milliseconds: 1))) &&
             record.startTime.isBefore(endOfDay);
    }).toList();
  }

  /// 更新喂奶记录
  Future<int> updateFeedingRecord(FeedingRecord record) async {
    final records = await getAllFeedingRecords();
    final index = records.indexWhere((r) => r.id == record.id);

    if (index != -1) {
      records[index] = record;
      await _saveRecords(records);
      return 1;
    }
    return 0;
  }

  /// 删除喂奶记录
  Future<int> deleteFeedingRecord(int id) async {
    final records = await getAllFeedingRecords();
    final initialLength = records.length;
    records.removeWhere((record) => record.id == id);

    if (records.length < initialLength) {
      await _saveRecords(records);
      return 1;
    }
    return 0;
  }

  /// 获取今日总喂奶量
  Future<int> getTodayTotalAmount() async {
    final today = DateTime.now();
    final records = await getFeedingRecordsByDate(today);

    int total = 0;
    for (var record in records) {
      if (record.amountConsumed != null) {
        total += record.amountConsumed!;
      }
    }
    return total;
  }

  /// 保存记录到SharedPreferences
  Future<void> _saveRecords(List<FeedingRecord> records) async {
    await _init();
    final recordsJson = json.encode(records.map((r) => r.toMap()).toList());
    await _prefs!.setString(_recordsKey, recordsJson);
  }

  /// 清除所有记录
  Future<void> clearAllRecords() async {
    await _init();
    await _prefs!.remove(_recordsKey);
  }
}
