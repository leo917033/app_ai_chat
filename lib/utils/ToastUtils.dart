import 'package:flutter/material.dart';

/// Toast 工具類：用於統一管理應用內的輕量級提示（SnackBar）
class ToastUtils {

  // 閥門控制變數：記錄當前是否正在顯示提示，防止短時間內重複觸發
  static bool showLoading = false;

  /// 顯示一個自定義樣式的 Toast (SnackBar)
  /// [context] 內容上下文，用於查找 ScaffoldMessenger
  /// [msg] 要顯示的文字內容，若為 null 則顯示 "成功"
  static void showToast(BuildContext context, String? msg) {

    // 如果閥門為 true，表示上一個提示還在顯示週期內，直接攔截，不再彈出新提示
    if(ToastUtils.showLoading){
      return;
    }

    // 開啟閥門，鎖定狀態
    ToastUtils.showLoading = true;

    // 設定計時器，3 秒後（與 SnackBar 顯示時間一致）重置閥門狀態
    Future.delayed(Duration(seconds: 3), () {
      ToastUtils.showLoading = false;
    });

    // 透過 ScaffoldMessenger 彈出 SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: 200, // 設置寬度（配合 floating 行為）
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40) // 設置圓角，使其看起來像膠囊狀
        ),
        behavior: SnackBarBehavior.floating, // 使 SnackBar 懸浮，不貼在底部
        duration: Duration(seconds: 3), // 提示顯示持續時間
        content: Text(
            msg ?? "成功", // 內容，若 msg 為空則顯示預設字樣
            textAlign: TextAlign.center // 文字居中
        ),
      ),
    );
  }
}
