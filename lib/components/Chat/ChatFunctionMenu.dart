import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yolo_text/api/aiChat.dart';
import 'package:yolo_text/utils/DialogUtils.dart';
import 'package:yolo_text/utils/ToastUtils.dart';

class ChatFunctionMenu extends StatelessWidget {
  final WebViewController controller; // 控制 Live2D 的 WebView
  final VoidCallback onClearHistory; // 供父組件傳入清除邏輯

  const ChatFunctionMenu({
    super.key,
    required this.controller,
    required this.onClearHistory,
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
              //   刪除持久化 _messages
              // 使用定義的 DialogUtils 顯示確認彈窗
              DialogUtils.showProtocolDialog(
                context,
                "確認刪除",
                "您確定要刪除所有聊天歷史紀錄嗎？此操作無法撤銷。",
                showConfirmActions: true, // 開啟「取消/確定」模式
                onConfirm: () {
                  print("執行：刪除聊天歷史紀錄與持久化資料");

                  // 1. 呼叫傳進來的清除回調 (通知父組件清除 _messages ，串接刪除 API)
                  onClearHistory();

                  // 提示使用者
                  ToastUtils.showToast(context, "歷史紀錄已成功清除");
                },
              );
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
            label: "語言選擇",
            onPressed: () {
              // TODO:語言選擇邏輯
              print("執行：語言選擇邏輯");
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