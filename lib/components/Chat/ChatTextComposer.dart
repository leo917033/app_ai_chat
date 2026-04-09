// lib/pages/Chat/index.dart

import 'package:flutter/material.dart';
import 'package:yolo_text/api/aiChat.dart';
import 'package:yolo_text/stores/AudioManager.dart';
import 'package:yolo_text/stores/ChatMessageManager.dart';
import 'package:yolo_text/viewmodels/aiChat.dart';
import '../../viewmodels/chat.dart';

// --- Widget 區 ---

/// `ChatView` 是主要的聊天頁面 Widget。
/// 它是一個 `StatefulWidget`，因為頁面上的訊息列表會隨著使用者互動而改變。
class ChatTextComposer extends StatefulWidget {
  // 使用 const 建構函式可以提高性能，因為 Flutter 可以快取這個不變的 Widget。
  const ChatTextComposer({super.key}); // 確保建構子支援 key

  @override
  // 建立與這個 Widget 關聯的 State 物件。
  State<ChatTextComposer> createState() => ChatTextComposerState();
}

/// `_ChatViewState` 是 `ChatView` 的 State 物件。
/// 所有會變動的資料 (例如訊息列表) 和與使用者互動的邏輯都寫在這裡。
class ChatTextComposerState extends State<ChatTextComposer> {
  // `TextEditingController` 用於讀取和控制 TextField (文字輸入框) 的內容。
  final TextEditingController _textController = TextEditingController();

  // `ScrollController` 用於控制 ListView 的滾動行為，例如在發送新訊息後自動滾動到底部。
  final ScrollController _scrollController = ScrollController();

  // `_messages` 是一個 `ChatMessage` 物件的列表，用來儲存聊天室的所有訊息。
  // 這裡我們加入了一些初始的假資料，以便在畫面上直接看到效果。
  final List<ChatMessage> _messages = [];

  // 儲存 sessionId
  int? _currentSessionId;

