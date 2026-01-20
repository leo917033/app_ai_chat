//管理路由
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yolo_text/pages/Login/index.dart';
import 'package:yolo_text/pages/Main/index.dart';

//返回app根級組建
Widget getRootWidget() {
  return MaterialApp(
    //命名路由
    initialRoute: "/",
    routes: getRootRoutes(), //路由配置
  );
}

//返回App的路由配置
Map<String, Widget Function(BuildContext)> getRootRoutes() {
  return {
    "/":(context) =>MainPage(), //主頁路由
    "/longin": (context) =>LoginPage() //登入路由
  };
}
