import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:yolo_text/api/user.dart';
import 'package:yolo_text/pages/Camera/index.dart';
import 'package:yolo_text/pages/Chat/index.dart';
import 'package:yolo_text/pages/Mine/index.dart';
import 'package:yolo_text/stores/TokenManager.dart';
import 'package:yolo_text/stores/UserController.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //定義數據 渲染三個導航
  final List<Map<String, String>> _tabList = [
    {
      "icon": "lib/assets/BottomNavigationBar/camera_normal.png",
      "active_icon": "lib/assets/BottomNavigationBar/camera_active.png",
      "text": "cc",
    },
    {
      "icon": "lib/assets/BottomNavigationBar/comment_normal.png",
      "active_icon": "lib/assets/BottomNavigationBar/comment_active.png",
      "text": "聊天",
    },
    {
      "icon": "lib/assets/BottomNavigationBar/user_normal.png",
      "active_icon": "lib/assets/BottomNavigationBar/user_active.png",
      "text": "我的",
    },
  ];

  int _currentIndex = 0;

  //把List<Map<String, String>>轉換成List<BottomNavigationBarItem>
  List<BottomNavigationBarItem> _getTabBarWidget() {
    return List.generate(_tabList.length, (int index) {
      return BottomNavigationBarItem(
        icon: Image.asset(_tabList[index]["icon"]!, width: 24, height: 24),
        activeIcon: Image.asset(
          _tabList[index]["active_icon"]!,
          width: 24,
          height: 24,
        ),
        label: _tabList[index]["text"],
      );
    });
  }

  List<Widget> _getChildern() {
    return [CameraView(), ChatView(), MineView()];
  }

  @override
  void initState() {
    super.initState();

    //初始化用戶
    _initUser();
  }

  final UserController _userController = Get.find<UserController>();

  _initUser() async {
    await tokenmanager.init(); //初始化token
    if (tokenmanager.getToken().isNotEmpty) {
      // 如果有Token就獲取UserInfo
      _userController.updataUserInfo(await getUserInfoAPI());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //SafeArea避開安全區
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _getChildern()),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        items: _getTabBarWidget(),
        currentIndex: _currentIndex,
        onTap: (int index) {
          _currentIndex = index;
          setState(() {});
        },
      ),
    );
  }
}
