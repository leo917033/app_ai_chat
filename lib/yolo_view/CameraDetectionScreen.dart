import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/models/yolo_result.dart';
import 'package:ultralytics_yolo/models/yolo_task.dart';
import 'package:ultralytics_yolo/widgets/yolo_controller.dart';
import 'package:ultralytics_yolo/widgets/yolo_overlay.dart';
import 'package:ultralytics_yolo/yolo_view.dart';

class CameraDetectionScreen extends StatefulWidget {
  // 接收從 index.dart 傳過來的隨機目標
  final String targetEnglish;
  final String targetChinese;

  const CameraDetectionScreen({
    super.key,
    required this.targetEnglish,
    required this.targetChinese,
  });

  @override
  State<CameraDetectionScreen> createState() => _CameraDetectionScreenState();
}

class _CameraDetectionScreenState extends State<CameraDetectionScreen> {
  late YOLOViewController controller;
  List<YOLOResult> currentResults = [];

  // --- 新增這行來解決 Undefined name 錯誤 ---
  DateTime? lastProcessedTime;

  @override
  void initState() {
    super.initState();
    controller = YOLOViewController();
  }

  // 在 CameraDetectionScreen.dart 的 State 類別中
  @override
  void dispose() {
    super.dispose();
  }

  // 按下確認按鈕時的判斷邏輯
  void _checkResult() {
    if (currentResults.isEmpty) return;

    // 比對偵測到的 label 是否符合目標的英文名稱
    bool isMatch = currentResults.any((result) =>
    result.className.toLowerCase().trim() ==
        widget.targetEnglish.toLowerCase().trim());

    _showResultDialog(isMatch);
  }

  // 彈出對/錯結果視窗
  void _showResultDialog(bool success) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: Icon(
              success ? Icons.check_circle : Icons.cancel,
              color: success ? Colors.green : Colors.red,
              size: 60,
            ),
            content: Text(
              success
                  ? "太棒了！找到了 ${widget.targetChinese}"
                  : "這不是 ${widget.targetChinese}，再找找看！",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // 關閉彈窗
                    if (success) Navigator.pop(context); // 成功則返回主選單
                  },
                  child: Text(success ? "完成任務" : "重試"),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. YOLO 相機渲染層
          YOLOView(
            modelPath: 'yolo11n',
            task: YOLOTask.detect,
            controller: controller,
            // 隱藏框框上的文字與機率
            // 修正：使用自定義樣式將文字大小設為 0 以達成隱藏效果
            // 使用正確的 overlayTheme 參數來隱藏文字
            overlayTheme: const YOLOOverlayTheme(
              boundingBoxColor: Colors.red,       // 框框顏色 (對應之前的 boxColor)
              boundingBoxWidth: 3.0,             // 框框粗細 (對應之前的 boxStrokeWidth)
              textColor: Colors.transparent,      // 文字設為透明以達成隱藏效果
              textSize: 0.0,                      // 文字大小設為 0
              labelBackgroundColor: Colors.transparent, // 標籤背景設為透明
            ),
            onResult: (results) {
              // 1. 檢查組件是否還在樹中
              if (!mounted) return;

              final now = DateTime.now();
              // 2. 節流 (Throttling)：每 200 毫秒才處理一次
              // 這能有效避免 Buffer 堆積導致的 ImageReader_JNI 警告
              if (lastProcessedTime == null ||
                  now.difference(lastProcessedTime!) > const Duration(milliseconds: 200)) {

                lastProcessedTime = now;

                // 3. 只有在結果真的有變化或必要時才更新 UI
                setState(() {
                  currentResults = results;
                });
              }
            },
          ),

          // 2. 頂部任務顯示 (顯示中文)
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                "請找尋：${widget.targetChinese}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),

          // 3. 底部控制按鈕
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 返回按鈕
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // 確認按鈕：只有偵測到任何東西時才亮起
                GestureDetector(
                  onTap: currentResults.isNotEmpty ? _checkResult : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    decoration: BoxDecoration(
                      color: currentResults.isNotEmpty
                          ? Colors.blueAccent
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "確認拍攝",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}