import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/timer_display.dart';
import '../widgets/feeding_input_dialog.dart';
import '../services/share_service.dart';
import '../services/database_service.dart';
import 'settings_screen.dart';

/// 主屏幕
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          '小熊猫嗷嗷叫倒计时',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
        elevation: 0,
        actions: [
          // 夜间模式快速切换
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleNightMode(!themeProvider.isNightModeEnabled);
                },
                tooltip: themeProvider.isDarkTheme ? '切换到白天模式' : '切换到夜间模式',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareTodayStats(context),
            tooltip: '分享今日统计',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<TimerProvider>(
        builder: (context, timerProvider, child) {
          return GestureDetector(
            onLongPress: () => _showResetConfirmation(context, timerProvider),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 状态提示（移到上方）
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (timerProvider.state == TimerState.stopped)
                          const Text(
                            '点击下方按钮开始倒计时',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          )
                        else if (timerProvider.state == TimerState.countdown)
                          const Text(
                            '距离小熊猫下次嗷嗷叫还有',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else if (timerProvider.state == TimerState.overtime)
                          const Text(
                            '小熊猫要嗷嗷叫了！🐼',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 计时器显示区域
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: TimerDisplay(
                        time: timerProvider.formattedTime,
                        state: timerProvider.state,
                      ),
                    ),
                  ),

                  // 操作提示（移到下方）
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (timerProvider.state != TimerState.stopped)
                          const Text(
                            '长按屏幕2秒重新开始倒计时',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  
                  // 开始按钮
                  if (timerProvider.state == TimerState.stopped)
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () => _showFeedingInputDialog(context, timerProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('开始倒计时'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 显示喂奶信息输入对话框
  void _showFeedingInputDialog(BuildContext context, TimerProvider timerProvider) {
    showDialog(
      context: context,
      builder: (context) => FeedingInputDialog(
        onConfirm: (amountPrepared, amountConsumed, notes) {
          timerProvider.startCountdown(
            amountPrepared: amountPrepared,
            amountConsumed: amountConsumed,
            notes: notes,
          );
        },
      ),
    );
  }

  /// 显示重置确认对话框
  void _showResetConfirmation(BuildContext context, TimerProvider timerProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重新开始倒计时'),
        content: const Text('确定要重新开始倒计时吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showFeedingInputDialog(context, timerProvider);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 分享今日统计
  Future<void> _shareTodayStats(BuildContext context) async {
    try {
      final dbService = DatabaseService();
      final shareService = ShareService();
      final today = DateTime.now();

      final records = await dbService.getFeedingRecordsByDate(today);
      final totalAmount = await dbService.getTodayTotalAmount();

      if (records.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('今天小熊猫还没有嗷嗷叫哦 🐼')),
          );
        }
        return;
      }

      await shareService.shareDailyStats(
        date: today,
        records: records,
        totalAmount: totalAmount,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: $e')),
        );
      }
    }
  }
}
