import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yolo_text/api/user.dart'; // 導入剛寫的 API
import 'package:yolo_text/utils/LoadingDialog.dart';
import 'package:yolo_text/utils/ToastUtils.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isObscureOld = true; // 控制目前密碼
  bool _isObscureNew = true; // 控制新密碼
  bool _isObscureConfirm = true; // 控制確認新密碼

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("修改密碼"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(30),
          color: Colors.white,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              _buildPasswordField(
                controller: _oldPasswordController,
                label: "目前密碼",
                hint: "請輸入目前使用的密碼",
                isObscure: _isObscureOld,
                // 傳入變數
                onToggle: () =>
                    setState(() => _isObscureOld = !_isObscureOld), // 傳入切換函式
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _newPasswordController,
                label: "新密碼",
                hint: "請輸入 6-16 位英數新密碼",
                isObscure: _isObscureNew,
                onToggle: () => setState(() => _isObscureNew = !_isObscureNew),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: "確認新密碼",
                hint: "請再次輸入新密碼",
                isConfirm: true,
                isObscure: _isObscureConfirm,
                onToggle: () =>
                    setState(() => _isObscureConfirm = !_isObscureConfirm),
              ),
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "修改密碼",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text("請輸入舊密碼與新密碼以完成修改", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isObscure, // 新增：目前是否隱藏
    required VoidCallback onToggle, // 新增：切換回調
    bool isConfirm = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure, // 使用傳入的狀態
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 18, color: Colors.blue),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.black87),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
          // 使用傳入的狀態
          onPressed: onToggle, // 執行傳入的切換邏輯
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
        if (value == null || value.isEmpty) return '$label不能為空';
        if (!RegExp(r'^[a-zA-Z0-9]{6,16}$').hasMatch(value))
          return '格式為6-16位英數';
        if (controller == _newPasswordController &&
            value == _oldPasswordController.text) {
          return '新密碼不能與目前密碼相同';
        }
        if (isConfirm && value != _newPasswordController.text)
          return '兩次密碼輸入不一致';
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
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
          if (_formKey.currentState!.validate()) {
            _handleSubmit();
          }
        },
        child: const Text("確認修改", style: TextStyle(fontSize: 18)),
      ),
    );
  }

  // 修改密碼核心邏輯
  _handleSubmit() async {
    try {
      LoadingDialog.show(context, message: "正在修改中...");

      // 1. 發送請求：這會傳遞包含兩個 String 的 Map
      await changePasswordAPI({
        "oldPassword": _oldPasswordController.text, // 確定是 String
        "newPassword": _newPasswordController.text, // 確定是 String
      });

      LoadingDialog.hide(context);
      ToastUtils.showToast(context, "修改成功");

      // 2. 成功後延遲返回，讓用戶看清 Toast
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      LoadingDialog.hide(context);

      // 這裡與 LoginPage 的錯誤處理邏輯保持一致
      if (e is DioException) {
        // 如果後端有回傳錯誤訊息，DioRequest 通常會將其放在 e.message 中
        ToastUtils.showToast(context, e.message ?? "修改失敗，請稍後再試");
      } else {
        ToastUtils.showToast(context, "發生未知錯誤");
      }
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
