import 'package:flutter/material.dart';

/*
// 使用藍色按鈕
ImageStateButton(
  text: "登入遊戲",
  onTap: () => print("Login clicked"),
),
ImageStateButton(
  text: "取消註冊",
  isRed: true,
  width: 150,
  onTap: () => Navigator.pop(context),
),
*/

class ImageStateButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isRed; // true 用紅色系列, false 用藍色系列
  final double width;
  final double height;
  final double fontSize;

  const ImageStateButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isRed = false,
    this.width = 180,
    this.height = 55,
    this.fontSize = 18,
  });

  @override
  State<ImageStateButton> createState() => _ImageStateButtonState();
}

class _ImageStateButtonState extends State<ImageStateButton> {
  bool _isPressed = false;

  // 根據狀態和顏色決定圖片路徑 (對應你的 pubspec.yaml 設定)
  String _getAssetPath() {
    const String basePath = 'lib/assets/Bottom/';
    if (widget.isRed) {
      return _isPressed
          ? '${basePath}bottom_a_r.png' // 按下用 a
          : '${basePath}bottom_n_r.png'; // 常態用 n
    } else {
      return _isPressed
          ? '${basePath}bottom_a_b.png'
          : '${basePath}bottom_n_b.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 處理按下狀態切換
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_getAssetPath()),
            fit: BoxFit.fill, // 讓圖片填滿 Container
          ),
        ),
        alignment: Alignment.center,
        child: Stack(
          children: [
            // 1. 底層：黑色描邊文字
            Text(
              widget.text,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth =
                      3 // 邊框寬度
                  ..color = Colors.black, // 邊框顏色
              ),
            ),
            // 2. 頂層：白色填充文字
            Text(
              widget.text,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white, // 文字主體顏色
                shadows: const [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2.0,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
