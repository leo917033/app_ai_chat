import 'package:flutter/material.dart';

class DialogUtils{
  static void showProtocolDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView( // 避免內容過長導致溢出
            child: Text(content),
          ),
          actions: [
            TextButton(
              child: const Text("我知道了"),
              onPressed: () {
                Navigator.of(context).pop(); // 關閉彈窗
              },
            ),
          ],
        );
      },
    );
  }
}