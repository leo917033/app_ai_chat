import 'package:shared_preferences/shared_preferences.dart';

class UserThemeManager {
  static const String _bgTypeKey = "USER_BG_TYPE"; // 'color', 'asset', 'file'
  static const String _bgValueKey = "USER_BG_VALUE"; // 十六進位值、路徑或網址

  // 儲存設定
  static Future<void> saveBackground(String type, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bgTypeKey, type);
    await prefs.setString(_bgValueKey, value);
  }

  // 讀取設定 (返回 Map)
  static Future<Map<String, String>> getBackgroundSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'type': prefs.getString(_bgTypeKey) ?? 'color',
      'value': prefs.getString(_bgValueKey) ?? '0xFF2196F3', // 預設藍色
    };
  }
}