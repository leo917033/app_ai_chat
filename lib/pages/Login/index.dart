import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:yolo_text/api/user.dart';
import 'package:yolo_text/stores/UserController.dart';

import '../../utils/DialogUtils.dart';
import '../../utils/ToastUtils.dart';
import '../ProtocolPage/ProtocolPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 1. 使用 GlobalKey 創建 key 綁定 Form 組件
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 使用者名稱與密碼的控制器
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isAgreed = false; // 勾選框狀態

  //Getx 的 Controller 注入 .find
  final UserController _userController = Get.find<UserController>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("登入"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(30),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 對齊左邊
            children: [
              const SizedBox(height: 20),
              _buildHeader(), // 標題
              const SizedBox(height: 38),
              _buildUsernameTextField(), // 使用者名稱
              const SizedBox(height: 20),
              _buildPasswordTextField(), // 密碼
              const SizedBox(height: 20),
              _buildCheckbox(), // 勾選框
              const SizedBox(height: 20),
              _buildLoginButton(), // 登入按鈕
              const SizedBox(height: 20),
              _buildRegisterButton(), // 註冊按鈕

            ],
          ),
        ),
      ),
    );
  }

  // 1. Header 部分
  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "歡迎登入",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        // 修正：修改提示文字
        Text("請輸入您的使用者名稱和密碼以開始使用", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  // 2. 使用者名稱輸入框
  Widget _buildUsernameTextField() {
    return TextFormField(
      controller: _usernameController, // 使用控制器
      // 使用者名稱通常使用 text 類型
      //keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        // 使用 InputDecoration ，功能 輸入框樣式
        labelText: "使用者名稱",
        labelStyle: TextStyle(
          fontSize: 18, // <--- 在這裡調整大小
          color: Colors.blue, // 也可以順便調整顏色
        ),
        hintText: "請輸入使用者名稱(英文大小寫或數字)",
        hintStyle: TextStyle(
          fontSize: 14, // <--- 提示文字通常會設小一點
          color: Colors.grey,
        ),
        prefixIcon: Icon(Icons.person_outline, color: Colors.black87),
        // 1. 平常還沒點擊時的線條顏色
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),

        // 2. 點擊輸入框（獲得焦點）時的線條顏色
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2), // 聚焦時變藍色且粗一點
        ),

        // 3. 驗證失敗（報錯）時的線條顏色
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),

        // 4. 驗證失敗且正點擊該框時的線條顏色
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
      validator: (value) {
        //validator作用 自動檢查使用者輸入的內容是否合法**，並在不合法時給出提示。
        if (value == null || value.isEmpty) {
          //value.isEmpty
          return '使用者名稱不能為空';
        }
        if (!RegExp(r'^[a-zA-Z0-9]{6,16}$').hasMatch(value)) {
          return '請輸入6到16位的英文大小寫或數字(不可有特殊字元)';
        }
        return null;
      },
    );
  }

  // 3. 密碼輸入框
  Widget _buildPasswordTextField() {
    return TextFormField(
      controller: _passwordController,
      // 修正：密碼使用 visiblePassword 或普通 text
      keyboardType: TextInputType.visiblePassword,
      // 重要：隱藏輸入內容
      obscureText: true,
      decoration: const InputDecoration(
        labelText: "密碼",
        labelStyle: TextStyle(
          fontSize: 18, // <--- 在這裡調整大小
          color: Colors.blue, // 也可以順便調整顏色
        ),
        hintText: "請輸入密碼",
        hintStyle: TextStyle(
          fontSize: 14, // <--- 提示文字通常會設小一點
          color: Colors.grey,
        ),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.black87),
        // 1. 平常還沒點擊時的線條顏色
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),

        // 2. 點擊輸入框（獲得焦點）時的線條顏色
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2), // 聚焦時變藍色且粗一點
        ),

        // 3. 驗證失敗（報錯）時的線條顏色
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),

        // 4. 驗證失敗且正點擊該框時的線條顏色
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '密碼不能為空';
        }
        if (!RegExp(r'^[a-zA-Z0-9]{6,16}$').hasMatch(value)) {
          return '請輸入6到16位的英文大小寫或數字(不可有特殊字元)';
        }
        return null;
      },
    );
  }

  // 4. 隱私協議勾選框
  Widget _buildCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isAgreed,
          activeColor: Colors.blueAccent,
          checkColor: Colors.white,
          onChanged: (bool? value) {
            setState(() {
              _isAgreed = value ?? false;
            });
          },
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: "我已閱讀並同意",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              children: [
                TextSpan(
                  text: "《用戶協議》",
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // 改為彈出小視窗
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProtocolPage(
                            title: "用戶協議",
                            assetPath: "lib/assets/html/user_agreement.html",
                          ),
                        ),
                      );
                    },
                ),
                const TextSpan(text: "與"),
                TextSpan(
                  text: "《隱私政策》",
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // 改為彈出小視窗
                      // 修正：也改為跳轉到 ProtocolPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProtocolPage(
                            title: "隱私政策",
                            assetPath: "lib/assets/html/privacy_policy.html",
                          ),
                        ),
                      );
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }



  // 5. 登入按鈕
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {//帳密符合

            if (_isAgreed) { // 檢查是否勾選了用戶協議
              _login(); // 執行登入邏輯
            }
            else{
              ToastUtils.showToast(context, "請勾選並同意用戶協議"); // 顯示 Toast
              return;
            }
          }
        },
        child: const Text("立即登入", style: TextStyle(fontSize: 18)),
      ),
    );
  }
  // 執行登入邏輯
  _login() async {

    try{
      final res= await loginAPI({
        "username": _usernameController.text,
        "password": _passwordController.text,
      });

      _userController.updataUserInfo(res); //更新Controller 為新的使用者資訊 res
      // 檢查解析後的數據
      //print("解析後的 Token: ${res.token}");
      //print("解析後的 Username: ${res.username}");
      //print("解析後的 ID: ${res.id}");
      //print("Controller 內當前狀態: ${_userController.user.value.username}");
      ToastUtils.showToast(context, "登入成功");
      // 延遲一下下再關閉頁面，確保用戶看見 Toast
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pop(context);
      });
    } catch(e){
      ToastUtils.showToast(context, (e as DioException).message);

    }
  }

  //6. 註冊按鈕
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.blueAccent), // 藍色邊框
          foregroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: () {
          // TODO: 跳轉到註冊頁面
          // Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
          Navigator.pushNamed(context, "/register");
        },
        child: const Text("還沒有帳號？立即註冊", style: TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  void dispose() {
    // 銷毀新的控制器
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

/*_formKey.currentState!.validate()
* 1. 分解指令•
* _formKey: 這是您在類別頂層定義的 GlobalKey<FormState>。它是連接「登入按鈕」與「Form 組件」的唯一橋樑。
* currentState: 透過這個 Key，我們可以獲取到 Form 組件目前的「狀態對象」（即 FormState）。•! (非空斷言): 因為 currentState 可能為 null（例如 Form 還沒渲染完成），這裡使用 ! 告訴編譯器：「我確定現在 Form 已經存在，請放心執行」。•
* validate(): 這是 FormState 提供的一個核心方法。
* validate() 的執行過程當這行程式碼被執行時（通常是在點擊按鈕後），它會按照以下順序動作：1.全面掃描：它會自動找到該 Form 下面所有的 TextFormField 組件。2.執行校驗：它會逐一執行每個 TextFormField 裡的 validator 函式。3.收集結果：•如果所有的 validator 都返回 null，則 validate() 會返回 true。•如果只要有一個 validator 返回了字串（報錯訊息），則 validate() 會返回 false。4.UI 反饋：如果結果是 false，它會自動通知那些報錯的輸入框，讓它們顯示紅色的錯誤文字。*/
