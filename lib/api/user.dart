//登入接口api

import 'package:yolo_text/contants/index.dart';
import 'package:yolo_text/utils/DioRequest.dart';
import 'package:yolo_text/viewmodels/user.dart';

Future<UserInfo> loginAPI(Map<String, dynamic> data) async {
  final res = await dioRequest.post(HttpConstants.LOGIN, data: data);
  print("API 回傳給 fromJson 的原始內容: $res");
  return UserInfo.fromJson(res);
}

Future<UserInfo> requiredAPI(Map<String, dynamic> data) async {
  return UserInfo.fromJson(
    await dioRequest.post(HttpConstants.REGISTER, data: data),
  );
}

Future<UserInfo> getUserInfoAPI() async {
  final res = await dioRequest.get(HttpConstants.USER_INFO);
  print("API 回傳給 getUserInfoAPI() 的原始內容: $res");
  return UserInfo.fromJson(res);
}
