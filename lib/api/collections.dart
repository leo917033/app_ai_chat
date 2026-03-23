import 'package:yolo_text/contants/index.dart';
import 'package:yolo_text/utils/DioRequest.dart';
import 'package:yolo_text/viewmodels/collections.dart';

import 'package:dio/dio.dart'; // 確保引入 Dio 以使用 FormData 和 MultipartFile
import 'dart:io';

//
Future<CollectionInfo> addCollectionAPI(Map<String, dynamic> data) async {
  // 1. 處理檔案：從 Map 中取出 File 並封裝為 FormData (Body)
  File file = data['file'];
  FormData formData = FormData.fromMap({
    "file": await MultipartFile.fromFile(
        file.path,
        filename: "collection_capture.png"
    ),
  });

  // 2. 呼叫新的 putWithParams：文字放在 queryParameters，檔案放在 data
  final res = await dioRequest.putWithParams(
    HttpConstants.COLLECTIONS_ADD,
    data: formData, // 這是 Body (multipart/form-data)
    queryParameters: { // 這是 FastAPI 所需的 Query 參數
      "target_en": data['target_en'],
      "target_zh": data['target_zh'],
      "capturedAt": data['capturedAt'],
    },
  );

  print("API 回傳給 addCollectionAPI() 的原始內容: $res");
  return CollectionInfo.fromJson(res['collectionInfo']);
}

// ------------------ 查詢用戶圖鑑 ------------------ #
Future<List<CollectionInfo>> getCollectionListAPI() async {
  // 呼叫後端 GET /collections/my
  final res = await dioRequest.get(HttpConstants.COLLECTIONS_MY);

  print("getCollectionListAPI() 回傳原始內容------------------------------------------------------------------------------------------------------------: $res");

  List<dynamic> dataList = res;

  // 將資料轉換為 CollectionInfo 物件列表
  return dataList.map((item) {
    // 這裡 item 是 CollectionResponse 結構，包含一個 collectionInfo 欄位
    return CollectionInfo.fromJson(item['collectionInfo']);
  }).toList();
}
