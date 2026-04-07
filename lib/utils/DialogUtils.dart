import 'package:flutter/material.dart';
import 'dart:async';

class DialogUtils {

  /// 顯示協議內容或確認訊息的彈窗
  /// [context] 當前頁面的上下文
  /// [title]   標題
  /// [content] 詳細內容
  /// [showConfirmActions] 是否顯示「取消/確定」模式。預設 false (僅顯示「我知道了」)
  /// [onConfirm] 當點擊「確定」按鈕時的回調函式
  static void showProtocolDialog(BuildContext context,
      String title,
      String content, {
        bool showConfirmActions = false,
        VoidCallback? onConfirm,
      }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          actions: _buildActions(context, showConfirmActions, onConfirm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  /// 根據模式構建不同的按鈕組合
  static List<Widget> _buildActions(BuildContext context,
      bool showConfirmActions,
      VoidCallback? onConfirm,) {
    if (showConfirmActions) {
      // 模式：取消 + 確定
      return [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消', style: TextStyle(color: Colors.black87)),
        ),
        TextButton(
          onPressed: () {
            if (onConfirm != null) onConfirm();
            Navigator.pop(context);
          },
          child: const Text('確定', style: TextStyle(color: Colors.blue)),
        ),
      ];
    } else {
      // 模式：單一按鈕（我知道了）
      return [
        TextButton(
          child: const Text(
            "我知道了",
            style: TextStyle(color: Colors.blueAccent),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ];
    }
  }
}