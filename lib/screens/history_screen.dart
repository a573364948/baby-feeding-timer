import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/feeding_record.dart';
import '../services/database_service.dart';
import '../services/share_service.dart';

/// 历史记录界面
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _dbService = DatabaseService();
  final ShareService _shareService = ShareService();
  List<FeedingRecord> _records = [];
  DateTime _selectedDate = DateTime.now();
  int _todayTotal = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final records = await _dbService.getFeedingRecordsByDate(_selectedDate);
      final total = await _dbService.getTodayTotalAmount();
      
      setState(() {
        _records = records;
        _todayTotal = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '小熊猫嗷嗷叫记录',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareStats,
            tooltip: '分享统计信息',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: '选择日期',
          ),
        ],
      ),
      body: Column(
        children: [
          // 日期和统计信息
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Column(
              children: [
                Text(
                  DateFormat('yyyy年MM月dd日').format(_selectedDate),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (_isToday())
                  Text(
                    '今日小熊猫总进食量: ${_todayTotal}ml 🐼',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    '当日嗷嗷叫记录: ${_records.length} 次',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          
          // 记录列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.no_meals,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '当日小熊猫还没有嗷嗷叫哦 🐼',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _records.length,
                        itemBuilder: (context, index) {
                          final record = _records[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: const Icon(
                                  Icons.pets,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                DateFormat('HH:mm').format(record.startTime),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (record.amountPrepared != null || record.amountConsumed != null)
                                    Text(
                                      '${record.amountPrepared != null ? "准备了${record.amountPrepared}ml竹子" : ""}'
                                      '${record.amountPrepared != null && record.amountConsumed != null ? " / " : ""}'
                                      '${record.amountConsumed != null ? "小熊猫吃了${record.amountConsumed}ml" : ""}',
                                    ),
                                  if (record.notes != null && record.notes!.isNotEmpty)
                                    Text(
                                      '备注: ${record.notes}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('MM/dd').format(record.startTime),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.share, size: 16),
                                    onPressed: () => _shareRecord(record),
                                    tooltip: '分享此记录',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      // 添加浮动分享按钮
      floatingActionButton: _records.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _shareStats,
              icon: const Icon(Icons.share),
              label: const Text('分享统计'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  /// 选择日期
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData();
    }
  }

  /// 判断是否为今天
  bool _isToday() {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
           _selectedDate.month == now.month &&
           _selectedDate.day == now.day;
  }

  /// 分享统计信息
  Future<void> _shareStats() async {
    if (_records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无数据可分享')),
      );
      return;
    }

    try {
      // 计算当日总量
      int dailyTotal = 0;
      for (var record in _records) {
        if (record.amountConsumed != null) {
          dailyTotal += record.amountConsumed!;
        }
      }

      await _shareService.shareDailyStats(
        date: _selectedDate,
        records: _records,
        totalAmount: dailyTotal,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: $e')),
        );
      }
    }
  }

  /// 分享单条记录
  Future<void> _shareRecord(FeedingRecord record) async {
    try {
      await _shareService.shareRecord(record);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: $e')),
        );
      }
    }
  }
}
