//登入接口api

import 'package:yolo_text/contants/index.dart';
import 'package:yolo_text/utils/DioRequest.dart';
import 'package:yolo_text/viewmodels/user.dart';

Future<UserInfo> loginAPI(Map<String,dynamic> data) async{
  return UserInfo.fromJson(
    await dioRequest.post(HttpConstants.LOGIN,data: data)
  );
}