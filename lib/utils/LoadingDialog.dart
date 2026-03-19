import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//LoadingDialog.show(context, message: "偵探裝備準備中...");

class LoadingDialog {
  static void show(BuildContext context, {String? message = "拼命加載中"}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // 設置背景透明
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(message ?? "拼命加載中"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    // 檢查當前最上層是否為 Dialog，避免誤關頁面
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
