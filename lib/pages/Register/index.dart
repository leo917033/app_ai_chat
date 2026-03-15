import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:yolo_text/api/user.dart'; // 假設您之後會建立 registerAPI
import 'package:yolo_text/utils/LoadingDialog.dart';
import '../../utils/ToastUtils.dart';
import '../ProtocolPage/ProtocolPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController(); // 確定密碼

  bool _isAgreed = false;
  bool _isObscure = true; // 控制密碼
  bool _isObscureConfirm = true; // 控制確認密碼

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("註冊"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView( // 加入滾動視圖防止鍵盤遮擋
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 38),
                _buildUsernameTextField(),
                const SizedBox(height: 20),
                _buildPasswordTextField(),
                const SizedBox(height: 20),
                _buildConfirmPasswordTextField(), // 確定密碼輸入框
                const SizedBox(height: 20),
                _buildCheckbox(),
                const SizedBox(height: 30),
                _buildRegisterButton(), // 註冊按鈕
              ],
            ),
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
          "加入我們",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
            "請填寫以下資訊完成帳號註冊", style: TextStyle(color: Colors.grey)),
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
      obscureText: _isObscure,
      decoration: InputDecoration(
        labelText: "設定密碼",
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
        suffixIcon: IconButton(
          icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
          onPressed: (){
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),
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

  // 4. 確定密碼輸入框 (新增)
  Widget _buildConfirmPasswordTextField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _isObscureConfirm,
      decoration: InputDecoration(
        labelText: "確認密碼",
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
        suffixIcon: IconButton(
          icon: Icon(_isObscureConfirm ? Icons.visibility_off : Icons.visibility),
          onPressed: (){
            setState(() {
              _isObscureConfirm = !_isObscureConfirm;
            });
          }),
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
        if (value == null || value.isEmpty) return '請再次輸入密碼';
        if (value != _passwordController.text) {
          return '兩次輸入的密碼不一致';
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

  // 6. 註冊按鈕
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (_isAgreed) {
              _handleRegister(); //處理註冊邏輯
            }
            else{
              ToastUtils.showToast(context, "請勾選並同意用戶協議");
              return;
            }

          }
        },
        child: const Text("立即註冊", style: TextStyle(fontSize: 18)),
      ),
    );
  }

  // 處理註冊邏輯
  _handleRegister() async {
    try{
      LoadingDialog.show(context, message: "拼命註冊中");
      final res= await requiredAPI({
        "username": _usernameController.text,
        "password": _passwordController.text,
      });
      LoadingDialog.hide(context);
      ToastUtils.showToast(context, "註冊成功，請重新登入");
      // 延遲一下下再關閉頁面，確保用戶看見 Toast
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pop(context);
      });
    } catch(e){
      LoadingDialog.hide(context);
      ToastUtils.showToast(context, (e as DioException).message);

    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}