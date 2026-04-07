/// 定義單一聊天訊息的資料結構。
/// 這個類別 (Class) 是一個不可變的物件，用來儲存訊息的所有相關資訊。
class ChatMessage {
  /// 訊息的文字內容。
  final String text;

  /// 標記這則訊息是否由目前使用者發送。
  /// true 代表是自己發的，會顯示在右邊；false 代表是接收的，會顯示在左邊。
  final bool isSentByMe;

  /// 訊息發送或接收的時間戳記。
  /// 用於顯示時間和排序訊息。
  final DateTime timestamp;

  /// 完整的 TTS 撥放網址
  final String? ttsUrl;

  /// ChatMessage 的建構函式 (Constructor)。
  /// 使用 required 關鍵字確保在建立物件時，這些參數都必須被賦值。
  ChatMessage({
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    this.ttsUrl, // 選填，因為使用者發送的訊息通常沒有 TTS
  });
}