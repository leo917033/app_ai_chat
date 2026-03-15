import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yolo_text/pages/ChangePasswordPage/index.dart';
import 'package:yolo_text/pages/NotificationPage/index.dart';
import 'package:yolo_text/pages/ProtocolPage/ProtocolPage.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  // 2. 建立中間的功能列表項
  // 使用 ListTile 可以快速建立帶有圖示、文字和箭頭的標準列表項
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // Column 讓所有子元件垂直排列
      children: [
        // 第二部分：功能列表
        _buildMenuItem(
          icon: Icons.lock_reset,
          title: '修改密碼',
          onTap: () {
            // 導航到設定頁面
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChangePasswordPage(),
              ),
            );
          },
        ),

        _buildMenuItem(
          icon: Icons.notifications,
          title: '通知中心',
          onTap: () {
            // 導航到通知中心頁面
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.privacy_tip,
          title: '隱私權政策',
          onTap: () {
            // 顯示隱私權政策
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProtocolPage(
                  title: "隱私政策",
                  assetPath: "lib/assets/html/privacy_policy.html",
                  showDialog: true,
                ),
              ),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.description,
          title: '用戶協議',
          onTap: () {
            // 顯示用戶協議
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProtocolPage(
                  title: "用戶協議",
                  assetPath: "lib/assets/html/user_agreement.html",
                  showDialog: true,
                ),
              ),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: '關於我們',
          onTap: () {
            // 顯示關於我們頁面
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProtocolPage(
                  title: "關於我們",
                  assetPath: "lib/assets/html/about_us.html",
                  showDialog: true,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
