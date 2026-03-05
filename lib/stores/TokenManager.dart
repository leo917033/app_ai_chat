import 'package:shared_preferences/shared_preferences.dart';
import 'package:yolo_text/contants/index.dart';

class TokenManager {
  //返回持久化對象的實例對象
  Future<SharedPreferences> _getInstence() {
    return SharedPreferences.getInstance();
  }

  String _token = "";

  //初始化Token
  init() async{
    //1.獲取持久化對象
    final prefs = await _getInstence();
    _token = prefs.getString(GlobalConstants.TOKEN_KEY) ?? ""; //從硬碟獲取token
  }

  //設置Token
    Future<void> setToken(String val) async {
    //1.獲取持久化對象
    final prefs = await _getInstence();
    prefs.setString(GlobalConstants.TOKEN_KEY, val); //儲存token 到持久化 硬碟
    _token = val; //更新token
    print("settoken: $_token");
  }

  //獲取Token
  getToken() {
    print("gettoken: $_token");
    return _token;
  }

  //移除Token
  Future<void> removeToken() async {
    //1.獲取持久化對象
    final prefs = await _getInstence();
    prefs.remove(GlobalConstants.TOKEN_KEY); //移除token 硬碟
    _token = ""; //更新token 內存
  }
}

final tokenmanager = TokenManager();
