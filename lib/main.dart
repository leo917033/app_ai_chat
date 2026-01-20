import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/yolo.dart'; // 匯入 Ultralytics YOLO 套件
import 'package:image_picker/image_picker.dart'; // 匯入圖片選擇器套件，用於從相簿或相機選擇圖片
import 'dart:io';

import 'package:yolo_text/yolo_view/CameraDetectionScreen.dart'; // 匯入 dart:io 以使用 File 類別

void main() => runApp(MainPage());

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: YOLODemo());

  }
}


class YOLODemo extends StatefulWidget {
  @override
  _YOLODemoState createState() => _YOLODemoState();
}

// YOLODemo Widget 的狀態管理類別
class _YOLODemoState extends State<YOLODemo> {
  YOLO? yolo; // YOLO 模型的實例
  File? selectedImage; // 用戶從相簿選擇的圖片檔案
  List<dynamic> results = []; // 儲存偵測結果的列表
  bool isLoading = false; // 用於追蹤模型是否正在載入或處理中，以顯示載入指示器

  // 當 widget 第一次被建立時會呼叫此方法
  @override
  void initState() {
    super.initState();
    loadYOLO(); // 開始載入 YOLO 模型
  }

  // 異步載入 YOLO 模型
  Future<void> loadYOLO() async {
    setState(() => isLoading = true); // 開始載入，設定 isLoading 為 true 以顯示進度環

    // 初始化 YOLO 物件，指定模型路徑和任務類型
    yolo = YOLO(
      modelPath: 'yolo11n', // 指定要使用的 YOLO 模型，'yolo11n' 可能是內建或預設模型的名稱
      task: YOLOTask.detect, // 指定任務為物件偵測
    );

    await yolo!.loadModel(); // 等待模型載入完成
    setState(() => isLoading = false); // 模型載入完成，設定 isLoading 為 false
  }

  // 挑選圖片並執行物件偵測
  Future<void> pickAndDetect() async {
    final picker = ImagePicker(); // 建立 ImagePicker 實例
    // 讓使用者從圖片庫挑選一張圖片
    final image = await picker.pickImage(source: ImageSource.gallery);

    // 如果使用者成功選擇了一張圖片
    if (image != null) {
      // 更新 UI 狀態以顯示選擇的圖片和載入指示器
      setState(() {
        selectedImage = File(image.path); // 將選擇的圖片路徑轉換成 File 物件
        isLoading = true; // 開始處理，設定為載入中
      });

      // 將圖片檔案讀取為位元組數據
      final imageBytes = await selectedImage!.readAsBytes();
      // 使用 YOLO 模型對圖片位元組進行預測
      final detectionResults = await yolo!.predict(imageBytes);

      // 更新 UI 狀態以顯示偵測結果
      setState(() {
        // 從回傳結果中提取 'boxes' 列表，如果為 null 則使用空列表
        results = detectionResults['boxes'] ?? [];
        isLoading = false; // 處理完成，隱藏載入指示器
      });
    }
  }

  // 建立 widget 的使用者介面
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(title: Text('YOLO Quick Demo')), // 應用程式頂部的標題列
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 主軸置中對齊
            children: [
              // 如果有選擇圖片，就顯示它
              if (selectedImage != null)
                Container(
                  height: 300, // 設定圖片容器的高度
                  child: Image.file(selectedImage!), // 顯示檔案中的圖片
                ),

              SizedBox(height: 20),

              if (isLoading) // 如果正在載入中，顯示一個圓形的進度指示器
                CircularProgressIndicator()
              else // 否則，顯示偵測到的物件數量
                Text('Detected ${results.length} objects'),

              SizedBox(height: 20),

              // 一個按鈕，用於觸發圖片選擇和偵測功能
              ElevatedButton(
                // 只有在 YOLO 模型載入完成後 (yolo != null) 才啟用按鈕
                onPressed: yolo != null ? pickAndDetect : null,
                child: Text('Pick Image & Detect'),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                // 只有在 YOLO 模型載入完成後 (yolo != null) 才啟用按鈕
                onPressed: yolo != null
                    ? () {
                        // 使用 Navigator.push 來導航到新的畫面
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraDetectionScreen(),
                          ),
                        );
                      }
                    : null,
                child: Text('Live Camera Detection'),
              ),

              SizedBox(height: 20),

              // 顯示偵測結果的列表
              Expanded(
                child: ListView.builder(
                  itemCount: results.length, // 列表項目的數量等於偵測結果的數量
                  itemBuilder: (context, index) {
                    final detection = results[index]; // 獲取單一偵測結果
                    // 為每個偵測結果建立一個 ListTile
                    return ListTile(
                      // 顯示偵測到的物件類別，如果沒有則顯示 'Unknown'
                      title: Text(detection['class'] ?? 'Unknown'),
                      // 顯示該偵測的信賴度，並格式化為百分比
                      subtitle: Text(
                        'Confidence: ${(detection['confidence'] * 100).toStringAsFixed(1)}%',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
  }
}
