import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ListTile(
              leading: Icon(Icons.done_all_rounded),
              title: Text('Tasky', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              subtitle: Text('Quản lý công việc'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Trang chủ'),
              onTap: () {
                Navigator.pop(context); // đóng drawer
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Đăng nhập'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
            ),
            const Spacer(),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('v1.0.0', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
            ),
          ],
        ),
      ),
    );
  }
}