  @override
  void initState() {
    super.initState();
    // 在頁面加載時獲取歷史紀錄和s
    // 使用 addPostFrameCallback 確保在首幀渲染後才執行邏輯
    // 這樣可以避免 _scrollToBottom 執行時找不到 ScrollController 的問題
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. 先嘗試從本地加載持久化資料 (假設我們預設載入一個 sessionId，或者由外部傳入)
      // 如果目前沒有 sessionId，可以先預設為 0 或從上次紀錄中讀取
      await _loadPersistedMessages();

      // 2. 隨後同步 API 歷史紀錄
      _getHistory();
    });
  }

  // --- 核心邏輯方法區 ---

  /// 處理訊息提交的函式。
  /// 當使用者點擊發送按鈕或在鍵盤上按下確認時會被呼叫。
  /// [text] 參數是從文字輸入框傳入的內容。
  void _handleSubmitted(String text) async {
    // 清除文字輸入框的內容，為下一條訊息做準備。
    _textController.clear();
    // 使用 trim() 去除頭尾的空白，如果訊息為空，則不做任何事。
    if (text.trim().isEmpty) return;

    // `setState` 是 `StatefulWidget` 的核心方法。
    // 呼叫它會通知 Flutter 框架，State 中的某些資料已經改變，需要重新執行 `build` 方法來更新畫面。
    setState(() {
      // 建立一個新的 ChatMessage 物件，並將其加入到訊息列表中。
      _messages.add(
        ChatMessage(
          text: text,
          isSentByMe: true, // 假設使用者自己發送的訊息
          timestamp: DateTime.now(), // 使用當前時間作為時間戳記
        ),
      );
    });

    // 持久化儲存
    if (_currentSessionId != null) {
      chatMessageManager.saveMessages(_currentSessionId!, _messages);
    }
    // 滾動到最新訊息處
    _scrollToBottom();

    _handleTextChange(text);
  }

  ///使用者輸入文字傳到後端
  void _handleTextChange(String text) async {

    print("ttttttttttttttttttttttt$_currentSessionId");

    // 將訊息傳送到後端伺服器
    AiChatMessage res = await aiChatAPI({
      "sessionId": _currentSessionId,
      "message": text,
      "ttsLanguage": "zh",
    });
    // 更新 UI
    setState(() {
      // 建立一個新的 ChatMessage 物件，並將其加入到訊息列表中。
      _messages.add(
        ChatMessage(
          text: res.responseMessage,
          isSentByMe: false,
          timestamp: DateTime.now(), // 使用當前時間作為時間戳記
          ttsUrl: res.ttsAudioUrl,
        ),
      );
    });

    // 持久化儲存
    if (_currentSessionId != null) {
      chatMessageManager.saveMessages(_currentSessionId!, _messages);
    }

    AudioManager.playVoice(res.ttsAudioUrl);

    // 5. 滾動到最新訊息處
    _scrollToBottom();
  }

  /// 從本地 Manager 加載訊息
  Future<void> _loadPersistedMessages() async {
    // 假設我們在沒有 SessionId 時先檢查有沒有通用快取，或等到有 SessionId 再讀取
    if (_currentSessionId != null) {
      final localMsgs = await chatMessageManager.getMessages(
        _currentSessionId!,
      );
      if (localMsgs.isNotEmpty) {
        setState(() {
          _messages.clear();
          _messages.addAll(localMsgs);
        });
        _scrollToBottom();
      }
    }
  }

  /// 取得歷史聊天紀錄
  Future<void> _getHistory() async {
    try {
      // 1. 調用 API 取得歷史 Map (格式為 { "sessionId": [歷史訊息列表] })
      Map<String, List<AiChatHistory>> historyData = await aiChatHistoryAPI();
      //print("歷史紀錄: $historyData");
      if (historyData.isEmpty) return;

      // 臨時儲存解析後的 UI 訊息
      List<ChatMessage> tempMessages = [];
      int? lastSessionId;

      // 2. 迭代 Map，將所有 Session 的訊息摊平（或者你可以根據需求只取最後一個 Session）
      historyData.forEach((sessionId, messages) {
        // 更新最後看到的 sessionId
        lastSessionId = int.tryParse(sessionId);

        for (var m in messages) {
          tempMessages.add(
            ChatMessage(
              text: m.content, // 使用 AiChatHistory 中的 content
              isSentByMe: m.role == "user", // 判斷是否為使用者發送
              timestamp: m.timestamp ?? DateTime.now(),
              ttsUrl: m.ttsUrl,
            ),
          );
          print("ttsurl: ${m.ttsUrl}");
        }
      });

      // 3. 排序訊息（確保時間早的在上面，如果後端 API 沒排好序的話）
      tempMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // 4. 更新 UI 狀態
      setState(() {
        _messages.clear();
        _messages.addAll(tempMessages);
        _currentSessionId = lastSessionId; // 儲存最後一個 sessionId，以便後續對話連貫
      });

      // API 同步後，更新本地快取
      if (_currentSessionId != null) {
        chatMessageManager.saveMessages(_currentSessionId!, _messages);
      }

      // 5. 滾動到最新訊息處
      _scrollToBottom();
    } catch (e) {
      debugPrint("獲取歷史紀錄失敗: $e");
    }
  }

  //滾動到最新訊息處
  void _scrollToBottom() {
    // 在 UI 更新後，自動將列表滾動到底部，以顯示最新的訊息。
    // 使用 `Future.delayed` 確保滾動操作在 ListView 更新完成後執行。
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent, // 滾動到最底部
        duration: const Duration(milliseconds: 300), // 動畫持續時間
        curve: Curves.easeOut, // 動畫曲線，先快後慢
      );
    });
  }

  /// 供外部呼叫的清除方法
  void clearHistory() async {
    if (_currentSessionId == null) return;

    final int sessionIdToDelete = _currentSessionId!;

    try {
      // 停止目前的聲音播放
      await AudioManager.stopAll();
      // 1. 串接遠端刪除 API (優先執行，確保伺服器端先清理)
      // 這會刪除資料庫紀錄與伺服器上的實體音檔
      bool apiSuccess = await aiChatDeleteHistoryAPI(sessionIdToDelete);

      if (apiSuccess) {
        // 2. 清除本地訊息持久化資料 (SharedPreferences)
        await chatMessageManager.clearChatHistory(sessionIdToDelete);

        // 3. 清除手機本地快取的 TTS 音檔 (.mp3 檔案)
        await AudioManager.clearAllCachedVoices();

        // 4. 更新 UI 狀態
        setState(() {
          _messages.clear();
        });

        debugPrint("ChatTextComposer: 雲端與本地歷史紀錄已完全清除");
      } else {
        debugPrint("ChatTextComposer: API 刪除失敗，取消本地清理流程");
      }
    } catch (e) {
      debugPrint("ChatTextComposer: 清除歷史紀錄時發生錯誤: $e");
    }
  }

  // --- UI 構建方法區 ---

  /// 建立底部的訊息輸入框區域。
  Widget _buildTextComposer() {
    return Container(
      // 設定上下左右的內邊距。
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      // 設定容器的裝飾，例如背景色和邊框。
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // 使用當前主題的卡片顏色作為背景色
        border: Border(top: BorderSide(color: Colors.grey[200]!)), // 在頂部加上一條細線
      ),
      child: Row(
        // Row 讓我們可以水平排列多個子 Widget。
        children: <Widget>[
          // `Flexible` 讓 TextField 可以填滿 Row 中剩餘的可用空間。
          Flexible(
            child: TextField(
              controller: _textController, // 綁定控制器
              onSubmitted: _handleSubmitted, // 設定鍵盤 "提交" 按鈕的處理函式
              // 設定輸入框的裝飾，`InputDecoration.collapsed` 是一種極簡風格。
              decoration: const InputDecoration.collapsed(
                hintText: '輸入訊息...', // 提示文字
              ),
            ),
          ),
          // 發送按鈕
          IconButton(
            icon: const Icon(Icons.send), // 使用 Material Design 的發送圖示
            // 按下按鈕時，呼叫 `_handleSubmitted` 並傳入當前輸入框的文字。
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }

  /// 根據單一的 `ChatMessage` 物件建立對應的訊息氣泡 Widget。
  Widget _buildMessageItem(ChatMessage message) {
    // 根據訊息是否由自己發送，決定對齊方式。
    final align = message.isSentByMe
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    // 根據訊息是否由自己發送，決定氣泡顏色。
    final color = message.isSentByMe ? Colors.white : Colors.blue[200];
    // 根據訊息是否由自己發送，message.isSentByMe。
    final textColor = Colors.black;

    // 使用 Container 作為訊息的外部容器，設定外邊距。
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        // `Column` 讓我們可以垂直排列氣泡和時間戳記。
        // `crossAxisAlignment` 控制子元件在交叉軸（水平方向）上的對齊。
        crossAxisAlignment: align,
        children: [
          // 訊息氣泡本身
          // 使用 ConstrainedBox 來限制最大寬度
          ConstrainedBox(
            constraints: BoxConstraints(
              // 限制氣泡最大寬度為螢幕寬度的 75%
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 15.0,
              ),
              decoration: BoxDecoration(
                color: color, // 設定背景色
                borderRadius: BorderRadius.circular(12.0), // 設定圓角
                // 為氣泡加上淡淡的陰影增加質感
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 1. 訊息文字
                  Flexible(
                    child: Text(
                      message.text,
                      style: TextStyle(color: textColor),
                    ),
                  ),
                  // 2. 如果有 TTS URL，顯示播放按鈕
                  // 使用 ...[] 語法來在 if 條件下插入多個 Widget
                  if (message.ttsUrl != null && message.ttsUrl!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => AudioManager.playVoice(message.ttsUrl!),
                      // 呼叫播放方法
                      child: const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // 氣泡和時間之間的小間距
          const SizedBox(height: 2.0),
          // 顯示時間的文字
          Text(
            // 簡單的時間格式化，例如 "14:05"。
            // `padLeft(2, '0')` 用於確保分鐘數總是兩位數（例如，將 "5" 變成 "05"）。
            '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12.0,
            ), // 設定時間的樣式
          ),
        ],
      ),
    );
  }

  /// `build` 方法是 Flutter 中最重要的函式之一。
  /// 它描述了 Widget 在畫面上應該如何顯示，當 State 改變時會被重新執行。
  @override
  Widget build(BuildContext context) {
    // `Column` 作為頁面的主佈局，將訊息列表和輸入框垂直排列。
    return Column(
      children: <Widget>[
        // `Expanded` 會讓其子 Widget (這裡的 ListView) 填滿 Column 中剩餘的所有垂直空間。
        Expanded(
          child: Column(
            children: [
              // 2. 使用另一個 Expanded 作為空白區域，並設定 flex 權重。
              //    這讓空白區域佔據所有可用空間的 3/4。
              Expanded(
                flex: 4,
                child: Container(), // <- 空白區域的空間
              ),

              // 1. 使用 Expanded 包裹 ListView，並設定 flex 權重。
              //    這讓 ListView 佔據所有可用空間的 1/4。
              Expanded(
                flex: 3, // <- ListView 的空間權重
                child: ListView.builder(
                  controller: _scrollController,
                  //列表自動滾動到最底部。
                  padding: const EdgeInsets.all(8.0),
                  //內邊距
                  reverse: false,
                  //列表從上到下排列
                  itemCount: _messages.length,
                  //告知 ListView 總共有多少個項目需要被建立。
                  // `itemBuilder` 函式會被呼叫來渲染所有項目，只渲染畫面上可見的那些。
                  itemBuilder: (BuildContext context, int index) {
                    return _buildMessageItem(_messages[index]);
                  },
                ),
              ),
            ],
          ),
        ),

        // 在列表和輸入框之間畫一條分隔線。
        const Divider(height: 1.0),
        // 將訊息輸入框 Widget 放在底部。
        _buildTextComposer(),
      ],
    );
  }

  /// 在 Widget 被銷毀時會呼叫 `dispose` 方法。
  /// 我們需要在此處釋放不再使用的控制器，以防止記憶體洩漏。
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
