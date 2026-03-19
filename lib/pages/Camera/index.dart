import 'package:flutter/material.dart';
import 'package:yolo_text/components/Camera/CameraDetectionScreen.dart';
import 'package:yolo_text/components/Camera/CollectionGallery.dart';
import 'package:yolo_text/pages/ProtocolPage/ProtocolPage.dart';
import 'dart:math'; // 引入隨機數工具

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  bool _isSelectionMode = false;

  // 定義物品對照表 (Key: 英文標籤, Value: 中文名稱)
  final Map<String, String> _targetPool = {
    "person": "人",
    "car": "汽車",
    "bird": "鳥",
    "cat": "貓",
    "dog": "狗",
    "banana": "香蕉",
    "apple": "蘋果",
    "carrot": "胡蘿蔔",
    "cake": "蛋糕",
    "chair": "椅子",
    "bed": "床",
    "dining table": "餐桌",
    "tv": "電視",
    "keyboard": "鍵盤",
    "cell phone": "手機",
    "backpack": "背包",
    "umbrella": "雨傘",
    "bottle": "瓶子",
    "cup": "杯子",
    "book": "書",
    "clock": "時鐘",
    "vase": "花瓶",
    "scissors": "剪刀",
  };

  // 當前選中的目標 (英文與中文)
  String _selectedEnglish = "";
  String _selectedChinese = "";

  // 隨機抽選物品的方法
  void _pickRandomTarget() {
    final keys = _targetPool.keys.toList();
    final randomKey = keys[Random().nextInt(keys.length)];
    setState(() {
      _selectedEnglish = randomKey;
      _selectedChinese = _targetPool[randomKey]!;
      _isSelectionMode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // 讓背景圖延伸到 AppBar 後方，視覺感更好
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 透明 AppBar
        elevation: 0,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => _isSelectionMode = false),
              )
            : null,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return Stack(
            children: [
              // 1. 底層背景圖
              Positioned.fill(
                child: _isSelectionMode
                    ? Image.asset(
                        'lib/assets/bu_img/c2.png', // 你的圖片
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'lib/assets/bu_img/c1.png', // 你的圖片
                        fit: BoxFit.cover,
                      ),
              ),

              // 2. 任務視窗 (透過 Align 或 Positioned 調整百分比)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isSelectionMode
                    ? Align(
                        // 使用 Alignment(x, y) 調整位置
                        // x: -1.0 是最左, 1.0 是最右
                        // y: -1.0 是最頂, 1.0 是最底
                        alignment: const Alignment(0.0, 0.5),
                        child: _buildSelectionView(screenWidth, screenHeight),
                      )
                    : Center(child: _buildMainMenuView()),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- 1. 初始選單畫面 ---
  Widget _buildMainMenuView() {
    return Align(
      alignment: Alignment.topRight, // 將內容對齊到右上角
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0, right: 30.0), // 距離頂部和右邊的間距
        child: Column(
          key: const ValueKey('MainMenuView'),
          mainAxisSize: MainAxisSize.min, // 讓高度縮到最小，Align 才會生效
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //const Icon(Icons.camera_enhance, size: 80, color: Colors.blue),
            const Text(
              '尋物偵探',
              style: TextStyle(
                fontSize: 30,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _pickRandomTarget, // 點擊開始時隨機抽取
              child: const Text('開始遊戲',style: TextStyle(fontSize: 20,color: Colors.blue)),
            ),
            const SizedBox(height: 20),
            //  任務說明
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProtocolPage(
                      title: "game_instructions",
                      assetPath: "lib/assets/html/game_instructions.html",
                    ),
                  ),
                );
              },
              child: const Text(
                '任務說明',
                style: TextStyle(color: Colors.black87, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            //蒐藏圖鑑
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.orangeAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                // 導航到圖鑑頁面
                Navigator.push(context, MaterialPageRoute(builder: (context) => CollectionGallery()));
              },
              icon: const Icon(Icons.collections_bookmark, color: Colors.white),
              label: const Text('我的蒐藏圖鑑', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. 物品確認畫面 ---
  Widget _buildSelectionView(double screenWidth, double screenHeight) {
    return Container(
      // 使用 ValueKey 讓 AnimatedSwitcher 辨識這是不同的元件，從而觸發切換動畫
      key: const ValueKey('SelectionView'),
      // 根據螢幕寬度動態調整卡片大小，例如佔據螢幕寬度的 70%
      width: screenWidth * 0.9,
      height: screenHeight * 0.35,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        // 圓角卡片
        child: Padding(
          padding: const EdgeInsets.all(20.0), // 卡片內部留白
          child: Column(
            //mainAxisSize: MainAxisSize.min, // 根據內容自動縮放垂直長度
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 標題文字
              const Text(
                '您的任務目標：',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 15),
              // 顯示抽中的物品名稱 (例如：手機 (cell phone))
              Text(
                "$_selectedChinese ($_selectedEnglish)",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 40),
              // 下方的操作按鈕列
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 「返回」按鈕：取消目前抽取結果，回到主選單
                  TextButton(
                    onPressed: () => setState(() => _isSelectionMode = false),
                    child: const Text('返回', style: TextStyle(fontSize: 16)),
                  ),
                  // 「前往找尋」按鈕：進入真正的 AI 相機偵測頁面
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // 按鈕背景色（綠色代表開始）
                      foregroundColor: Colors.white, // 文字顏色
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      // 導覽至相機偵測畫面 (CameraDetectionScreen)
                      // 同時傳遞英文標籤（用於 YOLO 比對）與中文名稱（用於畫面顯示）
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraDetectionScreen(
                            targetEnglish: _selectedEnglish,
                            targetChinese: _selectedChinese,
                          ),
                        ),
                      );
                    },
                    child: const Text('前往找尋', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
