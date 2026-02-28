import 'package:flutter/material.dart';

/// 彈窗工具類：用於統一管理全域的對話框（Dialog）樣式
class DialogUtils {
  /// 顯示協議內容的彈窗（如用戶協議、隱私政策）
  ///
  /// [context] 當前頁面的上下文，用於掛載彈窗
  /// [title]   彈窗頂部顯示的標題（例如：「用戶協議」）
  /// [content] 彈窗中間顯示的詳細文本內容
  static void showProtocolDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    // 調用 Flutter 內建的 showDialog 函數
    showDialog(
      context: context,
      // barrierDismissible: false, // 如果設為 false，點擊彈窗外部不會關閉（視需求而定）
      builder: (BuildContext context) {
        return AlertDialog(
          // 設置彈窗標題
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          // 設置彈窗主體內容
          content: SingleChildScrollView(
            // 使用 SingleChildScrollView 確保當文本內容非常長時（如法律條文），
            // 用戶可以滾動閱讀，避免畫面產生溢出（Overflow）錯誤。
            child: Text(
              content,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),

          // 設置彈窗底部的操作按鈕
          actions: [
            TextButton(
              child: const Text(
                "我知道了",
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () {
                // 關閉當前的彈窗（將 Dialog 從導航棧中彈出）
                Navigator.of(context).pop();
              },
            ),
          ],

          // 設置彈窗的圓角樣式（選用）
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }
}
