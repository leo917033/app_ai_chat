class GlobalConstants {
  static const String BASE_URL = "https://nonprofanely-untuneful-alessandro.ngrok-free.dev"; //http://192.168.0.4:8000 10.0.2.2
  static const int TIME_OUT = 10; //超時時間
  static const String SUCCESS_CODE = "200"; //成功狀態
  static const String TOKEN_KEY = "ai_chat_token"; //token對應持久化的key
}

class HttpConstants{
  //用戶api
  static const String LOGIN = "/api/user/login"; //登入
  static const String REGISTER = "/api/user/register"; //註冊
  static const String USER_INFO = "/api/user/info"; //用戶信息
  static const String CHANGE_PASSWORD = "/api/user/password"; //修改密碼

  //圖鑑api
  static const String COLLECTIONS_ADD = "/api/collections/add"; //添加圖鑑"
  static const String COLLECTIONS_MY = "/api/collections/my"; //查詢用戶圖鑑

  //用戶我的頁面api
  static const String USER_THEME_UPDATE = "/api/user-themes/update"; //用戶主題更新
  static const String USER_THEME_MY = "/api/user-themes/my"; //用戶主題查詢
}