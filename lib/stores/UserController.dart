import 'package:get/get.dart';
import 'package:yolo_text/viewmodels/user.dart';

// 需要共享的對象 進行狀態管理 並讓多個頁面共享這些數據
class UserController extends GetxController{
  var user = UserInfo.fromJson({}).obs;//.obs將其變成響應式對象
  //想要取值的話 要 User.value
  updataUserInfo(UserInfo newUserInfo){
    //print("正在更新用戶資訊: ${newUserInfo.username}"); // 調試用
    user.value = newUserInfo;
  }
}
