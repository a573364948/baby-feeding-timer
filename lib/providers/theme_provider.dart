import 'dart:async';
import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/preferences_service.dart';

/// 主题状态管理
class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService = ThemeService();
  final PreferencesService _prefsService = PreferencesService();
  
  Timer? _timer;
  ThemeData? _currentTheme;

  /// 获取当前主题
  ThemeData get currentTheme {
    _currentTheme ??= _themeService.getCurrentTheme();
    return _currentTheme!;
  }

  /// 是否为深色主题
  bool get isDarkTheme => _themeService.shouldUseDarkTheme();

  /// 夜间模式是否启用
  bool get isNightModeEnabled => _prefsService.isNightModeEnabled();

  /// 夜间模式类型
  NightModeType get nightModeType => _prefsService.getNightModeType();

  /// 夜间模式状态文本
  String get nightModeStatusText => _themeService.getNightModeStatusText();

  /// 初始化
  Future<void> init() async {
    await _prefsService.init();
    _updateTheme();
    _startTimer();
    await _themeService.applyBrightnessSettings();
  }

  /// 切换夜间模式开关
  Future<void> toggleNightMode(bool enabled) async {
    await _prefsService.setNightModeEnabled(enabled);
    _updateTheme();
    await _themeService.applyBrightnessSettings();
    notifyListeners();
  }

  /// 设置夜间模式类型
  Future<void> setNightModeType(NightModeType type) async {
    await _prefsService.setNightModeType(type);
    _updateTheme();
    await _themeService.applyBrightnessSettings();
    notifyListeners();
  }

  /// 手动刷新主题（用于测试或强制更新）
  Future<void> refreshTheme() async {
    _updateTheme();
    await _themeService.applyBrightnessSettings();
    notifyListeners();
  }

  /// 更新主题
  void _updateTheme() {
    final newTheme = _themeService.getCurrentTheme();
    if (_currentTheme != newTheme) {
      _currentTheme = newTheme;
      notifyListeners();
    }
  }

  /// 启动定时器，定期检查主题变化
  void _startTimer() {
    _timer?.cancel();
    
    // 每分钟检查一次主题变化
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final shouldUpdate = _shouldUpdateTheme();
      if (shouldUpdate) {
        _updateTheme();
        _themeService.applyBrightnessSettings();
      }
    });
  }

  /// 判断是否需要更新主题
  bool _shouldUpdateTheme() {
    if (!isNightModeEnabled) return false;
    
    // 只有在时间控制模式下才需要定期检查
    if (nightModeType == NightModeType.timeControl) {
      final currentIsDark = isDarkTheme;
      final shouldBeDark = _themeService.shouldUseDarkTheme();
      return currentIsDark != shouldBeDark;
    }
    
    return false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
