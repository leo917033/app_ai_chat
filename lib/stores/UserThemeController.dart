import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yolo_text/api/userTheme.dart';
import 'package:yolo_text/contants/index.dart';
import 'UserThemeManager.dart';

class UserThemeController extends GetxController {
  // 響應式變數
  var bgType = 'color'.obs; // 'color', 'asset', 'file'
  var bgValue = '0xFF2196F3'.obs; // 顏色 Hex 字串或圖片路徑

  var avatarPath = 'lib/assets/mine_img/av1.png'.obs; // 頭像路徑

  @override
  void onInit() {
    super.onInit();
    // 步驟 A: 先從本地加載（速度快，避免白屏）
    loadThemeSettings().then((_) {
      // 步驟 B: 加載完本地後，異步從後端刷新（保證數據最新）
      fetchThemeFromServer();
    });
  }

  /// --- 從後端獲取主題設定並同步至本地 ---
  Future<void> fetchThemeFromServer() async {
    try {
      // 1. 調用 API 獲取遠端數據
      final dynamic res = await getUsetThemeAPI();

      if (res != null) {
        // 處理背景
        // 假設後端 bgType 為 'color' 或 'path'
        String remoteType = (res.bgType == 'color') ? 'color' : 'asset';
        String remoteBgValue = res.bgValue ?? '0xFF2196F3';

        // 判斷是否需要拼接：非顏色且不是 lib/ 開頭
        if (remoteType == 'asset' &&
            !remoteBgValue.startsWith('lib/') &&
            !remoteBgValue.startsWith('http')) {
          remoteBgValue = "${GlobalConstants.BASE_URL}$remoteBgValue";
        }

        // 處理頭像路徑拼接
        String remoteAvatar = res.avatarPath ?? 'lib/assets/mine_img/av1.png';
        if (!remoteAvatar.startsWith('lib/') &&
            !remoteAvatar.startsWith('http')) {
          remoteAvatar = "${GlobalConstants.BASE_URL}$remoteAvatar";
        }

        // 3. 更新 GetX 響應式變數 (觸發 UI 更新)
        bgType.value = remoteType;
        bgValue.value = remoteBgValue;
        avatarPath.value = remoteAvatar;

        // 4. 保存到本地 SharedPreferences
        await UserThemeManager.saveBackground(bgType.value, bgValue.value);
        await UserThemeManager.saveAvatar(avatarPath.value);

        debugPrint("主題同步成功: 背景=${bgValue.value}, 頭像=${avatarPath.value}");
      }
    } catch (e) {
      debugPrint("fetchThemeFromServer 失敗: $e");
    }
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
    bgType.value = type; //
    bgValue.value = value;
    // 先保存到本地 SharedPreferences (保證 UI 立即反應)
    await UserThemeManager.saveBackground(type, value);

    // 同步到後端
    await _syncThemeWithServer();
  }

  //2. 更新頭像
  Future<void> updateAvatar(String path) async {
    avatarPath.value = path;
    await UserThemeManager.saveAvatar(path);

    // 同步到後端
    await _syncThemeWithServer();
  }

  // 輔助方法：獲取當前背景的裝飾圖片 (用於 UI)
  DecorationImage? getDecorationImage() {
    if (bgType.value == 'color') return null; //

    final path = bgValue.value;

    // 1. 優先判斷是否為網路路徑 (http/https)
    if (path.startsWith('http')) {
      return DecorationImage(
        image: NetworkImage(path),
        fit: BoxFit.cover,
      );
    }

    // 2. 本地檔案路徑 (手機相簿上傳的 file)
    if (bgType.value == 'file') {
      //本地檔案路徑
      return DecorationImage(
        image: FileImage(File(bgValue.value)),
        fit: BoxFit.cover,
      );
    }

    // 3. 資源路徑 (lib/assets/...)
    if (bgType.value == 'asset') {
      //資源路徑
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

    // 1. 優先判斷是否為網路路徑 (來自伺服器拼接後的完整網址)
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }

    // 2. 判斷是否為資源路徑 (Asset)
    if (path.startsWith('lib/') || path.startsWith('assets/')) {
      return AssetImage(path);
    }

    // 3. 判斷是否為本地檔案路徑 (File)
    if (File(path).existsSync()) {
      return FileImage(File(path));
    }

    // 備選方案：如果以上皆非，回傳預設圖
    return const AssetImage('lib/assets/mine_img/av1.png');
  }

  /// --- 核心同步函數：將當前狀態同步至後端 ---
  Future<void> _syncThemeWithServer() async {
    try {
      // 1. 建立一個空的 Map，動態增加參數
      Map<String, dynamic> apiData = {};

      // 2. 處理背景類型 (對齊後端 Enum: color 或 path)
      String eType = (bgType.value == 'color') ? "color" : "path";
      apiData["bg_type"] = eType;

      // 3. 處理背景數值與檔案
      if (bgType.value == 'file') {
        // 如果是本地檔案：只傳檔案，不傳 bg_value 字串
        File file = File(bgValue.value);
        if (await file.exists()) {
          apiData['bg_file'] = file;
        }
      } else {
        // 如果是顏色或資源路徑 (asset)：傳送 bg_value 字串
        apiData["bg_value"] = bgValue.value;
      }

      // 4. 處理頭像
      bool isAvatarAsset =
          avatarPath.value.startsWith('lib/') ||
          avatarPath.value.startsWith('assets/');

      if (isAvatarAsset) {
        // 如果是內建資源路徑：傳送 avatar_path 字串
        apiData["avatar_path"] = avatarPath.value;
      } else {
        // 如果是本地檔案：只傳檔案，不傳 avatar_path 字串
        File file = File(avatarPath.value);
        if (await file.exists()) {
          apiData['avatar_file'] = file;
        }
      }

      print("同步前數據 (僅含必要欄位): $apiData");

      // 5. 呼叫 API 層
      final response = await updateUserThemeAPI(apiData);
      print("同步至後端成功: $response");
    } catch (e) {
      debugPrint("同步至後端失敗: $e");
    }
  }
}
