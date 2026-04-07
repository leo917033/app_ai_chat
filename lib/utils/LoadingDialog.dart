import 'package:flutter/material.dart';
import 'dart:async';

import 'package:yolo_text/utils/ToastUtils.dart';

class LoadingDialog {
  /// 顯示加載彈窗
  /// [context] 上下文
  /// [message]
  // 用於追蹤當前是否有 Loading 在顯示，防止重複開啟
  static bool _isShowing = false;
  static Timer? _timeoutTimer;

  static void show(
    BuildContext context, {
    String message = "拼命加載中",
    int timeoutSeconds = 10,
  }) {
    // 如果已經在顯示中，就不重複開啟
    if (_isShowing) return;
    _isShowing = true;

    // 設定超時自動關閉
    _timeoutTimer?.cancel(); // 先取消舊的計時器（保險起見）
    _timeoutTimer = Timer(Duration(seconds: timeoutSeconds), () {
      if (_isShowing) {
        hide(context);
        // 可以選擇在這裡彈出一個 Toast 提示使用者超時
        ToastUtils.showToast(context, "Loading 超時，已自動關閉");
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false, // 禁止點擊背景關閉，確保流程完整
      builder: (context) {
        return PopScope(
          canPop: false, // 防止安卓實體返回鍵關閉彈窗
          child: Dialog(
            backgroundColor: Colors.transparent, // 彈窗外層背景透明
            elevation: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 25,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85), // 柔和的半透明白
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 根據內容縮放高度
                  children: [
                    // 使用你的 WebP 動畫
                    Image.asset(
                      "lib/assets/bu_img/c3.webp",
                      width: 120, // 稍微加大一點視覺效果更好
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent, // 與你按鈕風格統一的藍色
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 隱藏加載彈窗
  static void hide(BuildContext context) {
    if (_isShowing) {
      _isShowing = false;
      _timeoutTimer?.cancel(); // 正常關閉時，取消計時器
      _timeoutTimer = null;

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }
}
