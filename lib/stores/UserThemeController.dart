import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'UserThemeManager.dart';

class UserThemeController extends GetxController {
  // 響應式變數
  var bgType = 'color'.obs; // 'color', 'asset', 'file'
  var bgValue = '0xFF2196F3'.obs; // 顏色 Hex 字串或圖片路徑

  var avatarPath = 'lib/assets/mine_img/av1.png'.obs; // 頭像路徑

  @override
  void onInit() {
    super.onInit();
    loadThemeSettings(); // 初始化時從持久化層載入
  }

  // 1. 載入設定
  Future<void> loadThemeSettings() async {
    final settings = await UserThemeManager.getBackgroundSettings();
    bgType.value = settings['type']!;
    bgValue.value = settings['value']!;
    avatarPath.value = settings['avatarPath']!;
  }

  // 2. 更新背景 (顏色、預設圖、上傳圖)
  Future<void> updateBackground(String type, String value) async {
    bgType.value = type;
    bgValue.value = value;
    await UserThemeManager.saveBackground(type, value);
  }

  //2. 更新頭像
  Future<void> updateAvatar(String path) async {
    avatarPath.value = path;
    await UserThemeManager.saveAvatar(path);
  }

  // 輔助方法：獲取當前背景的裝飾圖片 (用於 UI)
  DecorationImage? getDecorationImage() {
    if (bgType.value == 'color') return null;

    if (bgType.value == 'file') {
      return DecorationImage(
        image: FileImage(File(bgValue.value)),
        fit: BoxFit.cover,
      );
    }
    if (bgType.value == 'asset') {
      return DecorationImage(
        image: AssetImage(bgValue.value),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  // 輔助方法：獲取當前背景顏色
  Color getBackgroundColor(BuildContext context) {
    if (bgType.value == 'color') {
      return Color(int.parse(bgValue.value));
    }
    // 如果是圖片模式，返回透明或主色作為底色
    return Theme.of(context).primaryColor;
  }

  // 輔助方法： 獲取當前頭像
  ImageProvider getAvatarImage() {
    final path = avatarPath.value;

    // 1. 判斷是否為資源路徑 (Asset)
    if (path.startsWith('lib/') || path.startsWith('assets/')) {
      return AssetImage(path);
    }

    // 2. 判斷是否為本地檔案路徑 (File)
    if (File(path).existsSync()) {
      return FileImage(File(path));
    }

    // 3. 備選方案：如果路徑無效，回傳預設圖
    return const AssetImage('lib/assets/mine_img/av1.png');
  }
}
