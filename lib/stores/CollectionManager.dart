import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionItem {
  final String id; // 物品英文名 (如: cell phone)
  final String imagePath; // 本地圖片路徑
  final String dateTime; // 達成時間
  final String label; // 中文名稱

  CollectionItem({
    required this.id,
    required this.imagePath,
    required this.dateTime,
    required this.label,
  });

  // 轉為 JSON 格式方便存儲
  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'imagePath': imagePath,
        'dateTime': dateTime,
        'label': label,
      };

  // 從 JSON 轉回物件
  factory CollectionItem.fromJson(Map<String, dynamic> json) =>
      CollectionItem(
        id: json['id'],
        imagePath: json['imagePath'],
        dateTime: json['dateTime'],
        label: json['label'],
      );
}

class CollectionManager {
  static const String _COLLECTION_KEY = "user_collections";

  Future<SharedPreferences> _getInstance() {
    return SharedPreferences.getInstance();
  }

  // 儲存新的捕獲紀錄
  Future<void> saveCapture(CollectionItem item) async {
    final prefs = await _getInstance();
    // 獲取現有清單
    List<String> list = prefs.getStringList(_COLLECTION_KEY) ?? [];
    // 加入新資料
    list.add(jsonEncode(item.toJson()));
    // 存回持久化硬碟
    await prefs.setStringList(_COLLECTION_KEY, list);
  }

  // 獲取所有圖鑑紀錄
  Future<List<CollectionItem>> getAllCollections() async {
    final prefs = await _getInstance();
    List<String> list = prefs.getStringList(_COLLECTION_KEY) ?? [];
    return list
        .map((item) => CollectionItem.fromJson(jsonDecode(item)))
        .toList();
  }

  // 檢查某物品是否已解鎖 (用於圖鑑 UI 顯示鎖頭或彩色)
  Future<bool> isUnlocked(String id) async {
    final list = await getAllCollections();
    return list.any((item) => item.id == id);
  }
}

final collectionManager = CollectionManager();