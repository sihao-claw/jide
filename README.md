# 记得 - Jide App

一款帮你真正记住知识的笔记类 App

## 核心功能

- 📝 **方便记** - 整合大语言模型，链接一键生成 AI 总结笔记
- ⏰ **定时提醒** - 基于遗忘曲线的复习提醒机制
- 📱 **多端支持** - Windows/Android/iOS (Flutter 开发)

## 开发环境

- Flutter SDK: >=3.0.0 <4.0.0
- Dart SDK: >=3.0.0 <4.0.0

## 快速开始

```bash
# 安装依赖
flutter pub get

# 运行应用
flutter run

# 构建 Windows
flutter build windows

# 构建 Android
flutter build apk
```

## 项目结构

```
lib/
├── main.dart              # 入口文件
├── models/                # 数据模型
│   └── note.dart          # 笔记模型
├── screens/               # 页面
│   ├── home_screen.dart   # 主页
│   ├── calendar_screen.dart # 日历视图
│   ├── note_editor.dart   # 笔记编辑
│   └── settings_screen.dart # 设置
├── widgets/               # 可复用组件
├── services/              # 服务层
│   ├── ai_service.dart    # AI 总结服务
│   ├── notification_service.dart # 通知服务
│   └── storage_service.dart # 本地存储
└── utils/                 # 工具类
```

## GitHub Action 打包

项目配置了 GitHub Action 自动打包流程，详见 `.github/workflows/`

## 自测要求

每次开发后需使用 computer-use 技能进行 Linux 版本自测

## License

MIT
