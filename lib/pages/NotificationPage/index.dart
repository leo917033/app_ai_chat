import 'package:flutter/material.dart';
import 'package:yolo_text/utils/ToastUtils.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // 1. 將數據移入 State，並增加 isRead (已讀) 與 isExpanded (展開) 狀態
  final List<Map<String, dynamic>> _notifications = [
    {
      "title": "歡迎使用 YOLO AI Chat",
      "content": "感謝您註冊我們的服務！現在就開始與 AI 對話吧。這裡有非常多有趣的功能等著你探索，包括多種 AI 角色切換以及自定義主題背景。",
      "time": "2024-03-20 10:00",
      "isRead": false,
      "isExpanded": false,
    },
    {
      "title": "系統更新通知",
      "content": "版本 v1.0.2 已發佈，優化了介面響應速度，並修復了部分機型在切換頭像時可能產生的內存溢出問題。建議所有用戶立即更新以獲得最佳體驗。",
      "time": "2024-03-18 15:30",
      "isRead": false,
      "isExpanded": false,
    },
  ];

  // 全部標記為已讀的功能
  void _markAllAsRead() {
    setState(() {
      for (var item in _notifications) {
        item['isRead'] = true;
      }
    });
    ToastUtils.showToast(context, '所有通知已標記為已讀');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知中心'),
        centerTitle: true,
        actions: [
          if (_notifications.any((item) => !item['isRead'])) // 只要有未讀才顯示
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      AlertDialog(
                        title: const Text('標記已讀'),
                        content: const Text('是否將所有通知標記為已讀？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('取消', style: TextStyle(
                                color: Colors.black87)),
                          ),
                          TextButton(
                            onPressed: () {
                              _markAllAsRead();
                              Navigator.pop(context);
                            },
                            child: const Text('確定', style: TextStyle(
                                color: Colors.blue)),
                          ),
                        ],
                      ),
                );
              },
              child: const Text(
                  "全部已讀", style: TextStyle(color: Colors.blue)),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildNotificationCard(_notifications[index]);
        },
      ),
    );
  }

  // 修改後的通知卡片：點擊可展開並標記已讀
  Widget _buildNotificationCard(Map<String, dynamic> item) {
    bool isExpanded = item['isExpanded'];
    bool isRead = item['isRead'];

    return GestureDetector(
      onTap: () {
        setState(() {
          item['isExpanded'] = !isExpanded; // 切換展開/收起
          item['isRead'] = true; // 點擊即標記為已讀
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        // 展開時的平滑動畫
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFF0F7FF), // 未讀時背景稍微帶藍
          borderRadius: BorderRadius.circular(12),
          border: isRead ? null : Border.all(
              color: Colors.blue.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 未讀小紅點
                if (!isRead)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Text(
                    item['title']!,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  item['time']!,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 內容部分：根據 isExpanded 決定顯示行數
            Text(
              item['content']!,
              maxLines: isExpanded ? null : 2, // 收起時最多顯示兩行
              overflow: isExpanded ? TextOverflow.visible : TextOverflow
                  .ellipsis,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.5,
                fontSize: 14,
              ),
            ),
            if (!isExpanded && item['content']!.length > 30) // 提示還有更多
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                    Icons.keyboard_arrow_down, size: 20, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80,
              color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("目前沒有任何通知", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}