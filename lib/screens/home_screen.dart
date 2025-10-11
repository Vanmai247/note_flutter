import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';   // 👈 thêm
import '../providers/task_provider.dart';
import '../theme.dart';
import '../widgets/task_tile.dart';
import '../widgets/date_pills.dart';
import '../widgets/app_drawer.dart';
import 'create_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TaskProvider>();
    final tasks = prov.tasksFor(prov.selectedDay);
    final user  = FirebaseAuth.instance.currentUser;

    return Scaffold(
      drawer: const AppDrawer(),
      body: Builder(
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('d MMM').format(prov.selectedDay),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    const Spacer(),

                    // 👇 Nút menu (có Đăng xuất)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (v) async {
                        if (v == 'logout') {
                          await FirebaseAuth.instance.signOut();
                          // Stream authStateChanges() trong main.dart sẽ tự đưa về Login
                        }
                      },
                      itemBuilder: (_) => [
                        if (user != null)
                          const PopupMenuItem(
                            value: 'logout',
                            child: Text('Đăng xuất'),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Today + Add
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Today', style: TextStyle(color: Colors.white70)),
                            Text(
                              '${tasks.length} Tasks',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                            ),
                            if (user != null) ...[
                              const SizedBox(height: 6),
                              Text(user.email ?? '',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
                        ),
                        child: const Text('Add New'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                DatePills(base: prov.selectedDay),

                const SizedBox(height: 14),
                const Text('My Tasks', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: tasks.length,
                    itemBuilder: (_, i) => TaskTile(task: tasks[i]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
