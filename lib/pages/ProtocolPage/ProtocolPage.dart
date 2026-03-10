// lib/pages/ProtocolPage/ProtocolPage.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yolo_text/utils/DialogUtils.dart';

class ProtocolPage extends StatefulWidget {
  final String title;
  final String assetPath;
  final bool showDialog; // 1. 加入判斷引數

  const ProtocolPage({
    super.key,
    required this.title,
    required this.assetPath,
    this.showDialog = false,
  });

  @override
  State<ProtocolPage> createState() => _ProtocolPageState();
}

class _ProtocolPageState extends State<ProtocolPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset(widget.assetPath); // 加載本地資產
    // 2. 判斷 widget.showDialog 是否為 true
    if (widget.showDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DialogUtils.showProtocolDialog(
          context,
          "用戶協議",
          "此為ai生成，內容不為真",
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      // 確保 WebViewWidget 在這裡，不要包裹在會縮減高度的容器中
      body: WebViewWidget(controller: _controller),
    );
  }
}
