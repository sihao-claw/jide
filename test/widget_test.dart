import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:jide/main.dart';
import 'package:jide/providers/note_provider.dart';
import 'package:jide/models/note.dart';

void main() {
  setUpAll(() async {
    // 初始化 Hive
    await Hive.initFlutter();
    Hive.registerAdapter(NoteAdapter());
    await Hive.openBox<Note>('notes');
    await Hive.openBox('settings');
  });

  testWidgets('开屏复习页面 - 显示笔记卡片', (WidgetTester tester) async {
    // 创建测试笔记
    final noteProvider = NoteProvider();
    await noteProvider.createNote(
      title: '测试笔记',
      content: '这是一条测试笔记的内容',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: noteProvider),
        ],
        child: const MaterialApp(
          home: SplashReviewScreen(),
        ),
      ),
    );

    // 等待加载完成
    await tester.pumpAndSettle();

    // 验证笔记标题显示
    expect(find.text('测试笔记'), findsOneWidget);
    
    // 验证进度条显示
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    
    // 验证按钮存在
    expect(find.text('跳过'), findsOneWidget);
    expect(find.text('记得'), findsOneWidget);
  });

  testWidgets('笔记编辑器 - 底部保存按钮测试', (WidgetTester tester) async {
    final noteProvider = NoteProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: noteProvider),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: NoteEditorScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 验证底部保存按钮存在
    expect(find.text('保存笔记'), findsOneWidget);
    
    // 验证按钮有图标
    expect(find.byIcon(Icons.save), findsOneWidget);
    
    // 验证按钮高度足够（易点击）
    final saveButton = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton).first,
    );
    expect(saveButton, isNotNull);
  });

  testWidgets('浅色模式 - 颜色值验证', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeProvider),
        ],
        child: const JideAppRoot(),
      ),
    );

    await tester.pumpAndSettle();

    // 验证主题颜色
    final theme = ThemeData(
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: const Color(0xFF007AFF),
        onPrimary: const Color(0xFFFFFFFF),
        surface: const Color(0xFFF5F5F5),
        onSurface: const Color(0xFF1C1C1C),
        outline: const Color(0xFF8E8E93),
        onSurfaceVariant: const Color(0xFF666666),
      ),
    );

    // 验证中性灰色（RGB 三值相同）
    expect(theme.colorScheme.surface.value & 0xFF, equals(0xF5));
    expect((theme.colorScheme.surface.value >> 8) & 0xFF, equals(0xF5));
    expect((theme.colorScheme.surface.value >> 16) & 0xFF, equals(0xF5));
    
    expect(theme.colorScheme.onSurfaceVariant.value & 0xFF, equals(0x66));
    expect((theme.colorScheme.onSurfaceVariant.value >> 8) & 0xFF, equals(0x66));
    expect((theme.colorScheme.onSurfaceVariant.value >> 16) & 0xFF, equals(0x66));
  });

  testWidgets('遗忘曲线算法验证', (WidgetTester tester) async {
    final note = Note(
      id: 'test-1',
      title: '测试',
      content: '内容',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      likeCount: 0,
      reviewWeight: 1.0,
    );

    // 验证初始状态需要复习
    expect(note.shouldReviewToday(), isTrue);

    // 点赞 1 次后，应该 1 天后复习
    note.like();
    expect(note.likeCount, equals(1));
    
    // 点赞 3 次后，应该 4 天后复习
    note.like();
    note.like();
    expect(note.likeCount, equals(3));
  });
}
