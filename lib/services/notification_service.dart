import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  /// Gọi 1 lần ở main()
  static Future<void> init() async {
    // Khởi tạo timezone
    tz.initializeTimeZones();

    // Đơn giản: fix cứng Asia/Ho_Chi_Minh (VN)
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);
  }

  /// Xin quyền thông báo (Android 13+ / Redmi Note 14)
  static Future<void> requestPermission() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.requestNotificationsPermission();
  }

  /// Hàm test thông báo ngay lập tức (để thử xem plugin có chạy không)
  static Future<void> showTestNow() async {
    await _plugin.show(
      9999,
      'Test Tasky',
      'Thông báo thành công',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tasky_channel',
          'Nhắc việc Tasky',
          channelDescription: 'Thông báo nhắc giờ các task',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  /// Schedule thông báo cho 1 task
  static Future<void> scheduleTaskNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    // Nếu thời điểm đã qua thì khỏi schedule
    if (time.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tasky_channel',
          'Nhắc việc Tasky',
          channelDescription: 'Thông báo nhắc giờ các task',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidAllowWhileIdle: true, // nếu version plugin cho phép thì OK
    );
  }

  /// Hủy thông báo (khi xóa task / đánh dấu xong)
  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
