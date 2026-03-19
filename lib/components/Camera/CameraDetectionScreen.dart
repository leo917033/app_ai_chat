import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultralytics_yolo/models/yolo_result.dart';
import 'package:ultralytics_yolo/models/yolo_task.dart';
import 'package:ultralytics_yolo/widgets/yolo_controller.dart';
import 'package:ultralytics_yolo/yolo_view.dart';

import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:yolo_text/utils/LoadingDialog.dart';

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

  //初始化截圖控制器
  ScreenshotController screenshotController = ScreenshotController();

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

  //儲存照片與紀錄到圖鑑
  Future<void> _saveToCollection(Uint8List imageBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    // 檔名規則：目標英文_時間戳記.png
    final String fileName =
        "${widget.targetEnglish}_${DateTime.now().millisecondsSinceEpoch}.png";
    final File imageFile = File('${directory.path}/$fileName');

    // 儲存實際檔案
    await imageFile.writeAsBytes(imageBytes);

    // 使用 SharedPreferences 紀錄已解鎖
    final prefs = await SharedPreferences.getInstance();
    // 儲存格式範例： key: "collected_cell phone", value: "檔案路徑|時間"
    await prefs.setString(
      'collected_${widget.targetEnglish}',
      '${imageFile.path}|${DateTime.now().toString()}',
    );

    //print("已存入圖鑑: ${imageFile.path}");
  }

  // 按下確認按鈕時的判斷邏輯
  Future<void> _checkResult() async {
    // 即使 currentResults 為空，我們也可以讓玩家拍一張（或者保持原樣）

    // 1. 比對邏輯
    bool isMatch = currentResults.any(
          (result) =>
      result.className.toLowerCase().trim() ==
          widget.targetEnglish.toLowerCase().trim(),
    );

    LoadingDialog.show(context, message: "辨識中...");

    // 2. 無論成敗，都截取當前畫面作為「證物」
    final Uint8List? imageBytes = await screenshotController.capture();

    if (isMatch && imageBytes != null) {
      // 只有成功時才存入圖鑑資料庫
      await _saveToCollection(imageBytes);
    }
    LoadingDialog.hide(context);
    // 3. 停止相機與偵測
    controller.stop();

    // 4. 彈出結果視窗，並把截取的圖片傳過去
    _showResultDialog(isMatch, imageBytes);
  }

  // 彈出對/錯結果視窗
  void _showResultDialog(bool success, Uint8List? capturedImage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.cancel,
              color: success ? Colors.green : Colors.red,
              size: 50,
            ),
            const SizedBox(height: 10),
            Text(
              success ? "任務達成！" : "辨識失敗",
              style: TextStyle(
                color: success ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, // 讓視窗大小隨內容縮放
          children: [
            // --- 顯示剛才截取的照片 ---
            if (capturedImage != null)
              Container(
                width: double.maxFinite,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    capturedImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 15),
            Text(
              success
                  ? "太棒了！找到了 ${widget.targetChinese}"
                  : "這看起來不像 ${widget.targetChinese}，再找找看！",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                backgroundColor: success ? Colors.green : Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                Navigator.pop(context); // 關閉彈窗
                if (success) {
                  Navigator.pop(context); // 成功則返回上一頁
                } else {
                  // 重試邏輯
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraDetectionScreen(
                        targetEnglish: widget.targetEnglish,
                        targetChinese: widget.targetChinese,
                      ),
                    ),
                  );
                }
              },
              child: Text(
                success ? "收進圖鑑" : "重新嘗試",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
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
          Screenshot(
            controller: screenshotController,
            child:
                // 1. YOLO 相機渲染層
                YOLOView(
                  modelPath: 'yolo11n',
                  task: YOLOTask.detect,
                  controller: controller,
                  // 隱藏框框上的文字與機率
                  // 修正：使用自定義樣式將文字大小設為 0 以達成隱藏效果
                  // 使用正確的 overlayTheme 參數來隱藏文字
                  //overlayTheme: const YOLOOverlayTheme(
                  //  boundingBoxColor: Colors.red,       // 框框顏色 (對應之前的 boxColor)
                  //  boundingBoxWidth: 3.0,             // 框框粗細 (對應之前的 boxStrokeWidth)
                  //  textColor: Colors.transparent,      // 文字設為透明以達成隱藏效果
                  //  textSize: 0.0,                      // 文字大小設為 0
                  //  labelBackgroundColor: Colors.transparent, // 標籤背景設為透明
                  //),
                  onResult: (results) {
                    // 1. 檢查組件是否還在樹中
                    if (!mounted) return;

                    final now = DateTime.now();
                    // 2. 節流 (Throttling)：每 200 毫秒才處理一次
                    if (lastProcessedTime == null ||
                        now.difference(lastProcessedTime!) >
                            const Duration(milliseconds: 200)) {
                      lastProcessedTime = now;

                      // 3. 只有在結果真的有變化或必要時才更新 UI
                      setState(() {
                        currentResults = results;
                      });
                    }
                  },
                ),
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
                "請尋找：${widget.targetChinese}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
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
                      horizontal: 40,
                      vertical: 15,
                    ),
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
                        fontWeight: FontWeight.bold,
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
