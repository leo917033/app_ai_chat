import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yolo_text/stores/UserController.dart';
import 'package:yolo_text/viewmodels/chat.dart';


class ChatMessageManager {
  static const String _BASE_KEY = "user_chat_history";

  // 取得當前帳號專屬的 Key，並加入 sessionId 區分不同對話
  Future<String> _getChatKey(int sessionId) async {
    final UserController userController = Get.find<UserController>();
    final String userId = userController.user.value.id;

    // 格式：user_chat_history_{userId}_session_{sessionId}
    if (userId != "null" && userId.isNotEmpty && userId != "0") {
      return "${_BASE_KEY}_${userId}_session_$sessionId";
    }
    return "${_BASE_KEY}_guest_session_$sessionId";
  }

  /// 儲存單一對話的所有訊息 (覆蓋式儲存)
  Future<void> saveMessages(int sessionId, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = await _getChatKey(sessionId);

    List<String> jsonList =
    messages.map((msg) => jsonEncode(msg.toJson())).toList();
    await prefs.setStringList(key, jsonList);
  }

  /// 獲取指定會話的本地紀錄
  Future<List<ChatMessage>> getMessages(int sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = await _getChatKey(sessionId);

    List<String>? jsonList = prefs.getStringList(key);
    if (jsonList == null) return [];

    return jsonList
        .map((item) => ChatMessage.fromJson(jsonDecode(item)))
        .toList();
  }

  /// 清除指定會話的本地紀錄
  Future<void> clearChatHistory(int sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = await _getChatKey(sessionId);
    await prefs.remove(key);
  }
}

// 匯出全域實例
final chatMessageManager = ChatMessageManager();