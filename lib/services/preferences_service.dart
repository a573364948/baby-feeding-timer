import 'package:shared_preferences/shared_preferences.dart';
import 'theme_service.dart';

/// 偏好设置服务类
class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  SharedPreferences? _prefs;

  /// 初始化偏好设置
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 获取默认倒计时时长（分钟）
  int getDefaultCountdownMinutes() {
    return _prefs?.getInt('default_countdown_minutes') ?? 180; // 默认3小时
  }

  /// 设置默认倒计时时长（分钟）
  Future<bool> setDefaultCountdownMinutes(int minutes) async {
    await init();
    return await _prefs!.setInt('default_countdown_minutes', minutes);
  }

  /// 获取上次喂奶时间
  DateTime? getLastFeedingTime() {
    final timestamp = _prefs?.getInt('last_feeding_time');
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  /// 设置上次喂奶时间
  Future<bool> setLastFeedingTime(DateTime time) async {
    await init();
    return await _prefs!.setInt('last_feeding_time', time.millisecondsSinceEpoch);
  }

  /// 获取是否首次使用
  bool isFirstTime() {
    return _prefs?.getBool('is_first_time') ?? true;
  }

  /// 设置首次使用标记
  Future<bool> setFirstTime(bool isFirst) async {
    await init();
    return await _prefs!.setBool('is_first_time', isFirst);
  }

  /// 获取是否启用屏幕常亮
  bool isKeepScreenOn() {
    return _prefs?.getBool('keep_screen_on') ?? true;
  }

  /// 设置屏幕常亮
  Future<bool> setKeepScreenOn(bool keepOn) async {
    await init();
    return await _prefs!.setBool('keep_screen_on', keepOn);
  }

  /// 获取是否启用夜间模式
  bool isNightModeEnabled() {
    return _prefs?.getBool('night_mode_enabled') ?? false;
  }

  /// 设置夜间模式
  Future<bool> setNightModeEnabled(bool enabled) async {
    await init();
    return await _prefs!.setBool('night_mode_enabled', enabled);
  }

  /// 获取夜间模式类型
  NightModeType getNightModeType() {
    final typeIndex = _prefs?.getInt('night_mode_type') ?? 0;
    return NightModeType.values[typeIndex];
  }

  /// 设置夜间模式类型
  Future<bool> setNightModeType(NightModeType type) async {
    await init();
    return await _prefs!.setInt('night_mode_type', type.index);
  }

  /// 清除所有偏好设置
  Future<bool> clear() async {
    await init();
    return await _prefs!.clear();
  }
}
