import 'package:flutter/material.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();
  bool showPass = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo tài khoản')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              hintText: 'Họ và tên',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Email',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passCtrl,
            obscureText: !showPass,
            decoration: InputDecoration(
              hintText: 'Mật khẩu',
              suffixIcon: IconButton(
                icon: Icon(showPass ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => showPass = !showPass),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: pass2Ctrl,
            obscureText: !showPass,
            decoration: InputDecoration(
              hintText: 'Nhập lại mật khẩu',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Đăng ký',
            onPressed: () {
              if (passCtrl.text != pass2Ctrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mật khẩu nhập lại không khớp')),
                );
                return;
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
