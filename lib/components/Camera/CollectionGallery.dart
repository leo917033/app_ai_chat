import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:yolo_text/api/collections.dart';
import 'package:yolo_text/contants/index.dart';
import 'package:yolo_text/stores/CollectionManager.dart';
import 'package:yolo_text/stores/UserController.dart';
import 'package:yolo_text/utils/ToastUtils.dart';
import 'package:yolo_text/viewmodels/collections.dart'; // 需要在 pubspec.yaml 加入 intl 套件處理時間格式

class CollectionGallery extends StatefulWidget {
  const CollectionGallery({super.key});

  @override
  State<CollectionGallery> createState() => _CollectionGalleryPageState();
}

class _CollectionGalleryPageState extends State<CollectionGallery> {
  // 存放已解鎖的資料，Key 為英文名 (id)，Value 為 CollectionItem 物件
  Map<String, CollectionItem> collectedData = {};
  bool isLoading = true; //判別圖鑑資料是否載入完成

  // 圖鑑所有的目標清單
  final List<Map<String, String>> allItems = [
    {"en": "person", "zh": "人"},
    {"en": "car", "zh": "汽車"},
    {"en": "bird", "zh": "鳥"},
    {"en": "cat", "zh": "貓"},
    {"en": "dog", "zh": "狗"},
    {"en": "banana", "zh": "香蕉"},
    {"en": "apple", "zh": "蘋果"},
    {"en": "carrot", "zh": "胡蘿蔔"},
    {"en": "cake", "zh": "蛋糕"},
    {"en": "chair", "zh": "椅子"},
    {"en": "bed", "zh": "床"},
    {"en": "dining table", "zh": "餐桌"},
    {"en": "tv", "zh": "電視"},
    {"en": "keyboard", "zh": "鍵盤"},
    {"en": "cell phone", "zh": "手機"},
    {"en": "backpack", "zh": "背包"},
    {"en": "umbrella", "zh": "雨傘"},
    {"en": "bottle", "zh": "瓶子"},
    {"en": "cup", "zh": "杯子"},
    {"en": "book", "zh": "書"},
    {"en": "clock", "zh": "時鐘"},
    {"en": "vase", "zh": "花瓶"},
    {"en": "scissors", "zh": "剪刀"},
  ];

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  // 讀取儲存的資料 ， 先讀本地，再嘗試從後端同步
  Future<void> _loadCollections() async {
    try {
      // 1. 獲取 UserController
      final UserController userController = Get.find<UserController>();

      // 2. 判斷是否登入 (根據您的 UserInfo id 判斷)
      final String userId = userController.user.value.id.toString();
      if (userId == "null" || userId.isEmpty || userId == "0") {
        // 未登入：直接設為空數據並停止加載
        if (mounted) {
          setState(() {
            collectedData = {};
            isLoading = false;
          });
        }
        return;
      }

      // 3. 已登入：從管理器獲取該帳號專屬的 CollectionItem
      // CollectionManager 內部會自動處理 _getAccountKey()
      List<CollectionItem> savedItems = await collectionManager
          .getAllCollections();

      // 4. 轉換為 Map
      Map<String, CollectionItem> tempMap = {};
      for (var item in savedItems) {
        tempMap[item.id] = item;
      }

      if (!mounted) return;
      setState(() {
        collectedData = tempMap;
        isLoading = false;
      });
      // 2. 獲取後端資料 (同步雲端紀錄)
      // 假設您的 API 是 getCollectionListAPI()
      try {
        // 2. 請求雲端 (獲取最新同步)
        List<CollectionInfo> cloudItems = await getCollectionListAPI();

        // 將雲端資料合併進 tempMap
        for (var cloud in cloudItems) {
          // 使用 GlobalConstants.BASE_URL 拼接完整網址
          final String fullImageUrl = "${GlobalConstants.BASE_URL}${cloud.imageUrl}";
          //print("########################################### $fullImageUrl");
          if (!tempMap.containsKey(cloud.targetEn)) {
            tempMap[cloud.targetEn] = CollectionItem(
              id: cloud.targetEn,
              imagePath: fullImageUrl, // 存入完整網址
              dateTime: cloud.capturedAt,
              label: cloud.targetZh,
            );
          }
        }
        // 更新 UI
        if (mounted) {
          setState(() {
            collectedData = Map.from(tempMap);
            isLoading = false;
          });
        }
      } catch (apiError) {
        print("雲端獲取失敗，僅顯示本地資料: $apiError");
        ToastUtils.showToast(context, "雲端獲取失敗，僅顯示本地資料");
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("載入圖鑑失敗: $e");
      ToastUtils.showToast(context, "載入圖鑑失敗");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "蒐藏圖鑑",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      // 使用 Obx 監聽登入狀態變化
      body: Obx(() {

        return isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 一列顯示兩個
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8, // 調整卡片比例
                  ),
                  itemCount: allItems.length,
                  itemBuilder: (context, index) {
                    final item = allItems[index];
                    final isUnlocked = collectedData.containsKey(item['en']);
                    // 從 Map 中取出 CollectionItem 物件
                    final CollectionItem? detail = collectedData[item['en']];

                    return _buildCollectionCard(
                      item['zh']!,
                      item['en']!,
                      isUnlocked,
                      // 修改這裡：直接存取物件屬性
                      isUnlocked ? detail?.imagePath : null,
                      isUnlocked ? detail?.dateTime : null,
                    );
                  },
                ),
              );
      }),
    );
  }

  // 圖鑑顯示格
  Widget _buildCollectionCard(
    String zhName,
    String enName,
    bool isUnlocked,
    String? imagePath,
    String? time,
  ) {
    // 安全解析日期，防止格式錯誤導致崩潰
    String formattedDate = "尚未捕獲";
    if (isUnlocked && time != null && time.isNotEmpty) {
      try {
        formattedDate = DateFormat(
          'yyyy-MM-dd HH:mm',
        ).format(DateTime.parse(time));
      } catch (e) {
        formattedDate = "日期格式錯誤";
      }
    }
    return GestureDetector(
      onTap: () {
        if (isUnlocked && imagePath != null) {
          _showFullImage(context, imagePath, zhName);
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // 背景圖片或鎖頭
            Positioned.fill(
              child: isUnlocked && imagePath != null
                  ? (imagePath.startsWith('http')
                  ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                // 加入此 Header 繞過 ngrok 警告頁面
                headers: const {'ngrok-skip-browser-warning': 'true'},
                errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
              )
                  : Image.file(File(imagePath), fit: BoxFit.cover))
                  : Container(
                color: Colors.grey[300],
                child: Icon(Icons.lock, size: 50, color: Colors.grey[600]),
              ),
            ),

            // 底部半透明遮罩顯示名稱
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10,
                ),
                color: Colors.black54,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      zhName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isUnlocked && time != null)
                      Text(
                        isUnlocked ? formattedDate : "未解鎖",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 如果未解鎖，顯示一個半透明灰色覆蓋層
            if (!isUnlocked)
              Positioned.fill(child: Container(color: Colors.black12)),
          ],
        ),
      ),
    );
  }

  // 放大預覽方法
  void _showFullImage(BuildContext context, String imagePath, String title) {
    showDialog(
      context: context,
      // barrierDismissible: true, // 點擊背景可關閉
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent, // 背景透明
        insetPadding: EdgeInsets.zero, // 全螢幕顯示
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 使用 InteractiveViewer 支援手勢縮放
            InteractiveViewer(
              panEnabled: true, // 支援平移
              minScale: 0.5,
              maxScale: 4.0,
              child: imagePath.startsWith('http')
                  ? Image.network(
                imagePath,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.contain,
                headers: const {'ngrok-skip-browser-warning': 'true'},
              )
                  : Image.file(
                File(imagePath),
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.contain,
              ),
            ),
            // 頂部顯示標題與關閉按鈕
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // 底部提示
            const Positioned(
              bottom: 40,
              child: Text(
                "可以使用雙指縮放圖片",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
