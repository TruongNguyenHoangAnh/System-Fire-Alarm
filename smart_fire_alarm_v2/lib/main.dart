import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

// --- 1. XỬ LÝ THÔNG BÁO KHI APP TẮT (BACKGROUND) ---
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Nhận thông báo ngầm: ${message.notification?.title}");
}

// Khởi tạo kênh thông báo Android
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'Cảnh báo khẩn cấp', // title
  description: 'Kênh thông báo cho các cảnh báo cháy quan trọng.',
  importance: Importance.max,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Đăng ký hàm xử lý ngầm
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Cấu hình Local Notification (để hiện thông báo khi đang mở App)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  // Xin quyền thông báo (quan trọng cho Android 13+ và iOS)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // --- QUAN TRỌNG: ĐĂNG KÝ THEO DÕI TOPIC "fire_alerts" ---
  await FirebaseMessaging.instance.subscribeToTopic('fire_alerts');
  print("Đã đăng ký nhận tin từ topic: fire_alerts");

  // Lắng nghe thông báo khi App đang mở (Foreground)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            color: Colors.red,
            playSound: true,
            icon: '@mipmap/ic_launcher', // Icon mặc định của App
          ),
        ),
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fire Alarm System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepOrange, useMaterial3: true),
      home: const LoginScreen(),
    );
  }
}
