// lib/pages/ProtocolPage/ProtocolPage.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProtocolPage extends StatefulWidget {
  final String title;
  final String assetPath;

  const ProtocolPage({super.key, required this.title, required this.assetPath});

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // 確保 WebViewWidget 在這裡，不要包裹在會縮減高度的容器中
      body: WebViewWidget(controller: _controller),
    );
  }
}