import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'theme.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'firebase_options.dart';
import 'screens/profile_screen.dart';

// ⬇️ Thêm import notification service
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Bật offline persistence cho Firestore
  FirebaseFirestore.instance.settings =
  const Settings(persistenceEnabled: true);

  // ⬇️ Khởi tạo local notification + xin quyền thông báo
  await NotificationService.init();
  await NotificationService.requestPermission();

  runApp(const TaskyApp());
}

class TaskyApp extends StatelessWidget {
  const TaskyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tasky',
        theme: buildTheme(),

        // Điều hướng theo trạng thái đăng nhập
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Đang chờ Firebase trả về trạng thái
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Nếu có lỗi trong quá trình xác thực
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Auth error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            // Có user → vào Home
            if (snapshot.hasData) {
              return const HomeScreen();
            }

            // Chưa đăng nhập → vào Login
            return const LoginScreen();
          },
        ),

        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/forgot': (_) => const ForgotPasswordScreen(),
          '/profile': (_) => const ProfileScreen(),
        },

        // Nếu route lạ → về Home (có stream guard ở trên)
        onUnknownRoute: (_) =>
            MaterialPageRoute(builder: (_) => const HomeScreen()),
      ),
    );
  }
}
