import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:yolo_text/components/Mine/UserInformation.dart';
import 'package:yolo_text/components/Mine/UserList.dart';
import 'package:yolo_text/components/Mine/UserLogin.dart';
import 'package:yolo_text/components/Mine/UserLogout.dart';
import 'package:yolo_text/stores/UserController.dart';

class MineView extends StatefulWidget {
  const MineView({super.key});

  @override
  State<MineView> createState() => _MineViewState();
}

class _MineViewState extends State<MineView> {
  //獲取全域的 UserController 實例
  final UserController _userController = Get.find<UserController>();

  List<Widget> _getChildern() {
    return [
      UserInformation(),
      const SizedBox(height: 20),
      UserList(),
      const Spacer(), // <--- 關鍵元件：佔用所有剩餘的垂直空間
      //根據登入狀態決定顯示什麼
      Obx(() {
        // 如果 id 不為空，代表已登入，顯示「登出」按鈕
        if (_userController.user.value.id.isNotEmpty) {

          return Userlogout();
        } else {
          // 如果未登入顯示一個「登入」的按鈕
          return Userlogin();
        }
      }),

    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: _getChildern());
  }
}
