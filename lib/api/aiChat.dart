

import 'package:yolo_text/contants/index.dart';
import 'package:yolo_text/stores/TokenManager.dart';
import 'package:yolo_text/utils/DioRequest.dart';
import 'package:yolo_text/viewmodels/aiChat.dart';


//取得ai返回訊息
Future<AiChatMessage> aiChatAPI(Map<String, dynamic> data) async {
  final res = await dioRequest.post(HttpConstants.AI_CHAT,data:data );
  print("API 回傳給aiChatAPI的原始內容: $res");
  return AiChatMessage.fromJson(res);
}

// 查詢 ai 聊天歷史和 session_id
Future<Map<String, List<AiChatHistory>>> aiChatHistoryAPI() async {
  try {
    // --- 新增：確保 Token 存在才發送 ---
    String token = tokenmanager.getToken();
    if (token.isEmpty) {
      print("aiChatHistoryAPI: Token 為空，等待 500ms 重試...");
      await Future.delayed(const Duration(milliseconds: 500));
      token = tokenmanager.getToken();
      if (token.isEmpty) {
        print("aiChatHistoryAPI: 依然沒有 Token，取消請求");
        return {};
      }
    }
    // --------------------------------

    print("開始取得歷史紀錄===========================================================");

    // 1. 調用 DioRequest
    final dynamic res = await dioRequest.get(HttpConstants.AI_CHAT_HISTORY);

    if (res == null) {
      print("aiChatHistoryAPI: 收到空的 API 回應");
      return {};
    }

    print("API 回傳給 aiChatHistoryAPI 的原始內容: $res");

    if (res is! Map<String, dynamic>) {
      print("API 返回格式錯誤：預期為 Map，實際為 ${res.runtimeType}");
      return {};
    }

    Map<String, List<AiChatHistory>> historyMap = {};

    res.forEach((sessionId, messages) {
      int? parsedId = int.tryParse(sessionId.toString());
      if (parsedId != null && messages is List) {
        historyMap[sessionId.toString()] = messages.map((item) {
          return AiChatHistory.fromJson(item as Map<String, dynamic>, parsedId);
        }).toList();
      }
    });

    print("成功解析後的歷史紀錄 Session 數量: ${historyMap.length}");
    return historyMap;

  } catch (e) {
    print("aiChatHistoryAPI 執行失敗: $e");
    return {};
  }
}


