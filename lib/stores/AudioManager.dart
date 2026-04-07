import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // 使用 static 確保全域共用同一個播放器實例，避免多個聲音同時播放疊加
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playVoice(String url) async {
    if (url.isEmpty) return;

    try {
      // 停止當前正在播放的聲音（如果有）
      await _player.stop();
      // 直接線上播放
      await _player.play(UrlSource(url));
    } catch (e) {
      print("語音播放錯誤: $e");
    }
  }
}