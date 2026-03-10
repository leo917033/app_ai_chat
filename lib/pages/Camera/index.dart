import 'package:flutter/material.dart';
import 'package:yolo_text/pages/ProtocolPage/ProtocolPage.dart';
import 'dart:math'; // 引入隨機數工具
import '../../yolo_view/CameraDetectionScreen.dart';

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
      appBar: AppBar(
        title: const Text('YOLO 物件偵測任務'),
        centerTitle: true,
        leading: _isSelectionMode
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _isSelectionMode = false),
        )
            : null,
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSelectionMode
              ? _buildSelectionView()
              : _buildMainMenuView(),
        ),
      ),
    );
  }

  // --- 1. 初始選單畫面 ---
  Widget _buildMainMenuView() {
    return Column(
      key: const ValueKey('MainMenuView'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.camera_enhance, size: 80, color: Colors.blue),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            textStyle: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: _pickRandomTarget, // 點擊開始時隨機抽取
          child: const Text('開始任務'),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)),
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
              '任務說明', style: TextStyle(color: Colors.grey, fontSize: 18)),
        ),
      ],
    );
  }

  // --- 2. 物品確認畫面 ---
  Widget _buildSelectionView() {
    return Padding(
      key: const ValueKey('SelectionView'),
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '您的任務目標：',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 15),
              Text(
                "$_selectedChinese ($_selectedEnglish)", // 顯示中文與英文
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _isSelectionMode = false),
                    child: const Text('返回', style: TextStyle(fontSize: 16)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      // 傳入英文標籤供 YOLO 比對，傳入中文名稱供 UI 顯示
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CameraDetectionScreen(
                                targetEnglish: _selectedEnglish,
                                targetChinese: _selectedChinese,
                              ),
                        ),
                      );
                    },
                    child: const Text(
                        '前往找尋', style: TextStyle(fontSize: 18)),
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