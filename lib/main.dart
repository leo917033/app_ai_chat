import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:yolo_text/routes/index.dart';
import 'package:yolo_text/stores/UserController.dart';

void main(List<String> args){
  // 2. 注入全域 Controller  Getx
  Get.put(UserController(), permanent: true); // permanent: true 確保切換頁面時不會被銷毀

  //runApp
  runApp(getRootWidget());
}