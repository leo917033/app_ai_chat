import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
          icon: Icons.settings,
          title: '帳號設定',
          onTap: () {
            // 導航到設定頁面
            print("點擊了帳號設定");
          },
        ),
        _buildMenuItem(
          icon: Icons.notifications,
          title: '通知中心',
          onTap: () {
            // 導航到通知中心
            print("點擊了通知中心");
          },
        ),
        _buildMenuItem(
          icon: Icons.privacy_tip,
          title: '隱私權政策',
          onTap: () {
            // 顯示隱私權政策
            print("點擊了隱私權政策");
          },
        ),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: '關於我們',
          onTap: () {
            // 顯示關於我們頁面
            print("點擊了關於我們");
          },
        ),
      ],
    );
  }
}
