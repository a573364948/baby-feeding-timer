import 'dart:async';
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
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isFullScreen = false;
  Timer? _idleTimer;
  static const Duration _idleTimeout = Duration(seconds: 10); // 10秒无操作进入全屏

  @override
  void initState() {
    super.initState();
    _startIdleTimer();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  /// 启动空闲计时器
  void _startIdleTimer() {
    _resetIdleTimer();
  }

  /// 重置空闲计时器
  void _resetIdleTimer() {
    _idleTimer?.cancel();
    if (_isFullScreen) {
      setState(() {
        _isFullScreen = false;
      });
    }
    _idleTimer = Timer(_idleTimeout, () {
      if (mounted) {
        setState(() {
          _isFullScreen = true;
        });
      }
    });
  }

  /// 处理屏幕点击
  void _handleTap() {
    _resetIdleTimer();
  }

  /// 处理长按（原有逻辑）
  void _handleLongPress(TimerProvider timerProvider) {
    _resetIdleTimer();
    _showResetConfirmation(context, timerProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _isFullScreen ? null : AppBar(
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
          final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
          
          return GestureDetector(
            onTap: _handleTap,
            onLongPress: () => _handleLongPress(timerProvider),
            child: isLandscape 
              ? _buildLandscapeLayout(context, timerProvider)
              : _buildPortraitLayout(context, timerProvider),
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
        defaultDuration: timerProvider.defaultDuration,
        onConfirm: (amountPrepared, amountConsumed, notes, customDuration) {
          timerProvider.startCountdown(
            amountPrepared: amountPrepared,
            amountConsumed: amountConsumed,
            notes: notes,
            customDuration: customDuration,
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

  /// 横屏布局
  Widget _buildLandscapeLayout(BuildContext context, TimerProvider timerProvider) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 左侧信息区域 (30%)
          Expanded(
            flex: 3,
            child: _buildLeftInfo(context, timerProvider),
          ),
          // 中间计时器区域 (40%)
          Expanded(
            flex: 4,
            child: _buildTimerArea(context, timerProvider),
          ),
          // 右侧操作区域 (30%)
          Expanded(
            flex: 3,
            child: _buildRightActions(context, timerProvider),
          ),
        ],
      ),
    );
  }

  /// 竖屏布局（原有布局）
  Widget _buildPortraitLayout(BuildContext context, TimerProvider timerProvider) {
    return Container(
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
    );
  }

  /// 左侧信息区域
  Widget _buildLeftInfo(BuildContext context, TimerProvider timerProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (timerProvider.state == TimerState.stopped)
            const Text(
              '点击右侧按钮\n开始倒计时',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            )
          else if (timerProvider.state == TimerState.countdown)
            const Text(
              '距离小熊猫\n下次嗷嗷叫还有',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            )
          else if (timerProvider.state == TimerState.overtime)
            const Text(
              '小熊猫要\n嗷嗷叫了！\n🐼',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.red,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  /// 中间计时器区域
  Widget _buildTimerArea(BuildContext context, TimerProvider timerProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Transform.scale(
          scale: 1.2, // 横屏时放大计时器显示
          child: TimerDisplay(
            time: timerProvider.formattedTime,
            state: timerProvider.state,
          ),
        ),
      ),
    );
  }

  /// 右侧操作区域
  Widget _buildRightActions(BuildContext context, TimerProvider timerProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 操作提示
          if (timerProvider.state != TimerState.stopped)
            const Text(
              '长按屏幕2秒\n重新开始倒计时',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                height: 1.5,
              ),
            ),

          const SizedBox(height: 20),
          
          // 开始按钮
          if (timerProvider.state == TimerState.stopped)
            ElevatedButton(
              onPressed: () => _showFeedingInputDialog(context, timerProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('开始\n倒计时'),
            ),
        ],
      ),
    );
  }
}
