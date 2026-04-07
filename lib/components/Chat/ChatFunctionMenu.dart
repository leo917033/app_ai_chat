import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatFunctionMenu extends StatelessWidget {
  final WebViewController controller;

  const ChatFunctionMenu({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // 使用 Positioned 定位在右上角
    return Positioned(
      top: 50, // 考慮狀態欄高度，可調整
      right: 15,
      child: Column(
        children: [
          _buildMenuButton(
            icon: Icons.delete_sweep_outlined,
            label: "刪除歷史",
            onPressed: () {
              print("執行：刪除聊天歷史紀錄");
              // TODO: 串接刪除 API
            },
          ),
          const SizedBox(height: 15),
          _buildMenuButton(
            icon: Icons.refresh_rounded,
            label: "重整模型",
            onPressed: () {
              print("執行：重新載入 WebView");
              controller.reload();
            },
          ),
          const SizedBox(height: 15),
          _buildMenuButton(
            icon: Icons.settings_outlined,
            label: "功能設定",
            onPressed: () {
              print("執行：開啟設定面板");
            },
          ),
        ],
      ),
    );
  }

  /// 建立具備半透明背景的圓形按鈕
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5), // 半透明背景避免被 Live2D 顏色干擾
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 24),
            onPressed: onPressed,
            tooltip: label,
          ),
        ),
      ],
    );
  }
}