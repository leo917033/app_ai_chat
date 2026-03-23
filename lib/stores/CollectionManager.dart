import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yolo_text/stores/UserController.dart';

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

  static const String _BASE_KEY = "user_collections";

  // 取得當前帳號專屬的 Key
  Future<String> _getAccountKey() async {
    // 1. 透過 Get.find 獲取 UserController
    final UserController _userController = Get.find<UserController>();

    // 2. 獲取 ID，注意：根據您的 UserInfo 定義，若 id 為 null 代表未登入
    final String userId = _userController.user.value.id;
    // 如果 id 不為空且不是 "0"，代表已登入，返回使用者專屬 Key
    if (userId != "null" && userId.isNotEmpty && userId != "0") {
      return "${_BASE_KEY}_$userId";
    }

    // 否則返回遊客模式 Key
    return "${_BASE_KEY}_guest";
  }

  // 儲存新的捕獲紀錄
  Future<void> saveCapture(CollectionItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = await _getAccountKey();

    List<String> list = prefs.getStringList(key) ?? [];
    list.add(jsonEncode(item.toJson()));
    await prefs.setStringList(key, list);
  }

  // 獲取目前帳號的圖鑑紀錄
  Future<List<CollectionItem>> getAllCollections() async {
    final prefs = await SharedPreferences.getInstance();
    final String key = await _getAccountKey();

    // 若為遊客且您不想顯示任何圖鑑，可直接回傳空清單
    if (key.endsWith("_guest")) return [];

    List<String> list = prefs.getStringList(key) ?? [];
    return list
        .map((item) => CollectionItem.fromJson(jsonDecode(item)))
        .toList();
  }
}

final collectionManager = CollectionManager();