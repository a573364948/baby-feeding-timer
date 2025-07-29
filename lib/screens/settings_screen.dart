import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../providers/timer_provider.dart';
import '../providers/theme_provider.dart';
import '../services/preferences_service.dart';
import '../services/theme_service.dart';
import 'history_screen.dart';

/// 设置界面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _prefsService = PreferencesService();
  bool _keepScreenOn = true;
  int _defaultMinutes = 180;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _keepScreenOn = _prefsService.isKeepScreenOn();
      _defaultMinutes = _prefsService.getDefaultCountdownMinutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '设置',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 倒计时设置
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '倒计时设置',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  // 默认时长设置
                  Row(
                    children: [
                      const Icon(Icons.timer),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('默认倒计时时长'),
                            Text(
                              '${(_defaultMinutes / 60).toStringAsFixed(1)} 小时',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _showDurationPicker,
                        child: const Text('修改'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // 显示设置
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '显示设置',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // 夜间模式设置
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Column(
                        children: [
                          SwitchListTile(
                            title: const Text('夜间模式'),
                            subtitle: Text(themeProvider.nightModeStatusText),
                            value: themeProvider.isNightModeEnabled,
                            onChanged: (value) => themeProvider.toggleNightMode(value),
                            secondary: Icon(
                              themeProvider.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                            ),
                          ),

                          // 夜间模式类型选择
                          if (themeProvider.isNightModeEnabled) ...[
                            const Divider(),
                            ListTile(
                              title: const Text('切换方式'),
                              subtitle: Text(
                                themeProvider.nightModeType == NightModeType.timeControl
                                    ? '按时间控制 (20:00-06:00)'
                                    : '跟随系统设置',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => _showNightModeTypeDialog(context, themeProvider),
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  const Divider(),

                  // 屏幕常亮设置
                  SwitchListTile(
                    title: const Text('保持屏幕常亮'),
                    subtitle: const Text('防止屏幕自动关闭'),
                    value: _keepScreenOn,
                    onChanged: _toggleKeepScreenOn,
                    secondary: const Icon(Icons.screen_lock_portrait),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 数据管理
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '数据管理',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  // 查看历史记录
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('查看嗷嗷叫记录'),
                    subtitle: const Text('查看小熊猫嗷嗷叫历史和统计数据'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 应用信息
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '关于应用',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '小熊猫嗷嗷叫倒计时应用 🐼\n'
                    '版本：1.0.0\n'
                    '专为可爱的小熊猫设计，帮助跟踪小熊猫嗷嗷叫的时间间隔。',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示时长选择器
  void _showDurationPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置默认倒计时时长'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('2 小时'),
              onTap: () => _setDuration(120),
            ),
            ListTile(
              title: const Text('2.5 小时'),
              onTap: () => _setDuration(150),
            ),
            ListTile(
              title: const Text('3 小时'),
              onTap: () => _setDuration(180),
            ),
            ListTile(
              title: const Text('3.5 小时'),
              onTap: () => _setDuration(210),
            ),
            ListTile(
              title: const Text('4 小时'),
              onTap: () => _setDuration(240),
            ),
          ],
        ),
      ),
    );
  }

  /// 设置时长
  void _setDuration(int minutes) {
    setState(() {
      _defaultMinutes = minutes;
    });
    _prefsService.setDefaultCountdownMinutes(minutes);
    
    // 更新TimerProvider中的默认时长
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    timerProvider.setDefaultDuration(Duration(minutes: minutes));
    
    Navigator.pop(context);
  }

  /// 切换屏幕常亮
  void _toggleKeepScreenOn(bool value) {
    setState(() {
      _keepScreenOn = value;
    });
    _prefsService.setKeepScreenOn(value);

    if (value) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  /// 显示夜间模式类型选择对话框
  void _showNightModeTypeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择切换方式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<NightModeType>(
              title: const Text('按时间控制'),
              subtitle: const Text('晚上8点到早上6点自动切换'),
              value: NightModeType.timeControl,
              groupValue: themeProvider.nightModeType,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setNightModeType(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<NightModeType>(
              title: const Text('跟随系统设置'),
              subtitle: const Text('根据系统深色模式设置'),
              value: NightModeType.followSystem,
              groupValue: themeProvider.nightModeType,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setNightModeType(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}
