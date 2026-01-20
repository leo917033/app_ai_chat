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
            modelPath: 'yolo11n',
            // 使用 YOLOv11 nano 模型
            task: YOLOTask.detect,
            // 指定為物件偵測任務
            controller: controller,
            // 綁定控制器

            // 每一幀推論完成後的回呼函式
            onResult: (results) {
              setState(() {
                // 更新目前偵測到的物件列表
                currentResults = results;
              });
            },

            // 效能資訊回呼（FPS、推論時間）
            onPerformanceMetrics: (metrics) {
              print('FPS: ${metrics.fps.toStringAsFixed(1)}');
              print(
                'Processing time: ${metrics.processingTimeMs.toStringAsFixed(1)}ms',
              );
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
