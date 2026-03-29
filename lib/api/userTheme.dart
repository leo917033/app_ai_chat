import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:yolo_text/contants/index.dart';
import 'package:yolo_text/utils/DioRequest.dart';
import 'package:yolo_text/viewmodels/userTheme.dart';

//更新用戶主題
Future<UsetThemeInfo> updateUserThemeAPI(Map<String, dynamic> data) async {
  // 1. 建立一個統一的 Map 用於存儲 FormData 的內容
  Map<String, dynamic> queryParams = {
    // 放入文字欄位（例如 bg_type, user_id 等）
    "bgType": data['bg_type'],
    "bgValue": data['bg_value'],
    "avatarPath": data['avatar_path'],
  };

  // 2. 建立 Form 資料 (僅放入檔案)
  Map<String, dynamic> fileMap = {};

  // 處理頭像檔案
  if (data['avatar_file'] != null && data['avatar_file'] is File) {
    File avatarFile = data['avatar_file'];
    fileMap["avatar_file"] = await MultipartFile.fromFile(
      avatarFile.path,
      filename: avatarFile.path.split('/').last,
    );
  }

  // 處理背景檔案
  if (data['bg_file'] != null && data['bg_file'] is File) {
    File bgFile = data['bg_file'];
    fileMap["bg_file"] = await MultipartFile.fromFile(
      bgFile.path,
      filename: bgFile.path.split('/').last,
    );
  }

  // fileMap 封裝成 FormData
  //FormData formData = FormData.fromMap(fileMap);

  try {
    // 3. 呼叫 putWithParams
    // 關鍵：queryParams 放在 URL，formData 放在 Body
    final res = await dioRequest.putWithParams(
      HttpConstants.USER_THEME_UPDATE,
      queryParameters: queryParams, // 這裡放文字欄位
      data: fileMap.isNotEmpty
          ? FormData.fromMap(fileMap)
          : null, // 這裡放檔案，若無檔案則傳 null
    );

    return UsetThemeInfo.fromJson(res);
  } on DioException catch (e) {
    // 打印詳細回應，這能幫你看到後端 422 具體報錯內容
    print("Dio Error Status: ${e.response?.statusCode}");
    print("Dio Error Detail: ${e.response?.data}");
    rethrow;
  }
}

//查詢用戶主題
Future<UsetThemeInfo> getUsetThemeAPI() async {
  final res = await dioRequest.get(HttpConstants.USER_THEME_MY);
  print("getUsetThemeAPI() 回傳原始內容: $res");

  return UsetThemeInfo.fromJson(res);
}
