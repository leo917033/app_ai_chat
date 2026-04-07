import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yolo_text/components/Bottom/image_state_button.dart';
import 'package:yolo_text/stores/TokenManager.dart';
import 'package:yolo_text/stores/UserController.dart';
import 'package:yolo_text/viewmodels/user.dart';

class Userlogout extends StatefulWidget {
  const Userlogout({super.key});

  @override
  State<Userlogout> createState() => _UserlogoutState();
}

class _UserlogoutState extends State<Userlogout> {
  final UserController _userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: SizedBox(
        width: double.infinity,
        child: ImageStateButton(
          text: "登出",
          isRed: true,
          onTap: () {
            // 處理退出登入邏輯
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('確認退出登入'),
                  content: const Text('確定要退出登入嗎？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('取消'),
                    ),
                    TextButton(
                      onPressed: () async {
                        //清除Getx 刪除token
                        await tokenmanager.removeToken();
                        _userController.updataUserInfo(UserInfo.fromJson({}));
                        Navigator.pop(context);
                      },
                      child: Text('確定'),
                    ),
                  ],
                );
              },
            );
          },
          height: 100.0,
        ),
      ),
    );
  }
}
