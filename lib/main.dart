import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'models/note.dart';
import 'providers/note_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  
  // 注册适配器
  Hive.registerAdapter(NoteAdapter());
  
  // 打开笔记盒子
  await Hive.openBox<Note>('notes');
  await Hive.openBox('settings');
  
  // 初始化通知服务
  await NotificationService.initialize();
  
  runApp(JideApp());
}

class ThemeProvider extends ChangeNotifier {
  String _themeMode = 'system';

  String get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final box = Hive.box('settings');
    _themeMode = box.get('themeMode', defaultValue: 'system');
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    final box = Hive.box('settings');
    await box.put('themeMode', mode);
    _themeMode = mode;
    notifyListeners();
  }

  ThemeMode get themeModeEnum {
    switch (_themeMode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}

class JideAppRoot extends StatefulWidget {
  const JideAppRoot({super.key});

  @override
  State<JideAppRoot> createState() => _JideAppRootState();
}

class _JideAppRootState extends State<JideAppRoot> {
  final ThemeProvider _themeProvider = ThemeProvider();

  void setThemeMode(String mode) {
    _themeProvider.setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider.value(value: _themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: '记得',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4CAF50),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4CAF50),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: themeProvider.themeModeEnum,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}

class JideApp extends StatelessWidget {
  const JideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const JideAppRoot();
  }
}
