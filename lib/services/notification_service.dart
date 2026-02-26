import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Android 初始化设置
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS 初始化设置
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 请求权限
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    // Android 13+ 需要请求通知权限
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // iOS 需要请求通知权限
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // TODO: 跳转到复习页面
    print('通知被点击：${response.payload}');
  }

  /// 显示每日复习提醒
  static Future<void> showDailyReviewReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_review',
      '每日复习',
      channelDescription: '提醒你复习历史笔记',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      '记得',
      '今天有新的笔记等待复习，快来看看吧！📚',
      details,
      payload: 'review',
    );
  }

  /// 显示开屏复习提醒（应用内）
  static Future<void> showInAppReviewReminder(String noteTitle) async {
    const androidDetails = AndroidNotificationDetails(
      'in_app_review',
      '应用内复习',
      channelDescription: '应用内显示的复习提醒',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      '复习提醒',
      '该复习这篇笔记了：$noteTitle',
      details,
      payload: 'in_app_review',
    );
  }

  /// 取消所有通知
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
