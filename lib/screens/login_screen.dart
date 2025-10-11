import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/primary_button.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl  = TextEditingController();
  bool showPass = false;
  bool loading  = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = emailCtrl.text.trim();
    final pass  = passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email và mật khẩu')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      // authStateChanges() trong main.dart sẽ tự điều hướng sang HomeScreen
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = _mapFirebaseError(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại.')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':       return 'Email không hợp lệ';
      case 'user-disabled':       return 'Tài khoản đã bị vô hiệu hoá';
      case 'user-not-found':      return 'Không tìm thấy tài khoản';
      case 'wrong-password':      return 'Mật khẩu không đúng';
      case 'too-many-requests':   return 'Thử lại sau ít phút (quá nhiều lần thử)';
      default:                    return e.message ?? 'Đăng nhập thất bại';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text('Đăng nhập'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.task_alt_rounded, size: 72, color: Colors.blueAccent),
              const SizedBox(height: 8),
              const Text(
                'Chào mừng trở lại 👋',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 32),

              // Email
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined),
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Mật khẩu
              TextField(
                controller: passCtrl,
                obscureText: !showPass,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
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

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                    );
                  },
                  child: const Text('Quên mật khẩu?', style: TextStyle(color: Colors.blueAccent)),
                ),
              ),
              const SizedBox(height: 4),

              // Nút đăng nhập (bọc callback async trong lambda)
              PrimaryButton(
                label: loading ? 'Đang đăng nhập...' : 'Đăng nhập',
                onPressed: loading ? null : () async { await _signIn(); },
              ),

              const SizedBox(height: 16),

              // Tạo tài khoản
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chưa có tài khoản?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Tạo tài khoản', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
