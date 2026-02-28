import 'package:flutter/cupertino.dart';
import 'package:yolo_text/components/Mine/UserInformation.dart';
import 'package:yolo_text/components/Mine/UserList.dart';
import 'package:yolo_text/components/Mine/UserLogout.dart';

class MineView extends StatefulWidget {
  const MineView({super.key});

  @override
  State<MineView> createState() => _MineViewState();
}

class _MineViewState extends State<MineView> {
  List<Widget> _getChildern() {
    return [
      UserInformation(),
      const SizedBox(height: 20),
      UserList(),
      const Spacer(), // <--- 關鍵元件：佔用所有剩餘的垂直空間
      Userlogout(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: _getChildern());
  }
}
