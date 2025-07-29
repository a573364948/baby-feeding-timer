import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/feeding_record.dart';

/// 分享服务类
class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  /// 分享当天统计信息
  Future<void> shareDailyStats({
    required DateTime date,
    required List<FeedingRecord> records,
    required int totalAmount,
  }) async {
    final shareText = _generateDailyStatsText(
      date: date,
      records: records,
      totalAmount: totalAmount,
    );

    try {
      await Share.share(
        shareText,
        subject: '小熊猫嗷嗷叫统计 🐼',
      );
    } catch (e) {
      // 分享失败时的处理
      print('分享失败: $e');
    }
  }

  /// 生成每日统计文本
  String _generateDailyStatsText({
    required DateTime date,
    required List<FeedingRecord> records,
    required int totalAmount,
  }) {
    final dateStr = DateFormat('yyyy年MM月dd日').format(date);
    final isToday = _isToday(date);
    
    final buffer = StringBuffer();
    
    // 标题
    buffer.writeln('🐼 小熊猫嗷嗷叫统计报告 🐼');
    buffer.writeln('');
    buffer.writeln('📅 日期：$dateStr');
    buffer.writeln('');
    
    if (records.isEmpty) {
      buffer.writeln('😴 小熊猫今天很乖，没有嗷嗷叫哦~');
    } else {
      // 基本统计
      buffer.writeln('📊 统计信息：');
      buffer.writeln('• 嗷嗷叫次数：${records.length} 次');
      if (totalAmount > 0) {
        buffer.writeln('• 总进食量：${totalAmount}ml 竹子');
        buffer.writeln('• 平均每次：${(totalAmount / records.length).toStringAsFixed(1)}ml');
      }
      buffer.writeln('');
      
      // 详细记录
      buffer.writeln('🕐 详细记录：');
      for (int i = 0; i < records.length; i++) {
        final record = records[i];
        final timeStr = DateFormat('HH:mm').format(record.startTime);
        
        buffer.write('${i + 1}. $timeStr - ');
        
        if (record.amountConsumed != null) {
          buffer.write('吃了${record.amountConsumed}ml竹子');
        } else if (record.amountPrepared != null) {
          buffer.write('准备了${record.amountPrepared}ml竹子');
        } else {
          buffer.write('嗷嗷叫了一次');
        }
        
        if (record.notes != null && record.notes!.isNotEmpty) {
          buffer.write(' (${record.notes})');
        }
        
        buffer.writeln('');
      }
      
      buffer.writeln('');
      
      // 时间间隔分析
      if (records.length > 1) {
        buffer.writeln('⏰ 时间间隔分析：');
        final intervals = _calculateIntervals(records);
        if (intervals.isNotEmpty) {
          final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
          final avgHours = (avgInterval / 60).toStringAsFixed(1);
          buffer.writeln('• 平均间隔：${avgHours}小时');
          
          final maxInterval = intervals.reduce((a, b) => a > b ? a : b);
          final maxHours = (maxInterval / 60).toStringAsFixed(1);
          buffer.writeln('• 最长间隔：${maxHours}小时');
          
          final minInterval = intervals.reduce((a, b) => a < b ? a : b);
          final minHours = (minInterval / 60).toStringAsFixed(1);
          buffer.writeln('• 最短间隔：${minHours}小时');
        }
        buffer.writeln('');
      }
    }
    
    // 结尾
    if (isToday) {
      buffer.writeln('💝 小熊猫今天表现很棒！');
    } else {
      buffer.writeln('💝 这是小熊猫的历史记录~');
    }
    buffer.writeln('');
    buffer.writeln('📱 来自：小熊猫嗷嗷叫倒计时应用');
    
    return buffer.toString();
  }

  /// 计算时间间隔（分钟）
  List<int> _calculateIntervals(List<FeedingRecord> records) {
    final intervals = <int>[];
    
    for (int i = 0; i < records.length - 1; i++) {
      final current = records[i].startTime;
      final next = records[i + 1].startTime;
      final interval = current.difference(next).inMinutes.abs();
      intervals.add(interval);
    }
    
    return intervals;
  }

  /// 判断是否为今天
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  /// 分享单条记录
  Future<void> shareRecord(FeedingRecord record) async {
    final timeStr = DateFormat('yyyy年MM月dd日 HH:mm').format(record.startTime);
    
    final buffer = StringBuffer();
    buffer.writeln('🐼 小熊猫嗷嗷叫记录');
    buffer.writeln('');
    buffer.writeln('🕐 时间：$timeStr');
    
    if (record.amountPrepared != null) {
      buffer.writeln('🎋 准备竹子：${record.amountPrepared}ml');
    }
    
    if (record.amountConsumed != null) {
      buffer.writeln('🍽️ 进食量：${record.amountConsumed}ml');
    }
    
    if (record.notes != null && record.notes!.isNotEmpty) {
      buffer.writeln('📝 备注：${record.notes}');
    }
    
    buffer.writeln('');
    buffer.writeln('📱 来自：小熊猫嗷嗷叫倒计时应用');
    
    try {
      await Share.share(
        buffer.toString(),
        subject: '小熊猫嗷嗷叫记录 🐼',
      );
    } catch (e) {
      print('分享失败: $e');
    }
  }
}
