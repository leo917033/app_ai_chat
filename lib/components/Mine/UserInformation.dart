import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:yolo_text/stores/UserController.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({super.key});

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {

  //Getx 的 Controller 注入 .find
  final UserController _userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Colors.blue, // 建議使用你的主題色 Theme.of(context).primaryColor
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      // 使用 Obx 監聽 user 的變化
      child: Obx(() {
        // 獲取當前使用者資訊
        var user = _userController.user.value;
        //print("目前 UI 偵測到的用戶名: ${user.username}");
        // 判斷是否登入：根據你的模型，如果 id 或 token 為空字串則視為未登入
        bool isLogin = user.id.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                'https://via.placeholder.com/150', // 這裡未來可以放 user.avatar
              ),
            ),
            const SizedBox(height: 15),

            // 顯示使用者名稱或「未登入」
            Text(
              isLogin ? user.username : '未登入',
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            // 顯示 UID
            Text(
              isLogin ? 'UID: ${(int.tryParse(user.id) ?? 0) + 24300000}' : 'UID: -',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        );
      }),
    );
  }
}
