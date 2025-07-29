import 'package:flutter/material.dart';

import 'package:wakelock_plus/wakelock_plus.dart';
import 'preferences_service.dart';

/// 夜间模式切换方式
enum NightModeType {
  timeControl,    // 按时间控制
  followSystem,   // 跟随系统
}

/// 主题服务类
class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  final PreferencesService _prefsService = PreferencesService();
  
  // 夜间模式时间设置
  static const int nightStartHour = 20; // 晚上8点
  static const int nightEndHour = 6;    // 早上6点
  
  // 夜间亮度
  static const double nightBrightness = 0.3; // 30%

  /// 获取当前主题数据
  ThemeData getCurrentTheme() {
    if (shouldUseDarkTheme()) {
      return _getDarkTheme();
    } else {
      return _getLightTheme();
    }
  }

  /// 判断是否应该使用深色主题
  bool shouldUseDarkTheme() {
    final nightModeEnabled = _prefsService.isNightModeEnabled();
    if (!nightModeEnabled) return false;

    final nightModeType = _prefsService.getNightModeType();
    
    switch (nightModeType) {
      case NightModeType.timeControl:
        return _isNightTime();
      case NightModeType.followSystem:
        return _isSystemDarkMode();
    }
  }

  /// 浅色主题
  ThemeData _getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),
    );
  }

  /// 深色主题（温暖深棕色系）
  ThemeData _getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFFFF8A50),        // 温暖橙色
        primaryContainer: const Color(0xFF8D4E2A), // 深橙棕色
        secondary: const Color(0xFFFFB74D),       // 浅橙色
        secondaryContainer: const Color(0xFF5D4037), // 深棕色
        surface: const Color(0xFF2E2E2E),         // 深灰表面
        // background: const Color(0xFF1A1A1A),      // 深棕黑背景 (deprecated)
        error: const Color(0xFFFF6B6B),          // 温暖红色
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFFE0E0E0),      // 浅灰文字
        // onBackground: const Color(0xFFE0E0E0),   // 浅灰文字 (deprecated)
      ),
      cardColor: const Color(0xFF2E2E2E),         // 卡片颜色
      scaffoldBackgroundColor: const Color(0xFF1A1A1A), // 脚手架背景
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2E2E2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      useMaterial3: true,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 72, 
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF8A50), // 温暖橙色
        ),
        displayMedium: TextStyle(
          fontSize: 56, 
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF8A50),
        ),
        displaySmall: TextStyle(
          fontSize: 48, 
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF8A50),
        ),
        headlineLarge: TextStyle(
          fontSize: 32, 
          fontWeight: FontWeight.w600,
          color: Color(0xFFE0E0E0),
        ),
        headlineMedium: TextStyle(
          fontSize: 28, 
          fontWeight: FontWeight.w600,
          color: Color(0xFFE0E0E0),
        ),
        headlineSmall: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.w600,
          color: Color(0xFFE0E0E0),
        ),
        titleLarge: TextStyle(
          fontSize: 22, 
          fontWeight: FontWeight.w500,
          color: Color(0xFFE0E0E0),
        ),
        titleMedium: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.w500,
          color: Color(0xFFE0E0E0),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFFE0E0E0),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFFE0E0E0),
        ),
      ),
    );
  }

  /// 应用亮度设置
  Future<void> applyBrightnessSettings() async {
    try {
      // 保持屏幕常亮
      if (_prefsService.isKeepScreenOn()) {
        await WakelockPlus.enable();
      }
    } catch (e) {
      // Debug: print('设置屏幕常亮失败: $e');
    }
  }

  /// 判断是否为夜间时间
  bool _isNightTime() {
    final now = DateTime.now();
    final hour = now.hour;
    
    // 20:00 - 06:00 为夜间
    return hour >= nightStartHour || hour < nightEndHour;
  }

  /// 判断系统是否为深色模式
  bool _isSystemDarkMode() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  /// 获取夜间模式状态文本
  String getNightModeStatusText() {
    if (!_prefsService.isNightModeEnabled()) {
      return '夜间模式已关闭';
    }
    
    final nightModeType = _prefsService.getNightModeType();
    final isDark = shouldUseDarkTheme();
    
    switch (nightModeType) {
      case NightModeType.timeControl:
        if (isDark) {
          return '夜间模式 🌙 ($nightStartHour:00-${nightEndHour.toString().padLeft(2, '0')}:00)';
        } else {
          return '白天模式 ☀️ ($nightStartHour:00-${nightEndHour.toString().padLeft(2, '0')}:00)';
        }
      case NightModeType.followSystem:
        return isDark ? '夜间模式 🌙 (跟随系统)' : '白天模式 ☀️ (跟随系统)';
    }
  }
}
