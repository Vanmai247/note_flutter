import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl  = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl  = TextEditingController();
  final pass2Ctrl = TextEditingController();

  bool showPass   = false;
  bool showPass2  = false;
  bool loading    = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name  = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final p1    = passCtrl.text.trim();
    final p2    = pass2Ctrl.text.trim();

    if (name.isEmpty || email.isEmpty || p1.isEmpty || p2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }
    if (p1 != p2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu nhập lại không khớp')),
      );
      return;
    }
    if (p1.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu tối thiểu 6 ký tự')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      // Tạo tài khoản Firebase Auth
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: p1);

      // Cập nhật displayName
      await cred.user?.updateDisplayName(name);

      // Lưu hồ sơ user vào Firestore
      final uid = cred.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      // Quay lại màn Login (authStateChanges trong main sẽ tự điều hướng)
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo tài khoản thành công')),
      );
    } on FirebaseAuthException catch (e) {
      final msg = _mapError(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại.')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':         return 'Email không hợp lệ';
      case 'email-already-in-use':  return 'Email đã được sử dụng';
      case 'weak-password':         return 'Mật khẩu quá yếu';
      case 'operation-not-allowed': return 'Tài khoản chưa được cho phép';
      default: return e.message ?? 'Đăng ký thất bại';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo tài khoản')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            controller: nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Họ và tên',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.person_outline),
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
              prefixIcon: const Icon(Icons.email_outlined),
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
              prefixIcon: const Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: pass2Ctrl,
            obscureText: !showPass2,
            decoration: InputDecoration(
              hintText: 'Nhập lại mật khẩu',
              suffixIcon: IconButton(
                icon: Icon(showPass2 ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => showPass2 = !showPass2),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.lock_reset_outlined),
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: loading ? 'Đang tạo tài khoản...' : 'Đăng ký',
            onPressed: loading ? null : _register,
          ),
        ],
      ),
    );
  }
}
