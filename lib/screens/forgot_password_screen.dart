// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import '../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Nhập email của bạn',
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Gửi liên kết đặt lại',
            onPressed: () {
              // TODO: gửi email reset password
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã gửi liên kết (giả lập)')),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
