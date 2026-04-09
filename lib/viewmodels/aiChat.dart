//訊息
import 'package:yolo_text/contants/index.dart';

class AiChatMessage {
  final int sessionId;
  final String responseMessage;
  final String ttsAudioUrl;

  AiChatMessage({
    required this.sessionId,
    required this.responseMessage,
    required this.ttsAudioUrl,
  });



  // 轉換為 JSON 格式
  factory AiChatMessage.fromJson(Map<String, dynamic> json) {

    // 獲取原始路徑
    String rawTtsUrl = json['ttsAudioUrl'] ?? '';
    String fullTtsUrl = '';

    // ✅ 修正點：即時訊息也需要自動拼接 BASE_URL
    if (rawTtsUrl.isNotEmpty) {
      // 檢查是否已經包含 http，若無則拼接
      fullTtsUrl = rawTtsUrl.startsWith('http')
          ? rawTtsUrl
          : "${GlobalConstants.BASE_URL}$rawTtsUrl";
    }

    return AiChatMessage(
      sessionId: json['sessionId'],
      responseMessage: json['responseMessage'],
      ttsAudioUrl: fullTtsUrl,
    );
  }
}

//查詢歷史
class AiChatHistory {
  final int sessionId;
  final String role; // "user" 或 "assistant"
  final String content;
  final String? ttsUrl;
  final DateTime? timestamp;

  AiChatHistory({
    required this.sessionId,
    required this.role,
    required this.content,
    this.ttsUrl,
    this.timestamp,
  });

  factory AiChatHistory.fromJson(Map<String, dynamic> json, int sessionId) {
    String? rawTtsUrl = json['tts_url'];
    String? fullTtsUrl;
    // 如果後端回傳的是相對路徑，則自動拼接 BASE_URL
    // 增加 startsWith 檢查，避免重複拼接
    if (rawTtsUrl != null && rawTtsUrl.isNotEmpty) {
      fullTtsUrl = rawTtsUrl.startsWith('http')
          ? rawTtsUrl
          : "${GlobalConstants.BASE_URL}$rawTtsUrl";
    }

    return AiChatHistory(
      sessionId: sessionId,
      role: json['role'] ?? '',
      content: json['content'] ?? '',
      ttsUrl: fullTtsUrl, // 這裡儲存的就是完整 URL
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }
}
