import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yolo_text/components/Bottom/image_state_button.dart';

class Userlogin extends StatefulWidget {
  const Userlogin({super.key});

  @override
  State<Userlogin> createState() => _UserloginState();
}

class _UserloginState extends State<Userlogin> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: SizedBox(
        width: double.infinity,
        child: ImageStateButton(
          text: "登入(註冊)",
          onTap: () => Navigator.pushNamed(context, "/longin"),
          height: 100.0,
        ),
      ),
    );
  }
} //
