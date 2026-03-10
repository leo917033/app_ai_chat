import 'dart:io'; // 必須導入以處理 FileImage
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:yolo_text/stores/UserController.dart';
import 'package:yolo_text/stores/UserThemeController.dart';

import 'package:image_picker/image_picker.dart'; // 此套件用於選取圖片

class UserInformation extends StatefulWidget {
  const UserInformation({super.key});

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  // Getx Controller 注入
  final UserController _userController = Get.find<UserController>();

  // 注入主題 Controller
  final UserThemeController _themeController = Get.put(UserThemeController());

  @override
  Widget build(BuildContext context) {
    // 將 Obx 放在最外層，這樣背景變化時 Container 才會重新構建
    return Obx(() {
      // 1. 獲取用戶資料與登入狀態
      var user = _userController.user.value;
      bool isLogin = user.id.isNotEmpty;

      // 2. 準備背景裝飾 (圖片或顏色)
      DecorationImage? backgroundImage;
      Color backgroundColor = Theme.of(context).primaryColor; // 預設底色

      if (_themeController.bgType.value == 'color') {
        // 如果是顏色模式，解析 Hex 字串
        backgroundColor = Color(int.parse(_themeController.bgValue.value));
      } else {
        // 如果是圖片模式 (file 或 asset)
        backgroundImage = _themeController.getDecorationImage();
      }

      return GestureDetector(
          onTap: () {
            if (!isLogin) {
              // 如果未登入，跳轉到登入頁面
              Get.toNamed('/login');
            } else {
              // 如果已登入，彈出更換背景的選單
              _showBackgroundOptions(context);
            }
          },
          child:Container(
        width: double.infinity,
        // 使用裝飾器處理背景與圓角
        decoration: BoxDecoration(
          color: backgroundColor,
          image: backgroundImage,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
            child: SafeArea(
              bottom: false,
              child: Container(
                // 設定一個固定高度或最小高度，確保背景有足夠空間顯示
                constraints: const BoxConstraints(minHeight: 220),
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end, // <--- 關鍵：將子組件推向底部
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150',
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLogin ? user.username : '未登入',
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(blurRadius: 2, color: Colors.black45)],
                              ),
                            ),
                            Text(
                              isLogin
                                  ? 'UID: ${(int.tryParse(user.id) ?? 0) + 24300000}'
                                  : 'UID: *************',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                shadows: [Shadow(blurRadius: 2, color: Colors.black45)],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      );
    });
  }
  // 建立一個彈窗方法來處理點擊事件
  void _showBackgroundOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            // --- 背景設定區塊 ---
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("背景設定", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ListTile(
              leading: const Icon(Icons.color_lens, color: Colors.blue),
              title: const Text('更換背景顏色'),
              onTap: () {
                Navigator.pop(context);
                _showColorPickerDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.orange),
              title: const Text('從預設圖片中挑選背景'),
              onTap: () {
                Navigator.pop(context);
                _showDefaultImagePicker(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.green),
              title: const Text('從相簿選擇背景圖片'),
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  _themeController.updateBackground('file', image.path);
                }
                Navigator.pop(context);
              },
            ),

            const Divider(), // 分割線

            // --- 頭像設定區塊 ---
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("頭像設定", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ListTile(
              leading: const Icon(Icons.face, color: Colors.purple),
              title: const Text('從預設圖片中挑選頭像'),
              onTap: () {
                Navigator.pop(context);
                _showDefaultAvatarPicker(context); // 下方新增此方法
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
              title: const Text('從相簿選擇新頭像'),
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  // TODO: 呼叫您的 UserController 更新頭像路徑
                  // _userController.updateAvatar(image.path);
                  print("選取頭像路徑: ${image.path}");
                }
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.restore, color: Colors.grey),
              title: const Text('恢復預設背景'),
              onTap: () {
                _themeController.updateBackground('color', '0xFF2196F3');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  // 3. 建立調色盤對話框方法
  void _showColorPickerDialog(BuildContext context) {
    // 取得目前顏色（如果不是顏色模式，預設藍色）
    Color currentColor = _themeController.bgType.value == 'color'
        ? Color(int.parse(_themeController.bgValue.value))
        : Theme.of(context).primaryColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('選擇背景顏色'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (Color color) {
              currentColor = color; // 當用戶在調色盤滑動時，更新臨時顏色變數
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('取消',style: TextStyle(color: Colors.black87),),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('確定',style: TextStyle(color: Colors.black87)),
            onPressed: () {
              // 將 Color 對象轉為 0xFFXXXXXX 格式的字串並儲存
              String colorString = '0x${currentColor.value.toRadixString(16).toUpperCase()}';
              _themeController.updateBackground('color', colorString);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
  // 顯示預設圖片選擇對話框
  void _showDefaultImagePicker(BuildContext context) {
    // 定義您的預設圖片路徑列表 (請確保這些路徑已加入 pubspec.yaml)
    final List<String> defaultImages = [
      'lib/assets/mine_img/bg1.png',
      'lib/assets/mine_img/bg2.png',
      'lib/assets/mine_img/bg3.png',

    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('挑選預設背景',style: TextStyle(color: Colors.black87)),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 一行顯示兩張
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 16 / 9, // 配合背景寬扁的特性
            ),
            itemCount: defaultImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // 更新背景為 asset 類型
                  _themeController.updateBackground('asset', defaultImages[index]);
                  Navigator.pop(context);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    defaultImages[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消',style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
  //預設頭像選擇器
  void _showDefaultAvatarPicker(BuildContext context) {
    final List<String> defaultAvatars = [
      'lib/assets/avatars/av1.png',
      'lib/assets/avatars/av2.png',
      'lib/assets/avatars/av3.png',
      'lib/assets/avatars/av4.png',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('挑選預設頭像', style: TextStyle(color: Colors.black87)),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 頭像比較小，一行顯示三個
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: defaultAvatars.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // TODO: 更新頭像邏輯
                  // _userController.updateAvatar(defaultAvatars[index]);
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  backgroundImage: AssetImage(defaultAvatars[index]),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
