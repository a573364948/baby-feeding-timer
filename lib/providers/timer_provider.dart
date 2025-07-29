import 'dart:async';
import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/database_service.dart';
import '../models/feeding_record.dart';

/// 计时器状态枚举
enum TimerState {
  countdown,    // 倒计时状态
  overtime,     // 超时状态
  stopped,      // 停止状态
}

/// 计时器状态管理
class TimerProvider with ChangeNotifier {
  final PreferencesService _prefsService = PreferencesService();
  final DatabaseService _dbService = DatabaseService();

  Timer? _timer;
  TimerState _state = TimerState.stopped;
  Duration _remainingTime = Duration.zero;
  Duration _defaultDuration = const Duration(hours: 3);
  DateTime? _startTime;

  // Getters
  TimerState get state => _state;
  Duration get remainingTime => _remainingTime;
  Duration get defaultDuration => _defaultDuration;
  DateTime? get startTime => _startTime;
  bool get isRunning => _timer != null && _timer!.isActive;

  /// 格式化时间显示
  String get formattedTime {
    if (_state == TimerState.countdown) {
      final hours = _remainingTime.inHours;
      final minutes = _remainingTime.inMinutes % 60;
      final seconds = _remainingTime.inSeconds % 60;
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else if (_state == TimerState.overtime) {
      final elapsed = DateTime.now().difference(_startTime!.add(_defaultDuration));
      final hours = elapsed.inHours;
      final minutes = elapsed.inMinutes % 60;
      final seconds = elapsed.inSeconds % 60;
      return '已过 ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '00:00:00';
  }

  /// 初始化
  Future<void> init() async {
    await _prefsService.init();
    await _loadSettings();
    await _checkLastFeedingTime();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    final minutes = _prefsService.getDefaultCountdownMinutes();
    _defaultDuration = Duration(minutes: minutes);
    notifyListeners();
  }

  /// 检查上次喂奶时间
  Future<void> _checkLastFeedingTime() async {
    final lastTime = _prefsService.getLastFeedingTime();
    if (lastTime != null) {
      final elapsed = DateTime.now().difference(lastTime);
      if (elapsed < _defaultDuration) {
        // 还在倒计时期间
        _remainingTime = _defaultDuration - elapsed;
        _startTime = lastTime;
        _state = TimerState.countdown;
        _startTimer();
      } else {
        // 已经超时
        _startTime = lastTime;
        _state = TimerState.overtime;
        _startTimer();
      }
    }
  }

  /// 开始倒计时
  Future<void> startCountdown({int? amountPrepared, int? amountConsumed, String? notes}) async {
    _startTime = DateTime.now();
    _remainingTime = _defaultDuration;
    _state = TimerState.countdown;

    // 保存喂奶记录
    final record = FeedingRecord(
      startTime: _startTime!,
      amountPrepared: amountPrepared,
      amountConsumed: amountConsumed,
      notes: notes,
    );
    await _dbService.insertFeedingRecord(record);

    // 保存到偏好设置
    await _prefsService.setLastFeedingTime(_startTime!);

    _startTimer();
    notifyListeners();
  }

  /// 启动计时器
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state == TimerState.countdown) {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        } else {
          _state = TimerState.overtime;
        }
      }
      notifyListeners();
    });
  }

  /// 重置计时器
  Future<void> resetTimer() async {
    _timer?.cancel();
    _state = TimerState.stopped;
    _remainingTime = Duration.zero;
    _startTime = null;
    notifyListeners();
  }

  /// 设置默认时长
  Future<void> setDefaultDuration(Duration duration) async {
    _defaultDuration = duration;
    await _prefsService.setDefaultCountdownMinutes(duration.inMinutes);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
