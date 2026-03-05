class GlobalConstants {
  static const String BASE_URL = "http://10.0.2.2:8000"; //基礎地址"https://meikou-api.itheima.net"
  static const int TIME_OUT = 10; //超時時間
  static const String SUCCESS_CODE = "200"; //成功狀態
  static const String TOKEN_KEY = "ai_chat_token"; //token對應持久化的key
}

class HttpConstants{
  static const String LOGIN = "/api/user/login"; //登入
  static const String REGISTER = "/api/user/register"; //註冊
  static const String USER_INFO = "/api/user/info"; //用戶信息
}