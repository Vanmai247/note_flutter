import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/primary_button.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  bool _loading = false;

  /// Avatar: chỉ lưu local trên máy
  File? _avatarFile; // ảnh vừa chọn / đã lưu

  final _picker = ImagePicker();

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  /// Tải thông tin từ Firestore + avatar từ SharedPreferences
  Future<void> _loadProfile() async {
    final user = _user;
    if (user == null) return;

    setState(() => _loading = true);

    try {
      // ----- Đọc Firestore -----
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        _nameCtrl.text = data?['name'] ?? '';
        _phoneCtrl.text = data?['phone'] ?? '';
        _bioCtrl.text = data?['bio'] ?? '';
      } else {
        // tạo user lần đầu
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'email': user.email,
          'name': user.displayName ?? '',
          'phone': '',
          'bio': '',
        });

        _nameCtrl.text = user.displayName ?? '';
      }

      // ----- Đọc đường dẫn avatar lưu local -----
      final prefs = await SharedPreferences.getInstance();
      final savedPath = prefs.getString('avatarPath');
      if (savedPath != null) {
        final file = File(savedPath);
        if (file.existsSync()) {
          _avatarFile = file;
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi tải hồ sơ: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  /// Chọn ảnh đại diện
  Future<void> _pickAvatar() async {
    final picked =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

  /// Lưu toàn bộ hồ sơ (Firestore + đường dẫn avatar local)
  Future<void> _saveProfile() async {
    final user = _user;
    if (user == null) return;

    setState(() => _loading = true);

    try {
      final name = _nameCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();
      final bio = _bioCtrl.text.trim();

      // Lưu thông tin text lên Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'email': user.email,
        'name': name,
        'phone': phone,
        'bio': bio,
      }, SetOptions(merge: true));

      await user.updateDisplayName(name);

      // Lưu đường dẫn avatar xuống SharedPreferences (local)
      if (_avatarFile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('avatarPath', _avatarFile!.path);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã lưu hồ sơ')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi lưu hồ sơ: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    if (_loading && user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    InkWell(
                      onTap: _pickAvatar,
                      borderRadius: BorderRadius.circular(999),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.primary,
                        backgroundImage: _avatarFile != null
                            ? FileImage(_avatarFile!)
                            : null,
                        child: _avatarFile == null
                            ? Text(
                          (user?.email != null &&
                              user!.email!.isNotEmpty)
                              ? user.email![0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        )
                            : null,
                      ),
                    ),

                    // Icon camera
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                              color: Colors.black.withValues(alpha: 0.15),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(user?.email ?? '(không có email)'),

              const SizedBox(height: 20),

              const Text(
                'Tên hiển thị',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nhập tên của bạn',
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Số điện thoại',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nhập số điện thoại',
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Giới thiệu bản thân',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _bioCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Mô tả ngắn...',
                ),
              ),

              const SizedBox(height: 24),

              PrimaryButton(
                label: _loading ? 'Đang lưu...' : 'Lưu thay đổi',
                onPressed: _loading ? null : _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
