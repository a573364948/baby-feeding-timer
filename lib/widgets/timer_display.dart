import 'package:flutter/material.dart';
import '../providers/timer_provider.dart';

/// 计时器显示组件
class TimerDisplay extends StatelessWidget {
  final String time;
  final TimerState state;

  const TimerDisplay({
    super.key,
    required this.time,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 时间显示
          Text(
            time,
            style: TextStyle(
              fontSize: _getFontSize(context),
              fontWeight: FontWeight.bold,
              color: _getTextColor(context),
              fontFamily: 'monospace',
            ),
          ),
          
          // 状态图标
          SizedBox(height: _getIconSpacing(context)),
          Icon(
            _getStateIcon(),
            size: _getIconSize(context),
            color: _getTextColor(context),
          ),
        ],
      ),
    );
  }

  /// 获取背景颜色
  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (state) {
      case TimerState.countdown:
        return isDark
            ? const Color(0xFF2E2E2E)  // 深色模式：深灰
            : Colors.blue[50]!;        // 浅色模式：浅蓝
      case TimerState.overtime:
        return isDark
            ? const Color(0xFF3E2723)  // 深色模式：深棕红
            : Colors.red[50]!;         // 浅色模式：浅红
      case TimerState.stopped:
        return isDark
            ? const Color(0xFF2E2E2E)  // 深色模式：深灰
            : Colors.grey[200]!;       // 浅色模式：浅灰
    }
  }

  /// 获取文字颜色
  Color _getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (state) {
      case TimerState.countdown:
        return isDark
            ? const Color(0xFFFF8A50)  // 深色模式：温暖橙色
            : Colors.blue[700]!;       // 浅色模式：深蓝
      case TimerState.overtime:
        return isDark
            ? const Color(0xFFFF6B6B)  // 深色模式：温暖红色
            : Colors.red[700]!;        // 浅色模式：深红
      case TimerState.stopped:
        return isDark
            ? const Color(0xFFE0E0E0)  // 深色模式：浅灰
            : Colors.grey[600]!;       // 浅色模式：深灰
    }
  }

  /// 获取状态图标
  IconData _getStateIcon() {
    switch (state) {
      case TimerState.countdown:
        return Icons.timer;
      case TimerState.overtime:
        return Icons.notification_important;
      case TimerState.stopped:
        return Icons.timer_off;
    }
  }

  /// 获取字体大小
  double _getFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 在测试环境中使用更小的字体
    if (screenWidth < 300 || screenHeight < 500) {
      return 24; // 测试环境或极小屏幕
    } else if (screenWidth > 600) {
      return 72; // 平板或大屏幕
    } else if (screenWidth > 400) {
      return 56; // 普通手机
    } else {
      return 36; // 小屏幕手机
    }
  }

  /// 获取图标大小
  double _getIconSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 在测试环境中使用更小的图标
    if (screenWidth < 300 || screenHeight < 500) {
      return 24; // 测试环境或极小屏幕
    } else if (screenWidth > 600) {
      return 64; // 平板或大屏幕
    } else {
      return 48; // 普通手机
    }
  }

  /// 获取图标间距
  double _getIconSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 在测试环境中使用更小的间距
    if (screenWidth < 300 || screenHeight < 500) {
      return 8; // 测试环境或极小屏幕
    } else {
      return 20; // 正常间距
    }
  }
}
