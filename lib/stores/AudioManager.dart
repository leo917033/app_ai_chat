import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// TODO:再播放tts音檔時讓live2d動嘴巴
class AudioManager {
  // 使用 static 確保全域共用同一個播放器實例，避免多個聲音同時播放疊加
  static final AudioPlayer _player = AudioPlayer();
  //
  static final Dio _dio = Dio();

  // 用來操作 Live2D 的控制器
  static WebViewController? _webViewController;

  // 初始化時傳入控制器
  static void init(WebViewController controller) {
    _webViewController = controller;

    // 監聽播放狀態變更
    _player.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.playing) {
        _setLive2DMouth(true); // 開始播放 -> 動嘴巴
      } else {
        _setLive2DMouth(false); // 停止、暫停或完成 -> 閉嘴
      }
    });
  }

  // 執行 JS 讓 Live2D 動嘴巴
  static void _setLive2DMouth(bool moving) {
    if (_webViewController != null) {
      _webViewController!.runJavaScript("window.setMouthMoving($moving);");
    }
  }
  /// 播放語音（優先讀取本地快取）
  static Future<void> playVoice(String url) async {
    if (url.isEmpty) return;

    // 安全檢查：如果網址不包含 http，說明拼接有誤，不執行播放以防崩潰
    if (!url.startsWith('http')) {
      debugPrint("AudioManager 錯誤: 網址格式不正確 (缺少 Host): $url");
      return;
    }

    try {
      // 1. 取得檔案名稱 (例如: audio_1775458163.mp3)
      final String fileName = url.split('/').last;

      // 2. 取得手機的應用程式文件目錄
      final Directory directory = await getApplicationDocumentsDirectory();
      final String localPath = "${directory.path}/$fileName";
      final File file = File(localPath);

      // 3. 檢查本地檔案是否存在
      if (await file.exists()) {
        debugPrint("播放本地快取音檔: $localPath");
        await _player.stop();
        await _player.play(DeviceFileSource(localPath));
      } else {
        debugPrint("本地無檔案，開始下載並播放: $url");

        // 停止當前播放
        await _player.stop();

        // 4. 下載檔案並儲存到本地
        await _dio.download(url, localPath);

        // 5. 播放剛下載好的本地檔案
        await _player.play(DeviceFileSource(localPath));
      }
    } catch (e) {
      debugPrint("語音播放或下載錯誤: $e");
      // 備援方案：嘗試線上直接播放
      if (url.startsWith('http')) {
        await _player.play(UrlSource(url));
      }
    }
  }
  /// 停止當前所有播放（用於刪除紀錄時立即靜音）
  static Future<void> stopAll() async {
    await _player.stop();
    _setLive2DMouth(false);
  }

  /// 清除手機內所有快取的音檔 (.mp3)
  static Future<void> clearAllCachedVoices() async {
    try {
      await stopAll(); // 先停止播放

      final Directory directory = await getApplicationDocumentsDirectory();
      if (await directory.exists()) {
        // 列出所有檔案
        final List<FileSystemEntity> files = directory.listSync();
        int deleteCount = 0;

        for (var file in files) {
          // 只刪除 mp3 結尾的檔案，避免刪掉其他重要資料
          if (file is File && file.path.endsWith('.mp3')) {
            await file.delete();
            deleteCount++;
          }
        }
        debugPrint("AudioManager: 已成功清除 $deleteCount 個本地音檔快取");
      }
    } catch (e) {
      debugPrint("AudioManager: 清除快取失敗: $e");
    }
  }
}