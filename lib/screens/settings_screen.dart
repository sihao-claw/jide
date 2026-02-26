import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isDarkMode = false;

  final Box _settingsBox = Hive.box('settings');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final hour = _settingsBox.get('reminderHour', defaultValue: 20);
    final minute = _settingsBox.get('reminderMinute', defaultValue: 0);
    final isDark = _settingsBox.get('isDarkMode', defaultValue: false);

    setState(() {
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      _isDarkMode = isDark;
    });
  }

  Future<void> _saveReminderTime(TimeOfDay time) async {
    await _settingsBox.put('reminderHour', time.hour);
    await _settingsBox.put('reminderMinute', time.minute);
    setState(() {
      _reminderTime = time;
    });

    // 更新本地通知
    await _scheduleDailyReminder(time);
  }

  Future<void> _scheduleDailyReminder(TimeOfDay time) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    final androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      '每日提醒',
      channelDescription: '每天定时提醒查看笔记',
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = const DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 计算触发时间
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '记得',
      '今天有新的笔记等待复习，快来看看吧！',
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiAllowScheduleExact: true,
    );
  }

  Future<void> _toggleDarkMode(bool value) async {
    await _settingsBox.put('isDarkMode', value);
    setState(() {
      _isDarkMode = value;
    });

    // TODO: 动态切换主题
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // 主题设置
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('深色模式'),
            subtitle: Text(_isDarkMode ? '已开启' : '已关闭'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: _toggleDarkMode,
            ),
          ),
          const Divider(),

          // 提醒时间设置
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('每日提醒时间'),
            subtitle: Text('${_reminderTime.format(context)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _reminderTime,
              );
              if (picked != null) {
                await _saveReminderTime(picked);
              }
            },
          ),
          const Divider(),

          // 关于
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于'),
            subtitle: const Text('版本 1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '记得',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 记得 App',
                children: [
                  const SizedBox(height: 16),
                  const Text('一款帮你真正记住知识的笔记 App'),
                ],
              );
            },
          ),
          const Divider(),

          // 取消提醒提示
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '💡 提示：如需取消每日提醒，请前往系统设置关闭应用通知',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
