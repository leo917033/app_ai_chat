import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/models/yolo_result.dart';
import 'package:ultralytics_yolo/models/yolo_task.dart';
import 'package:ultralytics_yolo/widgets/yolo_controller.dart';

import 'package:ultralytics_yolo/yolo_view.dart';
// 引入 Ultralytics YOLO 的即時相機視圖元件

/*
 * 相機即時物件偵測畫面
 * 使用 YOLOView 直接串接相機並即時推論
 */
class CameraDetectionScreen extends StatefulWidget {
  @override
  _CameraDetectionScreenState createState() => _CameraDetectionScreenState();
}

class _CameraDetectionScreenState extends State<CameraDetectionScreen> {
  // YOLOView 控制器，用來控制相機與推論流程
  late YOLOViewController controller;

  // 儲存目前偵測到的物件結果
  List<YOLOResult> currentResults = [];

  @override
  void initState() {
    super.initState();

    // 初始化 YOLOViewController
    controller = YOLOViewController();
  }

  // --- 新增 Dispose 診斷點 ---
  @override
  void dispose() {
    // 必須關閉控制器，否則相機會一直佔用 Buffer 導致 ImageReader 報錯
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /*
           * YOLO 相機畫面
           * - 自動開啟相機
           * - 即時進行 YOLO 物件偵測
           */
          YOLOView(
            // 修正點：確保與 pubspec.yaml 中的註冊路徑完全一致
            modelPath: 'yolo11n',
            task: YOLOTask.detect,
            controller: controller,
            onResult: (results) {
              // 2. 修正屬性名稱：套件中通常是 className (如果 className 報錯，請改用 e.label)
              try {
                if (results.isNotEmpty) {
                  // 嘗試印出偵測到的物體名稱，增加 try-catch 避免屬性名稱錯誤導致 App 崩潰
                  debugPrint(">>> 偵測到: ${results.map((e) => e.className).toList()}");
                }
              } catch (e) {
                debugPrint("無法讀取屬性: $e");
              }

              if (results.isEmpty && currentResults.isEmpty) return;
              if (mounted && results.length != currentResults.length) {
                setState(() {
                  currentResults = results;
                });
              }
            },
            onPerformanceMetrics: (metrics) {
              // 診斷點：如果持續顯示 0，代表路徑錯誤或檔案損毀
              if (metrics.processingTimeMs > 0) {
                debugPrint('YOLO 運行中 - FPS: ${metrics.fps.toStringAsFixed(1)} | 耗時: ${metrics.processingTimeMs}ms');
              } else {
                // 如果一直印出這行，請檢查模型檔案是否存在於 assets/ 資料夾中
                debugPrint('YOLO 警告: 引擎已啟動但推論時間為 0 (模型載入失敗)');
              }
            },
          ),

          /*
           * UI 疊加層（顯示偵測到的物件數量）
           * 疊在相機畫面上方
           */
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54, // 半透明黑色背景
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                // 顯示目前畫面中偵測到的物件數量
                'Objects: ${currentResults.length}',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
