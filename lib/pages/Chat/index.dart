import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart'; // 新增
import 'package:path/path.dart' as p;
import 'package:yolo_text/components/Chat/ChatTextComposer.dart'; // 新增

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final WebViewController _controller;
  HttpServer? _server;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
    // --- 加入以下 Debug 代碼 ---
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (WebResourceError error) {
            print("WebView Resource Error: ${error.description} (Code: ${error.errorCode})");
          },
          onPageFinished: (url) {
            print("WebView: Finished loading $url");
          },
        ),
      )
      ..addJavaScriptChannel(
        'Print', // 如果你在 JS 裡用 window.Print.postMessage('xxx')
        onMessageReceived: (JavaScriptMessage message) {
          print("JS Log: ${message.message}");
        },
      );
    // -------------------------
    _prepareAndStartServer();
  }

  Future<void> _prepareAndStartServer() async {
    try {
      // 1. 取得手機存儲路徑
      final docDir = await getApplicationSupportDirectory();
      final targetDir = Directory('${docDir.path}/live2d_web');

      // 如果目錄不存在，建立它
      if (!targetDir.existsSync()) {
        await targetDir.create(recursive: true);
      }

      // 2. 自動獲取所有 lib/assets/Live2d/ 下的資源路徑
      // 這會讀取 Flutter 內置的資源清單，避免手動輸入錯誤
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // 過濾出所有 Live2d 相關資源
      final List<String> allLive2dAssets = manifestMap.keys
          .where((String key) => key.startsWith('lib/assets/Live2d/'))
          .toList();

      print('Starting to copy ${allLive2dAssets.length} assets...');

      // 3. 執行拷貝動作
      for (String assetPath in allLive2dAssets) {
        final byteData = await rootBundle.load(assetPath);

        // 計算相對於 Live2d 資料夾的路徑
        final relativePath = assetPath.replaceFirst('lib/assets/Live2d/', '');
        final file = File('${targetDir.path}/$relativePath');

        // 建立必要的子目錄（例如 Resources/cc/）
        await file.parent.create(recursive: true);

        // 寫入檔案
        await file.writeAsBytes(byteData.buffer.asUint8List());
      }

      print('All assets copied to: ${targetDir.path}');

      // 4. 啟動靜態伺服器
      final handler = createStaticHandler(targetDir.path, defaultDocument: 'index.html');
      _server = await io.serve(handler, 'localhost', 8080);

      print('Server running on http://localhost:8080');

      // 5. 讓 WebView 載入
      _controller.loadRequest(Uri.parse('http://localhost:8080/index.html'));

    } catch (e) {
      print('Error in _prepareAndStartServer: $e');
    }
  }

  @override
  void dispose() {
    _server?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          ChatTextComposer(),
        ],
      ),
    );
  }
}