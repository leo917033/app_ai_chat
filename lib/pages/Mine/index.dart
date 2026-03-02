import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:yolo_text/components/Mine/UserInformation.dart';
import 'package:yolo_text/components/Mine/UserList.dart';
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
        // 如果 id 不為空，代表已登入，顯示「登入」按鈕
        if (_userController.user.value.id.isNotEmpty) {
          return const SizedBox.shrink();
        } else {
          // 如果未登入，這裡可以回傳空，或者顯示一個「去登入」的按鈕
          // 原本這裡如果是放登出按鈕，現在可以視需求移除或替換
          return Userlogout();
        }
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: _getChildern());
  }
}
