import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  String _themeMode = 'system'; // 'system', 'light', 'dark'

  final Box _settingsBox = Hive.box('settings');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final hour = _settingsBox.get('reminderHour', defaultValue: 20);
    final minute = _settingsBox.get('reminderMinute', defaultValue: 0);
    final themeMode = _settingsBox.get('themeMode', defaultValue: 'system');

    setState(() {
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      _themeMode = themeMode;
    });
  }

  Future<void> _saveReminderTime(TimeOfDay time) async {
    await _settingsBox.put('reminderHour', time.hour);
    await _settingsBox.put('reminderMinute', time.minute);
    setState(() {
      _reminderTime = time;
    });

    // TODO: 实现通知功能（需要迁移到 Android embedding v2）
  }

  Future<void> _setThemeMode(String mode) async {
    await _settingsBox.put('themeMode', mode);
    setState(() {
      _themeMode = mode;
    });
    
    // 动态更新主题模式
    if (mounted) {
      final app = context.findAncestorWidgetOfExactType<JideAppRoot>();
      if (app != null) {
        app.setThemeMode(mode);
      }
    }
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
            title: const Text('主题模式'),
            subtitle: Text(_themeMode == 'system' ? '跟随系统' : _themeMode == 'dark' ? '深色模式' : '浅色模式'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('选择主题模式'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        title: const Text('跟随系统'),
                        value: 'system',
                        groupValue: _themeMode,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _setThemeMode(value!);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('深色模式'),
                        value: 'dark',
                        groupValue: _themeMode,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _setThemeMode(value!);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('浅色模式'),
                        value: 'light',
                        groupValue: _themeMode,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _setThemeMode(value!);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
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
              '💡 提示：通知功能将在后续版本中实现（需要 Android embedding v2 迁移）',
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
