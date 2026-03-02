import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'models/note.dart';
import 'providers/note_provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_review_screen.dart';
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
  bool _hasShownSplash = false;

  void setThemeMode(String mode) {
    _themeProvider.setThemeMode(mode);
  }

  @override
  void initState() {
    super.initState();
    _checkAndShowSplash();
  }

  Future<void> _checkAndShowSplash() async {
    // 等待一帧确保 Provider 已初始化
    await WidgetsBinding.instance.endOfFrame;
    
    if (_hasShownSplash || !mounted) return;
    
    _hasShownSplash = true;
    final noteProvider = context.read<NoteProvider>();
    final reviewNotes = noteProvider.reviewNotes;
    
    // 只有当有需要复习的笔记时才显示开屏
    if (reviewNotes.isNotEmpty && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SplashReviewScreen(),
          fullscreenDialog: true,
        ),
      );
    }
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
              colorScheme: ColorScheme(
                brightness: Brightness.light,
                primary: const Color(0xFF007AFF),
                onPrimary: const Color(0xFFFFFFFF),
                secondary: const Color(0xFF5856D6),
                onSecondary: const Color(0xFFFFFFFF),
                surface: const Color(0xFFF5F5F5),
                onSurface: const Color(0xFF1C1C1C),
                error: const Color(0xFFFF3B30),
                onError: const Color(0xFFFFFFFF),
                outline: const Color(0xFF8E8E93),
                onSurfaceVariant: const Color(0xFF666666),
              ),
              scaffoldBackgroundColor: const Color(0xFFFFFFFF),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFFFFFFF),
                foregroundColor: Color(0xFF1C1C1C),
                elevation: 0,
              ),
              cardTheme: CardTheme(
                color: const Color(0xFFF5F5F5),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                ),
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme(
                brightness: Brightness.dark,
                primary: const Color(0xFF0A84FF),
                onPrimary: const Color(0xFFFFFFFF),
                secondary: const Color(0xFF5E5CE6),
                onSecondary: const Color(0xFFFFFFFF),
                surface: const Color(0xFF1C1C1C),
                onSurface: const Color(0xFFF5F5F5),
                error: const Color(0xFFFF453A),
                onError: const Color(0xFFFFFFFF),
                outline: const Color(0xFF8E8E93),
                onSurfaceVariant: const Color(0xFF98989D),
              ),
              scaffoldBackgroundColor: const Color(0xFF000000),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1C1C1C),
                foregroundColor: Color(0xFFF5F5F5),
                elevation: 0,
              ),
              cardTheme: CardTheme(
                color: const Color(0xFF1C1C1C),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF2C2C2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0A84FF), width: 2),
                ),
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
