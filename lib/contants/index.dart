class GlobalConstants {
  static const String BASE_URL = "https://nonprofanely-untuneful-alessandro.ngrok-free.dev"; //http://192.168.0.4:8000 10.0.2.2
  static const int TIME_OUT = 10; //超時時間
  static const String SUCCESS_CODE = "200"; //成功狀態
  static const String TOKEN_KEY = "ai_chat_token"; //token對應持久化的key
}

class HttpConstants{
  static const String LOGIN = "/api/user/login"; //登入
  static const String REGISTER = "/api/user/register"; //註冊
  static const String USER_INFO = "/api/user/info"; //用戶信息
  static const String CHANGE_PASSWORD = "/api/user/password"; //修改密碼
}