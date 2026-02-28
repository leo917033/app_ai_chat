import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Userlogout extends StatefulWidget {
  const Userlogout({super.key});

  @override
  State<Userlogout> createState() => _UserlogoutState();
}

class _UserlogoutState extends State<Userlogout> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[400], // 按鈕顏色
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            // 處理退出登入邏輯
            Navigator.pushNamed(context, "/longin");
          },
          child: const Text(
            '登入',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}