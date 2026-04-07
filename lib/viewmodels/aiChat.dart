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
    return AiChatMessage(
      sessionId: json['sessionId'],
      responseMessage: json['responseMessage'],
      ttsAudioUrl: json['ttsAudioUrl'],
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
    if (rawTtsUrl != null && rawTtsUrl.isNotEmpty) {
      fullTtsUrl = "${GlobalConstants.BASE_URL}$rawTtsUrl";
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
